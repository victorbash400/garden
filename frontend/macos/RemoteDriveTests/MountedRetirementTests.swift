import Darwin
import Foundation
import Security

@main struct MountedRetirementTests {
  static func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw NSError(domain: "MountedRetirementTests", code: 1,
      userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async throws {
    guard CommandLine.arguments.count == 2 else { throw POSIXError(.EINVAL) }
    let account = CommandLine.arguments[1]
    let api = GardenAPI(domainID: "account-\(account)-drive-2")
    guard let created = try await api.call("garden", "create", ["name": "retirement-test-\(UUID())"]) as? [String: Any],
      let drive = created["id"] as? Int else { throw GardenAPIError.invalidResponse }
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-mounted-retirement-\(UUID())")
    let manager = try RemoteManager(root: root, cache: root.appendingPathComponent("cache"))
    let registration = RemoteRegistration(accountID: account, driveID: drive, name: "Retirement test")
    var file: Int32 = -1
    var directory: Int32 = -1
    do {
      guard let session = try await api.call("garden", "finderSession", ["gardenId": drive]) as? [String: Any],
        let token = session["token"] as? String, let refresh = session["refreshToken"] as? String,
        let tokenID = session["tokenId"] as? String else { throw GardenAPIError.invalidResponse }
      let credential = try await api.streamCredential()
      try await manager.register(registration, credential: FinderCredential(serverURL: credential.serverURL,
        accountID: account, driveID: drive, tokenID: tokenID, token: token, refreshToken: refresh))
      directory = open(registration.mountPath, O_RDONLY)
      file = open(registration.mountPath + "/Pending.bin", O_CREAT | O_RDWR, 0o600)
      try require(file >= 0 && directory >= 0, "Fixture descriptors must open")
      let bytes = Data((0..<(512 * 1024)).map { UInt8($0 % 251) })
      let count = bytes.withUnsafeBytes { pwrite(file, $0.baseAddress, $0.count, 0) }
      try require(count == bytes.count, "Every accepted byte must be written")
      do {
        _ = try await manager.prepareRemoval(accountID: account, keeping: [])
        throw NSError(domain: "MountedRetirementTests", code: 2,
          userInfo: [NSLocalizedDescriptionKey: "Busy drive must reject preparation"])
      } catch let error as NSError {
        try require(error.domain == "GardenRemoteUnmount", "Busy removal must reject native unmount")
      }
      let retained = try FinderCredentialStore.read(registration.domainID)
      try require(retained.tokenID == tokenID, "Busy removal must preserve its session")
      let remote = GardenAPI(domainID: registration.domainID)
      guard let node = try await remote.list(parentID: 0, after: 0).first(where: { $0.name == "Pending.bin" }) else {
        throw GardenAPIError.invalidResponse
      }
      try require(node.size == bytes.count && node.version != 0, "Preparation must publish the pending file")
      var published = Data()
      for offset in stride(from: 0, to: bytes.count, by: 256 * 1024) {
        published.append(try await remote.read(id: node.id, version: node.version, offset: offset,
          length: min(256 * 1024, bytes.count - offset)))
      }
      try require(published == bytes, "Cloud publication must contain every accepted byte")
      try require(close(file) == 0 && close(directory) == 0, "Descriptors must close")
      file = -1
      directory = -1
      let tokens = try await manager.prepareRemoval(accountID: account, keeping: [])
      try require(tokens == [tokenID], "Preparation must return only the isolated session")
      _ = try await api.call("garden", "revokeFinderSessions", ["tokenIds": tokens])
      try await manager.reconcile(accountID: account, driveIDs: [])
      try require(try RemoteRegistry(root: root).read().isEmpty, "Finalization must clear the registration")
      do { _ = try FinderCredentialStore.read(registration.domainID); throw POSIXError(.EIO) }
      catch FinderCredentialError.keychain(let code) {
        try require(code == errSecItemNotFound, "Finalization must remove the credential")
      }
      _ = try await api.call("garden", "delete", ["gardenId": drive])
      try FileManager.default.removeItem(at: root)
      print("Mounted retirement: busy refusal, pending cloud publication, exact bytes, isolated revocation and final removal passed")
    } catch {
      if file >= 0 { close(file) }
      if directory >= 0 { close(directory) }
      do { try await manager.shutdown() }
      catch { print("Fixture shutdown failed: \(error.localizedDescription)") }
      FileHandle.standardError.write(Data("Retained isolated fixture drive \(drive), state \(root.path)\n".utf8))
      throw error
    }
  }
}
