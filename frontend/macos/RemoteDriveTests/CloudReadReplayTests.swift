import CryptoKit
import Foundation

private struct CloudMediaRead: Decodable {
  let offset: Int
  let length: Int
}

private struct CloudReplayReceipt: Encodable {
  let name: String
  let node: Int
  let version: Int
  let size: Int
  let reads: Int
  let bytes: Int
  let sha256: String
}

@main struct CloudReadReplayTests {
  static func main() async {
    setbuf(stdout, nil)
    do { try await run() }
    catch { print("Cloud replay failed: \(error.localizedDescription)"); exit(1) }
  }

  static func run() async throws {
    let arguments = CommandLine.arguments
    guard arguments.count == 4, let parent = Int(arguments[3]) else { throw POSIXError(.EINVAL) }
    let pattern = try JSONDecoder().decode([String: [CloudMediaRead]].self,
      from: Data(contentsOf: URL(fileURLWithPath: arguments[1])))
    let temporary = FileManager.default.temporaryDirectory
    let available = try temporary.resourceValues(forKeys: [.volumeAvailableCapacityKey]).volumeAvailableCapacity
    guard let available, available >= 2 * 1024 * 1024 * 1024 else { throw POSIXError(.ENOSPC) }
    let root = temporary.appendingPathComponent("garden-cloud-replay-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let api = GardenAPI(domainID: arguments[2])
    var nodes: [GardenNode] = []
    var cursor = 0
    while true {
      let page = try await api.list(parentID: parent, after: cursor)
      nodes.append(contentsOf: page)
      if page.count < 256 { break }
      guard let next = page.last?.id, next > cursor else { throw GardenAPIError.invalidResponse }
      cursor = next
    }
    let cache = GardenRangeCache(api: api, domainID: arguments[2], diskLimit: 512 * 1024 * 1024, directory: root)
    let started = ContinuousClock.now
    let receipts: [CloudReplayReceipt]
    do {
      receipts = try await withThrowingTaskGroup(of: CloudReplayReceipt.self) { group in
        for name in pattern.keys.sorted() {
          guard let node = nodes.first(where: { $0.name == name && !$0.folder }), let reads = pattern[name] else {
            throw GardenAPIError.invalidResponse
          }
          group.addTask {
            var digest = SHA256()
            var count = 0
            for read in reads {
              guard read.offset >= 0, read.offset <= node.size, read.length >= 0 else { throw POSIXError(.EINVAL) }
              let bytes = try await cache.read(node: node, offset: read.offset, length: read.length)
              guard bytes.count == min(read.length, node.size - read.offset) else { throw GardenAPIError.invalidResponse }
              digest.update(data: bytes)
              count += bytes.count
            }
            return CloudReplayReceipt(name: name, node: node.id, version: node.version, size: node.size,
              reads: reads.count, bytes: count, sha256: digest.finalize().map { String(format: "%02x", $0) }.joined())
          }
        }
        var completed: [CloudReplayReceipt] = []
        for try await receipt in group { completed.append(receipt) }
        return completed.sorted { $0.name < $1.name }
      }
    } catch {
      await cache.invalidate()
      throw error
    }
    await cache.invalidate()
    let encoded = try JSONEncoder().encode(receipts)
    print(String(decoding: encoded, as: UTF8.self))
    print("Cloud trace: \(receipts.reduce(0) { $0 + $1.reads }) reads in \(started.duration(to: .now)); \(await cache.remoteBytes) remote bytes")
  }
}
