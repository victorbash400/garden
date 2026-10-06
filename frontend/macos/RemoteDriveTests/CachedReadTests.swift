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
      await cache.invalidate()
      guard await cache.remoteBytes == remoteBefore else { throw POSIXError(.EIO) }
      print("\(source): 65536 exact cached 4 KiB reads, no remote bytes, \(started.duration(to: .now))")
    }
  }
}
