import Foundation

actor MetadataPairSource {
  let position = 16 * 1024 * 1024 + 16 * 1024
  private(set) var requests: [(Int, Int)] = []
  private let arrival = RemoteCompletion<Void>()

  func bytes(_ offset: Int, _ length: Int) -> Data {
    var data = Data((offset..<(offset + length)).map { UInt8($0 % 251) })
    if offset == 0 {
      let value = position - 10
      let header: [UInt8] = [
        0x1a, 0x45, 0xdf, 0xa3, 0x80, 0x18, 0x53, 0x80, 0x67, 0xff,
        0x1c, 0x53, 0xbb, 0x6b, 0x8a, 0xbb, 0x88, 0xb7, 0x86, 0xf1, 0x84,
        UInt8(truncatingIfNeeded: value >> 24), UInt8(truncatingIfNeeded: value >> 16),
        UInt8(truncatingIfNeeded: value >> 8), UInt8(truncatingIfNeeded: value)
      ]
      data.replaceSubrange(0..<header.count, with: header)
    }
    return data
  }
  func read(_ offset: Int, _ length: Int) async throws -> Data {
    requests.append((offset, length))
    if offset == position { arrival.resolve(.success(())) }
    try await Task.sleep(for: .milliseconds(30))
    return bytes(offset, length)
  }
  func waitForPair() async throws {
    let deadline = Task {
      try await Task.sleep(for: .seconds(5))
      arrival.resolve(.failure(URLError(.timedOut)))
    }
    defer { deadline.cancel() }
    try await arrival.wait()
  }
}

@main struct MetadataPairTests {
  static func main() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-metadata-pair-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let source = MetadataPairSource()
    let node = try GardenNode(["id": 1, "parentId": 0, "name": "media.webm", "kind": "file", "size": 100 * 1024 * 1024,
      "version": 1, "updatedAt": "2026-10-07T00:00:00.000Z", "deleted": false])
    let cache = GardenRangeCache(api: GardenAPI(domainID: "metadata-pair"), domainID: "metadata-pair", diskLimit: 8 * 1024 * 1024,
      directory: root, readRange: { _, offset, length in try await source.read(offset, length) })
    _ = try await cache.read(node: node, offset: 0, length: 16384)
    try await source.waitForPair()
    let position = await source.position
    let bytes = try await cache.read(node: node, offset: position, length: 32768)
    guard bytes == (await source.bytes(position, 32768)) else { throw POSIXError(.EIO) }
    await cache.invalidate()
    let reads = await source.requests.filter { $0.0 >= position && $0.0 < position + 32768 }
    guard reads.count == 1, reads[0].0 == position, reads[0].1 == 32768 else { throw POSIXError(.EIO) }
    print("Odd-page metadata read-ahead fetched both pages in one request; demanded bytes matched; no adjacent demand transfer")
  }
}
