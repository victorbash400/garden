import Darwin
import Foundation

@main struct LiveSharingTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "GardenSharingTest", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func credential(_ source: FinderCredential, drive: Int) -> FinderCredential {
    FinderCredential(serverURL: source.serverURL, accountID: source.accountID, driveID: drive,
      tokenID: source.tokenID, token: source.token, refreshToken: source.refreshToken)
  }

  static func main() async throws {
    setbuf(stdout, nil)
    guard CommandLine.arguments.count == 3 || CommandLine.arguments.count == 4 else { throw POSIXError(.EINVAL) }
    var ownerSource = try FinderCredentialStore.read(CommandLine.arguments[1])
    var recipientSource = try FinderCredentialStore.read(CommandLine.arguments[2])
    try require(ownerSource.accountID != recipientSource.accountID, "The test requires two different accounts")
    let ownerOriginal = GardenAPI(domainID: CommandLine.arguments[1])
    let recipientOriginal = GardenAPI(domainID: CommandLine.arguments[2])
    if CommandLine.arguments.count == 4, let abandoned = Int(CommandLine.arguments[3]) {
      guard let drives = try await ownerOriginal.call("garden", "list", [:]) as? [[String: Any]],
        let fixture = drives.first(where: { $0["id"] as? Int == abandoned }),
        let name = fixture["name"] as? String, name.hasPrefix("sharing-test-") else { throw POSIXError(.EINVAL) }
      _ = try await ownerOriginal.call("garden", "delete", ["gardenId": abandoned])
      try FinderCredentialStore.remove("account-\(ownerSource.accountID)-drive-\(abandoned)")
      try FinderCredentialStore.remove("account-\(recipientSource.accountID)-drive-\(abandoned)")
      print("Abandoned sharing fixture \(abandoned) removed")
      return
    }
    let identity = try await recipientOriginal.object(recipientOriginal.call("garden", "account", [:]))
    guard let email = identity["email"] as? String else { throw GardenAPIError.invalidResponse }
    let drive = try await ownerOriginal.object(ownerOriginal.call("garden", "create", ["name": "sharing-test-\(UUID())"]))
    guard let driveID = drive["id"] as? Int else { throw GardenAPIError.invalidResponse }
    ownerSource = try FinderCredentialStore.read(CommandLine.arguments[1])
    recipientSource = try FinderCredentialStore.read(CommandLine.arguments[2])
    let ownerDomain = "account-\(ownerSource.accountID)-drive-\(driveID)"
    let recipientDomain = "account-\(recipientSource.accountID)-drive-\(driveID)"
    try FinderCredentialStore.save(credential(ownerSource, drive: driveID), domainID: ownerDomain)
    try FinderCredentialStore.save(credential(recipientSource, drive: driveID), domainID: recipientDomain)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-live-sharing-\(UUID())")
    let owner = try RemoteEngine(domainID: ownerDomain, state: root.appendingPathComponent("owner"), cache: root.appendingPathComponent("cache"), limit: 0)
    let recipient = try RemoteEngine(domainID: recipientDomain, state: root.appendingPathComponent("recipient"), cache: root.appendingPathComponent("cache"), limit: 0)
    var mounted: RemoteMount?
    var loop: Task<Void, Error>?
    do {
      let invitation = try await owner.api.object(owner.api.call("driveInvitations", "invite", ["gardenId": driveID, "email": email, "role": "Editor"]))
      guard let invitationID = invitation["id"] as? Int else { throw GardenAPIError.invalidResponse }
      _ = try await recipient.api.call("driveInvitations", "accept", ["invitationId": invitationID])
      let file = try await owner.api.create(parentID: 0, name: "Shared.txt", folder: false)
      try await owner.prepare()
      try await recipient.prepare()
      let handle = try await recipient.open("/Shared.txt", directory: false)
      var bytes = Data("Written by the invited account".utf8)
      try await recipient.write(handle, offset: 0, bytes: bytes, append: false)
      try await recipient.flush(handle)
      try await recipient.close(handle)
      let committed = try await owner.api.get(file.id)
      try require(try await owner.api.read(id: file.id, version: committed.version, offset: 0, length: bytes.count) == bytes, "The other account must read the exact saved bytes")
      guard let versions = try await owner.api.call("content", "versions", ["nodeId": file.id]) as? [[String: Any]] else { throw GardenAPIError.invalidResponse }
      try require(versions.contains { $0["id"] as? Int == committed.version && $0["authorId"] as? String == recipientSource.accountID }, "Edits must be attributed only to the writing account")
      print("Hosted sharing: invitation accepted, exact cloud bytes and recipient-only edit attribution passed")
      try await owner.catchUp()
      try await recipient.catchUp()
      let ownerHandle = try await owner.open("/Shared.txt", directory: false)
      let recipientHandle = try await recipient.open("/Shared.txt", directory: false)
      let ownerEdit = Data("Owner's concurrent edit".utf8)
      let recipientEdit = Data("Recipient's concurrent edit".utf8)
      try await owner.write(ownerHandle, offset: 0, bytes: ownerEdit, append: false)
      await owner.scheduledPublications[file.id]?.cancel()
      try await owner.truncate("/Shared.txt", handle: ownerHandle, size: ownerEdit.count)
      await owner.scheduledPublications[file.id]?.cancel()
      try await recipient.write(recipientHandle, offset: 0, bytes: recipientEdit, append: false)
      await recipient.scheduledPublications[file.id]?.cancel()
      try await recipient.truncate("/Shared.txt", handle: recipientHandle, size: recipientEdit.count)
      await recipient.scheduledPublications[file.id]?.cancel()
      try await owner.flush(ownerHandle)
      do {
        try await recipient.flush(recipientHandle)
        throw POSIXError(.EIO)
      } catch let error as NSError {
        try require(error.domain == "GardenWriteConflict", "The second editor must receive a visible conflict")
      }
      let children = try await owner.api.list(parentID: 0, after: 0)
      guard let original = children.first(where: { $0.id == file.id }),
        let conflict = children.first(where: { $0.id != file.id }) else { throw GardenAPIError.invalidResponse }
      try require(try await owner.api.read(id: original.id, version: original.version, offset: 0, length: ownerEdit.count) == ownerEdit,
        "The original must preserve the owner's exact concurrent edit")
      try require(try await owner.api.read(id: conflict.id, version: conflict.version, offset: 0, length: recipientEdit.count) == recipientEdit,
        "The conflict copy must preserve the recipient's exact concurrent edit")
      guard let conflictVersions = try await owner.api.call("content", "versions", ["nodeId": conflict.id]) as? [[String: Any]] else { throw GardenAPIError.invalidResponse }
      try require(conflictVersions.contains { $0["authorId"] as? String == recipientSource.accountID },
        "The conflict copy must be attributed to the account that wrote it")
      try await owner.close(ownerHandle)
      try await recipient.close(recipientHandle)
      bytes = ownerEdit
      print("Hosted two-account conflict: both exact edits preserved, visible conflict and separate authorship passed")
      let pendingFile = try await owner.api.create(parentID: 0, name: "Pending.txt", folder: false)
      try await recipient.catchUp()
      let pendingHandle = try await recipient.open("/Pending.txt", directory: false)
      let pendingBytes = Data("Accepted before access changed".utf8)
      try await recipient.write(pendingHandle, offset: 0, bytes: pendingBytes, append: false)
      await recipient.scheduledPublications[pendingFile.id]?.cancel()
      let downgraded = RemoteCompletion<Void>()
      await recipient.setInvalidation({ _ in
        Task {
          do { try await recipient.requireWrite() }
          catch let error as POSIXError where error.code == .EROFS { downgraded.resolve(.success(())) }
          catch { }
        }
      }, settled: {})
      _ = try await owner.api.call("driveMembers", "changeRole", ["gardenId": driveID, "userId": recipientSource.accountID, "role": "Viewer"])
      let deadline = Task {
        do { try await Task.sleep(for: .seconds(20)) }
        catch { return }
        downgraded.resolve(.failure(POSIXError(.ETIMEDOUT)))
      }
      do { try await downgraded.wait() }
      catch { deadline.cancel(); throw error }
      deadline.cancel()
      print("Hosted permission stream: active engine received Viewer downgrade without manual refresh")
      do { try await recipient.flush(pendingHandle); throw POSIXError(.EIO) }
      catch let error as POSIXError { try require(error.code == .EROFS, "Downgrade must deny publication of an open edit") }
      try require(try await owner.api.get(pendingFile.id).size == 0, "Downgrade must leave the cloud version unchanged")
      let pendingExtents = try await recipient.writes.extents(pendingFile.id, offset: 0, length: pendingBytes.count)
      try require(pendingExtents.count == 1 && pendingExtents[0].bytes == pendingBytes, "Downgrade must preserve every accepted local byte")
      print("Hosted open-edit downgrade: publication denied, cloud unchanged and exact pending bytes retained")
      let mountPath = "/Volumes/GardenSharingTest-\(UUID())"
      let mount = try await RemoteMount.start(engine: recipient, path: mountPath, name: "Garden Sharing Test")
      mounted = mount
      let running = Task { try await mount.run() }
      loop = running
      let path = mountPath + "/Shared.txt"
      var info = stat()
      try require(stat(path, &info) == 0 && info.st_size == bytes.count && info.st_blocks == 0, "The hosted file must report logical size and zero payload blocks")
      let descriptor = open(path, O_WRONLY)
      if descriptor >= 0 { close(descriptor); throw POSIXError(.EIO) }
      try require(errno == EROFS || errno == EACCES, "Viewer write-open must be denied")
      try require(try Data(contentsOf: URL(fileURLWithPath: path)) == bytes, "Viewer mounted reads must match cloud bytes")
      _ = try await owner.api.call("driveMembers", "remove", ["gardenId": driveID, "userId": recipientSource.accountID])
      try require(try await recipient.checkWithdrawal(), "Hosted removal must withdraw access")
      do { _ = try await recipient.lookup("/Shared.txt"); throw POSIXError(.EIO) }
      catch let error as POSIXError { try require(error.code == .EACCES, "Removed account cannot use cached metadata") }
      let retainedExtents = try await recipient.writes.extents(pendingFile.id, offset: 0, length: pendingBytes.count)
      try require(retainedExtents.count == 1 && retainedExtents[0].bytes == pendingBytes, "Removal must retain the unpublished edit privately")
      try await mount.unmount(preserveWrites: true)
      try await running.value
      mounted = nil
      loop = nil
      await owner.stop()
      await recipient.stop()
      _ = try await owner.api.call("garden", "delete", ["gardenId": driveID])
      try FinderCredentialStore.remove(ownerDomain)
      try FinderCredentialStore.remove(recipientDomain)
      try FileManager.default.removeItem(at: root)
      print("Hosted mounted sharing: Viewer write denial, exact read, zero blocks, removal and cached-access denial passed; fixture removed")
    } catch {
      mounted?.stop()
      if let loop { _ = try? await loop.value }
      await owner.stop()
      await recipient.stop()
      print("Retained test drive \(driveID) and state \(root.path) for diagnosis")
      throw error
    }
  }
}
