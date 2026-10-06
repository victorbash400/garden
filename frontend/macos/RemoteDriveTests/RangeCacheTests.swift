import Foundation

actor RangeSource {
  var requests: [(Int, Int)] = []
  func read(_ node: GardenNode, _ offset: Int, _ length: Int) async throws -> Data {
    requests.append((offset, length))
    try await Task.sleep(for: .milliseconds(20))
    return Data((offset..<(offset + length)).map { UInt8($0 % 251) })
  }
}

@main struct RangeCacheTests {
  static func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw NSError(domain: "RangeCacheTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }
  static func main() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-range-tests-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let source = RangeSource()
    let domain = "range-test-\(UUID())"
    let cache = GardenRangeCache(api: GardenAPI(domainID: domain), domainID: domain, diskLimit: 8 * 1024 * 1024,
      directory: root, readRange: { node, offset, length in try await source.read(node, offset, length) })
    let size = 100 * 1024 * 1024 + 123
    let node = try GardenNode(["id": 1, "parentId": 0, "name": "test.webm", "kind": "file", "size": size,
      "version": 1, "updatedAt": "2026-10-06T00:00:00.000Z", "deleted": false])
    let start = ContinuousClock.now
    for index in 0..<16 {
      let offset = index * 65536
      let data = try await cache.read(node: node, offset: offset, length: 65536)
      try require(data == Data((offset..<(offset + 65536)).map { UInt8($0 % 251) }), "Sequential bytes differ")
    }
    await cache.invalidate()
    let requests = await source.requests
    try require(requests.count <= 6, "Nearby reads must share bounded bulk windows")
    try require(await cache.remoteBytes <= 4 * 1024 * 1024, "Fast read-ahead must stay within three blocks ahead")
    print("16 sequential 64 KiB reads: \(requests.count) requests including read-ahead, \(start.duration(to: .now))")
    _ = try await cache.read(node: node, offset: 1234, length: 700000)
    try require(await source.requests.count == requests.count, "Changing read size must reuse cached pages")
    let far = 90 * 1024 * 1024
    let random = try await cache.read(node: node, offset: far + 123, length: 256)
    try require(random == Data(((far + 123)..<(far + 379)).map { UInt8($0 % 251) }), "Seek bytes differ")
    try require(await source.requests.last?.1 == 65536, "An isolated seek must not trigger bulk fetching")
    let before = await source.requests.count
    let uncached = 60 * 1024 * 1024
    try await withThrowingTaskGroup(of: Data.self) { group in
      for _ in 0..<8 { group.addTask { try await cache.read(node: node, offset: uncached, length: 32768) } }
      for try await bytes in group { try require(bytes.count == 32768, "Concurrent result size differs") }
    }
    try require(await source.requests.count - before == 1, "Overlapping reads should share one request")
    let final = try await cache.read(node: node, offset: size - 70, length: 512)
    try require(final == Data(((size - 70)..<size).map { UInt8($0 % 251) }), "EOF bytes differ")
    await GardenReadBuffer.shared.clear()
    let count = await source.requests.count
    let reopened = GardenRangeCache(api: GardenAPI(domainID: domain), domainID: domain, diskLimit: 8 * 1024 * 1024,
      directory: root, readRange: { node, offset, length in try await source.read(node, offset, length) })
    _ = try await reopened.read(node: node, offset: 0, length: 1)
    try require(await source.requests.count == count, "Reopened cache must reuse persisted pages")
    var record: [String: Any] = ["id": 1, "parentId": 0, "name": "test.webm", "kind": "file", "size": size,
      "version": 2, "updatedAt": "2026-10-06T00:00:00.000Z", "deleted": false]
    record["version"] = 2
    _ = try await reopened.read(node: GardenNode(record), offset: 0, length: 1)
    try require(await source.requests.count == count + 1, "New versions must not reuse old pages")
    print("Byte correctness, partial seeks, concurrent reuse, EOF, disk reuse and version isolation passed")
    var streams = GardenReadWindow()
    for step in 0..<4 {
      let first = streams.observe(offset: step * 16384, length: 16384)
      let second = streams.observe(offset: 10 * 1024 * 1024 + step * 16384, length: 16384)
      if step == 3 {
        try require(first == GardenReadWindow.maximumSize && second == GardenReadWindow.maximumSize,
          "Interleaved readers must retain separate sequential windows")
      }
    }
    try require(streams.observe(offset: 90 * 1024 * 1024, length: 16384) == GardenReadWindow.pageSize,
      "A distant metadata seek must retain a small window")
    let audio = try GardenNode(["id": 2, "parentId": 0, "name": "audio.wav", "kind": "file", "size": size,
      "version": 1, "updatedAt": "2026-10-06T00:00:00.000Z", "deleted": false])
    let audioBefore = await source.requests.count
    let bytesBefore = await cache.remoteBytes
    for offset in stride(from: 0, to: 2 * 1024 * 1024, by: 4096) {
      let data = try await cache.read(node: audio, offset: offset, length: 4096)
      try require(data == Data((offset..<(offset + 4096)).map { UInt8($0 % 251) }), "Small audio reads differ")
    }
    await cache.invalidate()
    try require(await source.requests.count - audioBefore <= 7, "Small sequential audio reads must reuse bounded read-ahead")
    try require(await cache.remoteBytes - bytesBefore <= 5 * 1024 * 1024 + 65536,
      "Fast small-read prefetch must stay within three bulk windows ahead")
    print("512 small audio reads: byte correctness, shared requests and bounded read-ahead passed")
    for length in [16384, 32768] {
      let media = try GardenNode(["id": length, "parentId": 0, "name": "media.webm", "kind": "file", "size": size,
        "version": 1, "updatedAt": "2026-10-06T00:00:00.000Z", "deleted": false])
      let before = await source.requests.count
      let bytesBefore = await cache.remoteBytes
      for offset in stride(from: 0, to: 2 * 1024 * 1024, by: length) {
        let bytes = try await cache.read(node: media, offset: offset, length: length)
        try require(bytes == Data((offset..<(offset + length)).map { UInt8($0 % 251) }), "Media stream bytes differ")
        if offset == 1024 * 1024 - 2 * length {
          let started = await source.requests.dropFirst(before).contains { $0.0 == 1024 * 1024 }
          try require(started, "The next media window must start before the current one is exhausted")
        }
      }
      await cache.invalidate()
      try require(await source.requests.count - before <= 7, "Sequential media reads must reuse bounded windows")
      try require(await cache.remoteBytes - bytesBefore <= 5 * 1024 * 1024 + 65536,
        "Fast media read-ahead must stay within three blocks ahead")
    }
    print("16 and 32 KiB media streams: byte correctness and bounded read-ahead passed")
    let instant = ContinuousClock.now
    var fast = GardenReadWindow()
    var slow = GardenReadWindow()
    for index in 0..<32 {
      _ = fast.observe(offset: index * 32768, length: 32768, now: instant.advanced(by: .milliseconds(index)))
      _ = slow.observe(offset: index * 32768, length: 32768, now: instant.advanced(by: .milliseconds(index * 40)))
    }
    try require(fast.payloadReadAheadBlocks == 3, "Sustained fast consumers need a bounded three-block pipeline")
    try require(slow.payloadReadAheadBlocks == 1, "Paced consumers must keep the smaller read-ahead window")
    _ = fast.observe(offset: 90 * 1024 * 1024, length: 32768, now: instant.advanced(by: .seconds(2)))
    try require(fast.payloadReadAheadBlocks == 1, "A distant seek must reset the payload pipeline")
  }
}
