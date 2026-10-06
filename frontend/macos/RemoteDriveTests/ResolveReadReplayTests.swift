import Foundation

private struct MediaRead: Decodable { let offset: Int; let length: Int }

private actor ReplaySource {
  let root: URL
  var requests = 0
  var bytes = 0
  init(root: URL) { self.root = root }
  func read(_ node: GardenNode, offset: Int, length: Int) async throws -> Data {
    requests += 1
    bytes += length
    try await Task.sleep(for: .milliseconds(20))
    return try Self.local(root.appendingPathComponent(node.name), offset: offset, length: length)
  }
  static func local(_ path: URL, offset: Int, length: Int) throws -> Data {
    let file = try FileHandle(forReadingFrom: path)
    defer { try? file.close() }
    try file.seek(toOffset: UInt64(offset))
    guard let bytes = try file.read(upToCount: length), bytes.count == length else { throw POSIXError(.EIO) }
    return bytes
  }
}

@main struct ResolveReadReplayTests {
  static func main() async throws {
    setbuf(stdout, nil)
    let arguments = CommandLine.arguments
    guard arguments.count == 3 || arguments.count == 5 else { throw POSIXError(.EINVAL) }
    let pattern = try JSONDecoder().decode([String: [MediaRead]].self,
      from: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1])))
    let media = URL(fileURLWithPath: CommandLine.arguments[2])
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-replay-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let source = ReplaySource(root: media)
    let network = arguments.count == 5
    let domain = network ? arguments[3] : "replay-\(UUID())"
    let api = GardenAPI(domainID: domain)
    var remote: [GardenNode] = []
    if network {
      guard let parent = Int(arguments[4]) else { throw POSIXError(.EINVAL) }
      var cursor = 0
      while true {
        let page = try await api.list(parentID: parent, after: cursor)
        remote.append(contentsOf: page)
        if page.count < 256 { break }
        guard let next = page.last?.id, next > cursor else { throw GardenAPIError.invalidResponse }
        cursor = next
      }
    }
    let fetch: (@Sendable (GardenNode, Int, Int) async throws -> Data)?
    if network { fetch = nil }
    else { fetch = { node, offset, length in try await source.read(node, offset: offset, length: length) } }
    let cache = GardenRangeCache(api: api, domainID: domain,
      diskLimit: 1024 * 1024 * 1024, directory: root, readRange: fetch)
    let started = ContinuousClock.now
    try await withThrowingTaskGroup(of: Void.self) { group in
      for (index, name) in pattern.keys.sorted().enumerated() {
        let path = media.appendingPathComponent(name)
        let size = try path.resourceValues(forKeys: [.fileSizeKey]).fileSize!
        let node: GardenNode
        if network {
          guard let match = remote.first(where: { $0.name == name && !$0.folder }), match.size == size else {
            throw GardenAPIError.invalidResponse
          }
          node = match
        } else {
          node = try GardenNode(["id": index + 1, "parentId": 0, "name": name, "kind": "file",
            "size": size, "version": 1, "updatedAt": "2026-10-06T00:00:00.000Z", "deleted": false])
        }
        let reads = pattern[name]!
        group.addTask {
          for read in reads {
            let bytes = try await cache.read(node: node, offset: read.offset, length: read.length)
            guard bytes == (try ReplaySource.local(path, offset: read.offset, length: read.length)) else {
              throw POSIXError(.EIO)
            }
          }
        }
      }
      try await group.waitForAll()
    }
    await cache.invalidate()
    let bytes = await cache.remoteBytes
    print("Resolve trace: \(pattern.values.reduce(0) { $0 + $1.count }) exact reads passed in \(started.duration(to: .now)); \(bytes) remote bytes")
  }
}
