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
    print("Credential store: signed Data Protection Keychain create, read, update and removal passed")
  }
}
