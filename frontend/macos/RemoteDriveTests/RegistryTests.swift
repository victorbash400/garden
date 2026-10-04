import Foundation

@main struct RegistryTests {
  static func main() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-registry-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let registry = try RemoteRegistry(root: root)
    let account = UUID().uuidString.lowercased()
    let other = UUID().uuidString.lowercased()
    let records = [RemoteRegistration(accountID: account, driveID: 1, name: "A, B"),
      RemoteRegistration(accountID: other, driveID: 1, name: "A, B")]
    try registry.save(records)
    let reopened = try RemoteRegistry(root: root)
    guard Set(try reopened.read().map(\.domainID)) == Set(records.map(\.domainID)),
      records[0].mountPath != records[1].mountPath else { throw POSIXError(.EINVAL) }
    let permissions = try FileManager.default.attributesOfItem(atPath: root.appendingPathComponent("drives.json").path)
    guard permissions[.posixPermissions] as? Int == 0o600 else { throw POSIXError(.EACCES) }
    do {
      try registry.save([records[0], records[0]])
      throw POSIXError(.EIO)
    } catch let error as POSIXError { guard error.code == .EINVAL else { throw error } }
    guard try reopened.read().count == 2 else { throw POSIXError(.EIO) }
    do {
      try registry.save([RemoteRegistration(accountID: "../invalid", driveID: 1, name: "X")])
      throw POSIXError(.EIO)
    } catch let error as POSIXError { guard error.code == .EINVAL else { throw error } }
    try Data("invalid registry".utf8).write(to: root.appendingPathComponent("drives.json"))
    do { _ = try reopened.read(); throw POSIXError(.EIO) }
    catch is DecodingError {}
    print("Mount registry: restart, account isolation, private storage, invalid identity, and corrupt state passed")
  }
}
