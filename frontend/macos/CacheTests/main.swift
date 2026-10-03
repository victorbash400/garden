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
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-cache-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
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
