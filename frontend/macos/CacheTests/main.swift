import Foundation

@main struct CacheTests {
  static func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw NSError(domain: "CacheTests", code: 1,
      userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func worker(root: URL, namespace: String, base: Int) async throws -> Int32 {
    try await withCheckedThrowingContinuation { continuation in
      let process = Process()
      process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
      process.arguments = [root.path, namespace, String(base)]
      process.terminationHandler = { continuation.resume(returning: $0.terminationStatus) }
      do { try process.run() }
      catch { continuation.resume(throwing: error) }
    }
  }

  static func main() async throws {
    setbuf(stdout, nil)
    if CommandLine.arguments.count == 4 {
      let cache = GardenDiskCache(directory: URL(fileURLWithPath: CommandLine.arguments[1]), limit: 4 * 1024 * 1024)
      let namespace = CommandLine.arguments[2]
      let base = Int(CommandLine.arguments[3])!
      for index in base..<(base + 20) {
        try await cache.store(Data(repeating: 8, count: 1024 * 1024), key: "\(namespace)/1-1-\(index)")
        let status = try await cache.status()
        try require(status.used <= status.limit, "Process exceeded the shared budget")
      }
      return
    }
    let buffer = GardenReadBuffer(capacity: 2 * 1024 * 1024)
    let buffered = Data(repeating: 9, count: 1024 * 1024)
    await buffer.store(buffered, key: "first")
    await buffer.store(buffered, key: "second")
    _ = await buffer.read("first")
    await buffer.store(buffered, key: "third")
    try require(await buffer.used == 2 * 1024 * 1024, "RAM buffer exceeded its bound")
    try require(await buffer.read("second") == nil, "RAM buffer evicted the wrong block")
    await buffer.clear()
    try require(await buffer.used == 0, "RAM buffer did not clear")
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-cache-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    let written = root.appendingPathComponent("range-write")
    let progress = Progress(totalUnitCount: 0)
    let begin = 17
    let end = 4 * 1024 * 1024 + 93
    try await GardenRangeWriter.write(start: begin, end: end, to: written, progress: progress) { offset, count in
      await Task.yield()
      return Data(repeating: UInt8((offset - begin) / (1024 * 1024)), count: count)
    }
    let contents = try Data(contentsOf: written)
    try require(contents.count == end && contents.prefix(begin) == Data(repeating: 0, count: begin), "Sparse range boundaries changed")
    for position in begin..<end {
      try require(contents[position] == UInt8((position - begin) / (1024 * 1024)), "Parallel writes reordered bytes")
    }
    try require(progress.completedUnitCount == Int64(end - begin), "Parallel write progress is incorrect")
    let incomplete = root.appendingPathComponent("incomplete-write")
    do {
      try await GardenRangeWriter.write(start: 0, end: 100, to: incomplete, progress: Progress()) { _, _ in Data() }
      throw NSError(domain: "CacheTests", code: 1)
    } catch GardenAPIError.invalidResponse { }
    try require(!FileManager.default.fileExists(atPath: incomplete.path), "Failed range write retained an incomplete file")
    let cache = GardenDiskCache(directory: root, limit: 4 * 1024 * 1024)
    let peer = GardenDiskCache(directory: root, limit: 4 * 1024 * 1024)
    let a = String(repeating: "a", count: 64)
    let b = String(repeating: "b", count: 64)
    let block = Data(repeating: 7, count: 1024 * 1024)
    try await cache.store(block, key: "\(a)/1-1-0")
    try await peer.store(block, key: "\(b)/2-1-0")
    try require(try await cache.status().used == 2 * 1024 * 1024, "Drives do not share usage")
    _ = try await cache.read("\(a)/1-1-0", expected: block.count)
    _ = try await cache.setLimit(Int64(block.count), persist: false)
    let evicted = try await peer.read("\(b)/2-1-0", expected: block.count)
    try require(evicted == nil, "LRU eviction retained the older drive")
    let retained = try await peer.read("\(a)/1-1-0", expected: block.count)
    try require(retained == block, "LRU eviction lost the most recently read block")
    _ = try await cache.setLimit(4 * 1024 * 1024, persist: false)
    try await withThrowingTaskGroup(of: Void.self) { group in
      for index in 1...40 {
        group.addTask {
          let owner = index.isMultiple(of: 2) ? cache : peer
          try await owner.store(block, key: "\(a)/1-1-\(index)")
          let state = try await owner.status()
          try require(state.used <= state.limit, "Concurrent writes exceeded budget")
        }
      }
      try await group.waitForAll()
    }
    async let firstProcess = worker(root: root, namespace: a, base: 100)
    async let secondProcess = worker(root: root, namespace: b, base: 200)
    let results = try await (firstProcess, secondProcess)
    try require(results.0 == 0 && results.1 == 0, "Separate cache processes failed")
    _ = try await peer.setLimit(2 * 1024 * 1024, persist: false)
    let reopened = GardenDiskCache(directory: root, limit: 4 * 1024 * 1024)
    let persisted = try await reopened.status()
    try require(persisted.limit == 2 * 1024 * 1024 && persisted.used <= persisted.limit, "Budget did not survive reopening")
    _ = try await cache.setLimit(0, persist: false)
    try await peer.store(block, key: "\(b)/2-1-99")
    let zero = try await reopened.status()
    try require(zero.used == 0 && zero.blocks == 0, "Late read persisted data after zero limit")
    _ = try await cache.setLimit(8192, persist: false)
    let tail = Data(repeating: 5, count: 5000)
    let tailKey = "\(a)/3-1-0"
    try await cache.store(tail, key: tailKey)
    let allocated = try root.appendingPathComponent(tailKey).resourceValues(forKeys: [.fileAllocatedSizeKey]).fileAllocatedSize!
    let tailStatus = try await peer.status()
    try require(tailStatus.used == Int64(allocated) && tailStatus.used <= tailStatus.limit,
      "Partial blocks did not account for their allocated disk size")
    try require(try await cache.read(tailKey, expected: tail.count) == tail, "Partial block contents changed")
    let changes = try await cache.updates()
    var iterator = changes.makeAsyncIterator()
    let first = try await iterator.next()
    try require(first?.used == tailStatus.used, "Subscription did not report current usage")
    _ = try await cache.clear()
    let cleared = try await iterator.next()
    try require(cleared?.used == 0, "Cache clear did not push a usage update")
    try await peer.store(tail, key: tailKey)
    let crossActor = try await iterator.next()
    try require(crossActor?.used == Int64(allocated), "Another cache actor did not push a disk change")
    let result = try await worker(root: root, namespace: b, base: 500)
    try require(result == 0, "Observer test process failed")
    _ = try await cache.setLimit(2 * 1024 * 1024, persist: false)
    let resultAfterLimit = try await worker(root: root, namespace: b, base: 600)
    try require(resultAfterLimit == 0, "Observer test process writes failed")
    let changed = try await iterator.next()
    try require(changed?.used == 2 * 1024 * 1024, "Another process did not push a usage change")
    let pending = root.appendingPathComponent("pending-upload")
    try Data("unsaved edit".utf8).write(to: pending)
    _ = try await reopened.clear()
    try require(try Data(contentsOf: pending) == Data("unsaved edit".utf8), "Cache clear removed pending edits")
    print("Shared budget, LRU, concurrent writers and processes, persisted limits, zero cache, and edit preservation passed.")
  }
}
