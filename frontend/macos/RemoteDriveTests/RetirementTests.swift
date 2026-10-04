import Foundation
import Security

@main struct RetirementTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RetirementTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-retirement-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let account = UUID().uuidString.lowercased()
    let other = UUID().uuidString.lowercased()
    let registrations = [RemoteRegistration(accountID: account, driveID: 1, name: "Removed"),
      RemoteRegistration(accountID: account, driveID: 2, name: "Kept"),
      RemoteRegistration(accountID: other, driveID: 1, name: "Other account")]
    let registry = try RemoteRegistry(root: root)
    try registry.save(registrations)
    for registration in registrations {
      try FinderCredentialStore.save(FinderCredential(serverURL: "https://unused.invalid/", accountID: registration.accountID,
        driveID: registration.driveID, tokenID: registration.domainID, token: "test", refreshToken: "test"),
        domainID: registration.domainID)
    }
    defer { for registration in registrations { try? FinderCredentialStore.remove(registration.domainID) } }
    let manager = try RemoteManager(root: root, cache: root.appendingPathComponent("cache"))
    let tokens = try await manager.prepareRemoval(accountID: account, keeping: [2])
    try require(tokens == [registrations[0].domainID], "Preparation must return only this account's removed drive token")
    let retained = try registry.read()
    try require(retained.first { $0.domainID == registrations[0].domainID }?.retiring == true,
      "Retirement must persist before credentials are revoked")
    try require(retained.filter { $0.retiring == true }.count == 1,
      "Kept drives and other accounts must remain unchanged")
    try require(try FinderCredentialStore.read(registrations[0].domainID).tokenID == tokens[0],
      "A failed cloud revocation must leave credentials available for retry")
    try require(try await manager.prepareRemoval(accountID: account, keeping: [2]) == tokens,
      "Preparation replay must return the same retained token")
    try await manager.reconcile(accountID: account, driveIDs: [2])
    try require(try registry.read().count == 2, "Finalization must remove only the prepared registration")
    do { _ = try FinderCredentialStore.read(registrations[0].domainID); throw POSIXError(.EIO) }
    catch FinderCredentialError.keychain(let code) { try require(code == errSecItemNotFound, "Finalization must remove the credential") }

    let pendingRoot = root.appendingPathComponent("pending")
    let pendingRegistry = try RemoteRegistry(root: pendingRoot)
    try pendingRegistry.save([registrations[0]])
    let url = pendingRoot.appendingPathComponent(registrations[0].domainID).appendingPathComponent("writes.sqlite")
    let journal = try RemoteWriteJournal(url: url, namespace: registrations[0].domainID, limit: 256 * 1024 * 1024)
    let node = try GardenNode(["id": 1, "parentId": 0, "name": "Pending.bin", "kind": "file", "size": 0,
      "version": 0, "updatedAt": "2026-10-04T12:00:00.000Z", "deleted": false])
    try journal.write(node, offset: 0, bytes: Data([1, 2, 3, 4]))
    let pending = try RemoteManager(root: pendingRoot, cache: root.appendingPathComponent("pending-cache"))
    do { _ = try await pending.prepareRemoval(accountID: account, keeping: []); throw POSIXError(.EIO) }
    catch FinderCredentialError.keychain(let code) { try require(code == errSecItemNotFound, "Failed publication must reject preparation") }
    try require(try journal.used == 4 && pendingRegistry.read().first?.retiring == true,
      "Rejected preparation must retain every accepted byte and the registration")
    do { try await pending.reconcile(accountID: account, driveIDs: []); throw POSIXError(.EIO) }
    catch let error as POSIXError { try require(error.code == .EBUSY, "Finalization must reject unresolved writes") }
    let restarted = try RemoteManager(root: pendingRoot, cache: root.appendingPathComponent("pending-cache"))
    await restarted.restore()
    try require(try journal.used == 4, "Restart must not remount a retiring drive or discard pending edits")

    let interrupted = root.appendingPathComponent("interrupted")
    let interruptedRegistry = try RemoteRegistry(root: interrupted)
    var retiring = registrations[0]
    retiring.retiring = true
    try interruptedRegistry.save([retiring])
    let recovery = try RemoteManager(root: interrupted, cache: root.appendingPathComponent("interrupted-cache"))
    try require(try await recovery.prepareRemoval(accountID: account, keeping: []).isEmpty,
      "Credential deletion with an interrupted registry commit must be replayable")
    try await recovery.reconcile(accountID: account, driveIDs: [])
    try require(try interruptedRegistry.read().isEmpty, "Interrupted finalization must complete on retry")
    print("Retirement: account isolation, retained credentials, replay, publication failure retention, pending-write refusal and interrupted finalization passed")
  }
}
