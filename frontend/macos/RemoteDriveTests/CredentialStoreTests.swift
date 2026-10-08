import Foundation
import Security

@main struct CredentialStoreTests {
  static func main() throws {
    let domain = "garden-credential-test-\(UUID())"
    let first = FinderCredential(serverURL: "https://unused.invalid/", accountID: UUID().uuidString,
      driveID: 1, tokenID: UUID().uuidString, token: "test-token", refreshToken: "test-refresh")
    do {
      _ = try FinderCredentialStore.read(domain)
      throw NSError(domain: "CredentialStoreTests", code: 1)
    } catch FinderCredentialError.keychain(errSecItemNotFound) {}
    try FinderCredentialStore.save(first, domainID: domain)
    defer { try? FinderCredentialStore.remove(domain) }
    let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("GardenRemote/Connections", isDirectory: true)
    let filename = domain.utf8.map { String(format: "%02x", $0) }.joined() + ".json"
    let file = root.appendingPathComponent(filename)
    let directoryAttributes = try FileManager.default.attributesOfItem(atPath: root.path)
    let fileAttributes = try FileManager.default.attributesOfItem(atPath: file.path)
    guard directoryAttributes[.posixPermissions] as? Int == 0o700,
      fileAttributes[.posixPermissions] as? Int == 0o600 else { throw POSIXError(.EACCES) }
    let saved = try FinderCredentialStore.read(domain)
    guard saved.token == first.token, saved.accountID == first.accountID else {
      throw NSError(domain: "CredentialStoreTests", code: 2)
    }
    var updated = first
    updated.token = "updated-test-token"
    try FinderCredentialStore.save(updated, domainID: domain)
    guard try FinderCredentialStore.read(domain).token == updated.token else {
      throw NSError(domain: "CredentialStoreTests", code: 3)
    }
    try FinderCredentialStore.remove(domain)
    do {
      _ = try FinderCredentialStore.read(domain)
      throw NSError(domain: "CredentialStoreTests", code: 4)
    } catch FinderCredentialError.keychain(errSecItemNotFound) {}
    try Data("invalid".utf8).write(to: file, options: .atomic)
    do {
      _ = try FinderCredentialStore.read(domain)
      throw POSIXError(.EIO)
    } catch is DecodingError {}
    try FinderCredentialStore.remove(domain)
    do {
      try FinderCredentialStore.save(first, domainID: String(repeating: "x", count: 121))
      throw POSIXError(.EIO)
    } catch let error as POSIXError where error.code == .EINVAL {}
    print("Credential store: permissions, create, read, update, removal and corrupt-data rejection passed")
  }
}
