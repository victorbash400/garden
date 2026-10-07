import Foundation
import CryptoKit

@main struct ArtifactRoundtripTests {
  static func seconds(_ duration: Duration) -> Double {
    let value = duration.components
    return Double(value.seconds) + Double(value.attoseconds) / 1_000_000_000_000_000_000
  }

  static func main() async throws {
    setbuf(stdout, nil)
    let args = CommandLine.arguments
    guard args.count == 5, let nodeID = Int(args[2]) else { throw POSIXError(.EINVAL) }
    let api = GardenAPI(domainID: args[1])
    let credential = try await api.streamCredential()
    let mount = URL(fileURLWithPath: args[3]).standardizedFileURL
    let prefix = "/Volumes/Garden-\(credential.accountID)-\(credential.driveID)/"
    guard mount.path.hasPrefix(prefix) else { throw POSIXError(.EINVAL) }
    let node = try await api.get(nodeID)
    guard !node.folder, node.name == mount.lastPathComponent, node.size > 0,
      node.size <= 128 * 1024 * 1024 else { throw POSIXError(.EINVAL) }
    let began = ContinuousClock.now
    let cloud: Data
    if node.size <= 256 * 1024 {
      cloud = try await api.read(id: node.id, version: node.version, offset: 0, length: node.size)
    } else {
      let ticket = try await api.download(id: node.id, version: node.version)
      guard ticket.size == node.size, let url = ticket.url else { throw GardenAPIError.invalidResponse }
      let settings = URLSessionConfiguration.ephemeral
      settings.urlCache = nil
      settings.timeoutIntervalForRequest = 30
      settings.timeoutIntervalForResource = 180
      let session = URLSession(configuration: settings)
      defer { session.invalidateAndCancel() }
      let (bytes, response) = try await session.data(from: url)
      guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw GardenAPIError.invalidResponse }
      cloud = bytes
    }
    guard cloud.count == node.size else { throw POSIXError(.EIO) }
    let downloadSeconds = seconds(began.duration(to: .now))
    print("Cloud artifact downloaded: \(node.size) bytes in \(downloadSeconds) seconds")
    let mountedBegan = ContinuousClock.now
    let mounted = try Data(contentsOf: mount)
    guard mounted == cloud else { throw POSIXError(.EIO) }
    let mountedSeconds = seconds(mountedBegan.duration(to: .now))
    try cloud.write(to: URL(fileURLWithPath: args[4]))
    let receipt: [String: Any] = ["node": node.id, "version": node.version, "bytes": node.size,
      "sha256": SHA256.hash(data: cloud).map { String(format: "%02x", $0) }.joined(),
      "cloudDownloadSeconds": downloadSeconds, "mountedReadSeconds": mountedSeconds, "exactMatch": true]
    let data = try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys])
    print(String(decoding: data, as: UTF8.self))
  }
}
