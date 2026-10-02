import FileProvider
import Foundation
import Security
import AppKit

enum FinderDomainManager {
  static func identifier(accountID: String, driveID: Int) -> String {
    "account-\(accountID)-drive-\(driveID)"
  }

  static func missing(accountID: String, driveIDs: [Int]) async throws -> [Int] {
    let current = try await domains()
    let registered = Set(current.map { $0.identifier.rawValue })
    var missing: [Int] = []
    for id in driveIDs {
      let name = identifier(accountID: accountID, driveID: id)
      if !registered.contains(name) {
        missing.append(id)
        continue
      }
      do {
        _ = try FinderCredentialStore.read(name)
      } catch FinderCredentialError.keychain(errSecItemNotFound) {
        missing.append(id)
      }
    }
    return missing
  }

  static func register(
    accountID: String,
    driveID: Int,
    name: String,
    credential: FinderCredential
  ) async throws {
    let id = identifier(accountID: accountID, driveID: driveID)
    guard credential.accountID == accountID, credential.driveID == driveID else {
      throw FinderBridgeError.invalidArguments
    }
    try FinderCredentialStore.save(credential, domainID: id)
    if try await domains().contains(where: { $0.identifier.rawValue == id }) {
      return
    }
    let domain = NSFileProviderDomain(
      identifier: NSFileProviderDomainIdentifier(id), displayName: name
    )
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      NSFileProviderManager.add(domain) { error in
        if let error { continuation.resume(throwing: error) }
        else { continuation.resume() }
      }
    }
  }

  static func reconcile(accountID: String, driveIDs: [Int]) async throws {
    let valid = Set(driveIDs.map { identifier(accountID: accountID, driveID: $0) })
    let prefix = "account-\(accountID)-drive-"
    for domain in try await domains() {
      let id = domain.identifier.rawValue
      if id.hasPrefix(prefix) && !valid.contains(id) {
        try await remove(domain)
      }
    }
  }

  static func signOut(accountID: String) async throws {
    let prefix = "account-\(accountID)-drive-"
    for domain in try await domains() where domain.identifier.rawValue.hasPrefix(prefix) {
      try await remove(domain)
    }
  }

  static func tokenIDs(accountID: String) async throws -> [String] {
    let prefix = "account-\(accountID)-drive-"
    var ids: [String] = []
    for domain in try await domains() where domain.identifier.rawValue.hasPrefix(prefix) {
      do {
        ids.append(try FinderCredentialStore.read(domain.identifier.rawValue).tokenID)
      } catch FinderCredentialError.keychain(errSecItemNotFound) {
        continue
      }
    }
    return ids
  }

  static func enabled(accountID: String, driveIDs: [Int]) async throws -> [Int] {
    let current = try await domains()
    return driveIDs.filter { driveID in
      current.contains { domain in
        domain.identifier.rawValue == identifier(accountID: accountID, driveID: driveID)
          && domain.userEnabled && !domain.isDisconnected
      }
    }
  }

  static func open(accountID: String, driveID: Int) async throws {
    let id = identifier(accountID: accountID, driveID: driveID)
    guard let domain = try await domains().first(where: { $0.identifier.rawValue == id }),
          let manager = NSFileProviderManager(for: domain) else {
      throw FinderBridgeError.domainMissing
    }
    let url = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
      manager.getUserVisibleURL(for: .rootContainer) { url, error in
        if let error { continuation.resume(throwing: error) }
        else if let url { continuation.resume(returning: url) }
        else { continuation.resume(throwing: FinderBridgeError.domainMissing) }
      }
    }
    guard NSWorkspace.shared.open(url) else { throw FinderBridgeError.cannotOpen }
  }

  static func openSettings() throws {
    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.systempreferences"),
          NSWorkspace.shared.open(url) else {
      throw FinderBridgeError.cannotOpenSettings
    }
  }

  static func signal(accountID: String, driveID: Int, parentIDs: [Int]) async throws {
    let id = identifier(accountID: accountID, driveID: driveID)
    guard let domain = try await domains().first(where: { $0.identifier.rawValue == id }),
          let manager = NSFileProviderManager(for: domain) else {
      throw FinderBridgeError.domainMissing
    }
    let identifiers = Set(parentIDs.map { $0 == 0
      ? NSFileProviderItemIdentifier.rootContainer
      : NSFileProviderItemIdentifier(String($0))
    }).union([.workingSet])
    for identifier in identifiers {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        manager.signalEnumerator(for: identifier) { error in
          if let error { continuation.resume(throwing: error) }
          else { continuation.resume() }
        }
      }
    }
  }

  private static func remove(_ domain: NSFileProviderDomain) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      NSFileProviderManager.remove(domain, mode: .preserveDirtyUserData) { _, error in
        if let error { continuation.resume(throwing: error) }
        else { continuation.resume() }
      }
    }
    try FinderCredentialStore.remove(domain.identifier.rawValue)
  }

  private static func domains() async throws -> [NSFileProviderDomain] {
    try await withCheckedThrowingContinuation { continuation in
      NSFileProviderManager.getDomainsWithCompletionHandler { domains, error in
        if let error { continuation.resume(throwing: error) }
        else { continuation.resume(returning: domains) }
      }
    }
  }
}
