import Darwin
import Foundation

@main struct GardenManagedWriteTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }
  static func main() async throws {
    guard CommandLine.arguments.count == 2 else { throw POSIXError(.EINVAL) }
    let account = CommandLine.arguments[1]
    for drive in [1, 2] {
      let api = GardenAPI(domainID: "account-\(account)-drive-\(drive)")
      let name = "managed-write-test-\(UUID())"
      let path = "/Volumes/Garden-\(account)-\(drive)/" + name
      guard mkdir(path, 0o755) == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
      var fixture: Int?
      do {
        let file = URL(fileURLWithPath: path + "/Managed.bin")
        let bytes = Data((0..<2048).map { UInt8(($0 + drive) % 251) })
        try bytes.write(to: file, options: .atomic)
        var after = 0
        while fixture == nil {
          let roots = try await api.list(parentID: 0, after: after)
          fixture = roots.first { $0.name == name }?.id
          if fixture != nil || roots.count < 256 { break }
          guard let next = roots.last?.id, next > after else { throw GardenAPIError.invalidResponse }
          after = next
        }
        guard let fixture, let node = try await api.list(parentID: fixture, after: 0).first(where: { $0.name == "Managed.bin" }) else {
          throw GardenAPIError.invalidResponse
        }
        try require(node.size == bytes.count && node.version != 0, "Managed close must publish the complete cloud file")
        try require(try await api.read(id: node.id, version: node.version, offset: 0, length: bytes.count) == bytes,
          "Managed cloud bytes must match")
        var attributes = stat()
        try require(stat(file.path, &attributes) == 0 && attributes.st_size == bytes.count && attributes.st_blocks == 0,
          "Managed file must report its logical size with zero payload blocks")
        try require(unlink(file.path) == 0 && rmdir(path) == 0, "Managed fixture must clean up through the filesystem")
        print("Managed drive \(drive): atomic write, cloud confirmation, exact bytes, zero blocks and native cleanup passed")
      } catch {
        if let fixture { try await api.delete(fixture) }
        throw error
      }
    }
  }
}
