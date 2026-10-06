import Foundation

@main struct CachedReadTests {
  static func main() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-cached-reads-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let bytes = Data((0..<(4 * 1024 * 1024)).map { UInt8($0 % 251) })
    let node = try GardenNode(["id": 1, "parentId": 0, "name": "audio.wav", "kind": "file",
      "size": bytes.count, "version": 1, "updatedAt": "2026-10-07T00:00:00.000Z", "deleted": false])
    let domain = "cached-reads-\(UUID())"
    let cache = GardenRangeCache(api: GardenAPI(domainID: domain), domainID: domain,
      diskLimit: 8 * 1024 * 1024, directory: root,
      readRange: { _, offset, length in Data(bytes[offset..<(offset + length)]) })
    guard try await cache.read(node: node, offset: 0, length: bytes.count) == bytes else {
      throw POSIXError(.EIO)
    }
    await cache.invalidate()
    let expected = (0..<1024).map { Data(bytes[($0 * 4096)..<(($0 + 1) * 4096)]) }
    let remoteBefore = await cache.remoteBytes
    for source in ["Memory", "Disk"] {
      if source == "Disk" { await GardenReadBuffer.shared.clear() }
      let started = ContinuousClock.now
      for index in 0..<65536 {
        let block = index % 1024
        let data = try await cache.read(node: node, offset: block * 4096, length: 4096)
        guard data == expected[block] else { throw POSIXError(.EIO) }
      }
      for length in [65536, 131072, 1048576] {
        let offsets = (0..<32).map { $0 * 65536 + 123 }
        let expected = offsets.map { Data(bytes[$0..<($0 + length)]) }
        for index in 0..<4096 {
          let block = index % offsets.count
          let data = try await cache.read(node: node, offset: offsets[block], length: length)
          guard data == expected[block] else { throw POSIXError(.EIO) }
        }
      }
      await cache.invalidate()
      guard await cache.remoteBytes == remoteBefore else { throw POSIXError(.EIO) }
      print("\(source): exact cached small and unaligned bulk reads, no remote bytes, \(started.duration(to: .now))")
    }
    let partial = try GardenNode(["id": 2, "parentId": 0, "name": "partial.wav", "kind": "file",
      "size": bytes.count, "version": 1, "updatedAt": "2026-10-07T00:00:00.000Z", "deleted": false])
    _ = try await cache.read(node: partial, offset: 0, length: 65536, persist: false)
    let before = await cache.remoteBytes
    let result = try await cache.read(node: partial, offset: 123, length: 131072, persist: false)
    guard result == Data(bytes[123..<131195]), await cache.remoteBytes - before == 131072 else {
      throw POSIXError(.EIO)
    }
    await cache.invalidate()
    let buffer = GardenReadBuffer(capacity: 8)
    let entry = Data([1, 2, 3, 4])
    await buffer.store(entry, key: "first")
    await buffer.store(entry, key: "second")
    guard await buffer.read(["first", "second"]) == [entry, entry] else { throw POSIXError(.EIO) }
    await buffer.store(entry, key: "third")
    guard await buffer.read("first") == nil, await buffer.read(["second", "third"]) == [entry, entry],
      await buffer.used == 8 else { throw POSIXError(.EIO) }
    print("Partial cached ranges and bounded batch-read eviction passed")
  }
}
