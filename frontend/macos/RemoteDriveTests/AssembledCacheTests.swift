import Foundation

actor AssembledRangeSource {
  var requests = 0
  func read(_ offset: Int, _ length: Int) -> Data {
    requests += 1
    return Data((offset..<(offset + length)).map { UInt8($0 % 251) })
  }
}

@main struct AssembledCacheTests {
  static func main() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-assembled-storage-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let domain = "assembled-storage-\(UUID())", source = AssembledRangeSource()
    let size = 1024 * 1024 + 100000
    let node = try GardenNode(["id": 1, "parentId": 0, "name": "payload.bin", "kind": "file", "size": size,
        "version": 1, "updatedAt": "2026-10-07T00:00:00.000Z", "deleted": false])
    let limit = 3 * 1024 * 1024
    let cache = GardenRangeCache(api: GardenAPI(domainID: domain), domainID: domain, diskLimit: limit,
        directory: root, readRange: { _, offset, length in await source.read(offset, length) })
    _ = try await cache.read(node: node, offset: 0, length: 16384)
    let first = try await cache.read(node: node, offset: 0, length: 1024 * 1024)
    guard first == Data((0..<(1024 * 1024)).map { UInt8($0 % 251) }) else { throw POSIXError(.EIO) }
    await cache.invalidate()
    let tail = try await cache.read(node: node, offset: 1024 * 1024, length: 100000)
    guard tail == Data(((1024 * 1024)..<size).map { UInt8($0 % 251) }) else { throw POSIXError(.EIO) }
    await cache.invalidate()
    let disk = GardenDiskCache(directory: root, limit: Int64(limit))
    let status = try await disk.status()
    guard status.blocks >= 2, status.blocks <= 6, status.used <= limit else { throw POSIXError(.EIO) }
    await GardenReadBuffer.shared.clear()
    let before = await source.requests
    let reopened = GardenRangeCache(api: GardenAPI(domainID: domain), domainID: domain, diskLimit: limit,
        directory: root, readRange: { _, offset, length in await source.read(offset, length) })
    let offset = 1024 * 1024 - 1234
    let crossing = try await reopened.read(node: node, offset: offset, length: 5000)
    let final = try await reopened.read(node: node, offset: size - 100, length: 1000)
    guard crossing == Data((offset..<(offset + 5000)).map { UInt8($0 % 251) }),
        final == Data((size - 100..<size).map { UInt8($0 % 251) }), await source.requests == before else {
        throw POSIXError(.EIO)
    }
    print("Partial metadata pages and assembled 1 MiB payload with short EOF tail remain budgeted; reopened cross-block and EOF bytes exact with no transfer")
  }
}
