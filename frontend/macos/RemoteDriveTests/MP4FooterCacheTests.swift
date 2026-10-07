import Foundation

actor MP4FooterSource {
  let size = 100 * 1024 * 1024 + 50000
  let position = 16 * 1024 * 1024 + 16 * 1024
  private(set) var requests: [(Int, Int)] = []
  private let arrival = RemoteCompletion<Void>()

  private func integer(_ value: UInt64) -> Data {
    Data((0..<4).reversed().map { UInt8(truncatingIfNeeded: value >> ($0 * 8)) })
  }

  private func atom(_ type: String, _ payload: Data = Data()) -> Data {
    integer(UInt64(payload.count + 8)) + Data(type.utf8) + payload
  }

  func bytes(_ offset: Int, _ length: Int) -> Data {
    var result = Data((offset..<(offset + length)).map { UInt8($0 % 251) })
    let prefix = atom("ftyp", Data("isom".utf8)) + atom("moov") + atom("moof")
    var table = Data([0, 0, 0, 0]) + integer(1) + integer(0) + integer(1800)
    for index in 0..<1800 {
      table += integer(0) + integer(UInt64(position + index * 32768)) + Data([1, 1, 1])
    }
    let index = atom("tfra", table)
    let footer = atom("mfra", index + atom("mfro", integer(0) + integer(UInt64(index.count + 24))))
    for (start, data) in [(0, prefix), (size - footer.count, footer)] {
      let lower = max(offset, start)
      let upper = min(offset + length, start + data.count)
      if lower < upper {
        result.replaceSubrange((lower - offset)..<(upper - offset),
          with: data[(lower - start)..<(upper - start)])
      }
    }
    return result
  }

  func read(_ offset: Int, _ length: Int) async throws -> Data {
    requests.append((offset, length))
    if offset == position { arrival.resolve(.success(())) }
    try await Task.sleep(for: .milliseconds(30))
    return bytes(offset, length)
  }

  func waitForMetadata() async throws {
    let deadline = Task {
      try await Task.sleep(for: .seconds(5))
      arrival.resolve(.failure(URLError(.timedOut)))
    }
    defer { deadline.cancel() }
    try await arrival.wait()
  }
}

@main struct MP4FooterCacheTests {
  static func main() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-mp4-footer-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let source = MP4FooterSource()
    let size = await source.size
    let position = await source.position
    let node = try GardenNode(["id": 1, "parentId": 0, "name": "media.mp4", "kind": "file",
      "size": size, "version": 1, "updatedAt": "2026-10-07T00:00:00.000Z", "deleted": false])
    let cache = GardenRangeCache(api: GardenAPI(domainID: "mp4-footer"), domainID: "mp4-footer",
      diskLimit: 8 * 1024 * 1024, directory: root,
      readRange: { _, offset, length in try await source.read(offset, length) })
    _ = try await cache.read(node: node, offset: 0, length: 16384)
    try await source.waitForMetadata()
    let bytes = try await cache.read(node: node, offset: position, length: 32768)
    guard bytes == (await source.bytes(position, 32768)) else { throw POSIXError(.EIO) }
    await cache.invalidate()
    let requests = await source.requests
    let tail = (size - 1) / 65536 * 65536
    guard requests.contains(where: { $0.0 == tail && $0.1 == size - tail }),
      requests.filter({ $0.0 == position }).count == 1 else { throw POSIXError(.EIO) }
    print("MP4 footer spanning small pages discovers fragment positions and reuses paired metadata bytes")
  }
}
