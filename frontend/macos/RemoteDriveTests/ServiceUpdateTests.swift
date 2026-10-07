import Foundation
import Darwin

@main struct ServiceUpdateTests {
  static func prepare(_ service: RemoteControlService) async throws {
    let result = RemoteCompletion<Data>()
    let payload = try JSONEncoder().encode(GardenRemoteRequest(accountID: ""))
    service.request("prepareUpdate", payload: payload) { data, message in
      if let message { result.resolve(.failure(NSError(domain: "ServiceUpdateTest", code: 1,
        userInfo: [NSLocalizedDescriptionKey: message]))) }
      else if let data { result.resolve(.success(data)) }
      else { result.resolve(.failure(POSIXError(.EIO))) }
    }
    let data = try await result.wait()
    guard try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) is NSNull else {
      throw POSIXError(.EIO)
    }
  }

  static func main() async throws {
    setbuf(stdout, nil)
    guard CommandLine.arguments.count == 2 else { throw POSIXError(.EINVAL) }
    let source = CommandLine.arguments[1]
    let original = try FinderCredentialStore.read(source)
    let api = GardenAPI(domainID: source)
    let account = UUID().uuidString.lowercased()
    let registration = RemoteRegistration(accountID: account, driveID: original.driveID, name: "Service Update Test")
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-service-update-\(account)")
    let cache = root.appendingPathComponent("cache")
    let manager = try RemoteManager(root: root, cache: cache)
    let service = RemoteControlService(manager: manager, cache: GardenDiskCache(directory: cache))
    let folder = try await api.create(parentID: 0, name: "service-update-test-\(account)", folder: true)
    var descriptor: Int32 = -1
    do {
      let node = try await api.create(parentID: folder.id, name: "Pending.bin", folder: false)
      let latest = try FinderCredentialStore.read(source)
      let credential = FinderCredential(serverURL: latest.serverURL, accountID: account,
        driveID: latest.driveID, tokenID: latest.tokenID, token: latest.token, refreshToken: latest.refreshToken)
      try await manager.register(registration, credential: credential)
      let bytes = Data((0..<131_071).map { UInt8($0 % 251) })
      let path = URL(fileURLWithPath: registration.mountPath).appendingPathComponent(folder.name).appendingPathComponent(node.name).path
      descriptor = open(path, O_WRONLY)
      guard descriptor >= 0 else { throw POSIXError(.EIO) }
      guard bytes.withUnsafeBytes({ write(descriptor, $0.baseAddress, $0.count) }) == bytes.count else { throw POSIXError(.EIO) }
      let journal = try RemoteWriteJournal(url: root.appendingPathComponent(registration.domainID).appendingPathComponent("writes.sqlite"),
        namespace: registration.domainID, limit: 256 * 1024 * 1024)
      guard try journal.pending().contains(where: { $0.base.id == node.id }) else { throw POSIXError(.EIO) }
      do { try await prepare(service); throw POSIXError(.EIO) }
      catch let error as NSError where error.domain == "ServiceUpdateTest" {
        print("Busy update response: \(error.localizedDescription)")
        print("Busy update status: \(try await manager.status(accountID: account, driveIDs: [credential.driveID]))")
        guard error.localizedDescription.contains("could not unmount"),
          try await manager.status(accountID: account, driveIDs: [credential.driveID])["enabled"] == [credential.driveID],
          FileManager.default.fileExists(atPath: registration.mountPath) else { throw POSIXError(.EIO) }
      }
      close(descriptor)
      descriptor = -1
      try await prepare(service)
      let committed = try await api.get(node.id)
      print("Committed size: \(committed.size); expected: \(bytes.count); mount present: \(FileManager.default.fileExists(atPath: registration.mountPath)); registrations: \(try RemoteRegistry(root: root).read().count)")
      guard committed.size == bytes.count,
        try await api.read(id: committed.id, version: committed.version, offset: 0, length: bytes.count) == bytes,
        try journal.pending().isEmpty,
        !FileManager.default.fileExists(atPath: registration.mountPath),
        try RemoteRegistry(root: root).read() == [registration] else { throw POSIXError(.EIO) }
      try await api.delete(folder.id)
      try FinderCredentialStore.remove(registration.domainID)
      try FileManager.default.removeItem(at: root)
      print("Service update: pending writes published exactly, busy mount rejects update, retry unmounts, registry retained")
    } catch {
      if descriptor >= 0 { close(descriptor) }
      do { try await manager.shutdown() }
      catch { RemoteLog.error(error); throw error }
      try await api.delete(folder.id)
      try FinderCredentialStore.remove(registration.domainID)
      try FileManager.default.removeItem(at: root)
      throw error
    }
  }
}
