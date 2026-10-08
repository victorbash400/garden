import Foundation
import Security

private final class RemoteDriveEntry {
  var registration: RemoteRegistration
  var mount: RemoteMount?
  var starting: Task<RemoteMount, Error>?
  var issue: String?
  var removing = false
  init(_ registration: RemoteRegistration) { self.registration = registration }
}

actor RemoteManager {
  private let root: URL
  private let registry: RemoteRegistry
  private let cache: URL
  private var entries: [String: RemoteDriveEntry] = [:]
  private var stopping = false
  private struct Observer {
    let account: String
    let driveIDs: [Int]
    let continuation: AsyncThrowingStream<[String: [Int]], Error>.Continuation
  }
  private var observers: [UUID: Observer] = [:]

  func updates(accountID: String, driveIDs: [Int]) async throws -> AsyncThrowingStream<[String: [Int]], Error> {
    let current = try await status(accountID: accountID, driveIDs: driveIDs)
    let id = UUID()
    return AsyncThrowingStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
      observers[id] = Observer(account: accountID, driveIDs: driveIDs, continuation: continuation)
      continuation.yield(current)
      continuation.onTermination = { _ in Task { await self.removeObserver(id) } }
    }
  }

  private func removeObserver(_ id: UUID) { observers.removeValue(forKey: id) }

  func publish() async {
    for observer in Array(observers.values) {
      do { observer.continuation.yield(try await status(accountID: observer.account, driveIDs: observer.driveIDs)) }
      catch { observer.continuation.finish(throwing: error) }
    }
  }

  init(root: URL, cache: URL) throws {
    self.root = root
    self.cache = cache
    registry = try RemoteRegistry(root: root)
    for registration in try registry.read() { entries[registration.domainID] = RemoteDriveEntry(registration) }
  }

  func restore() async {
    let registrations = entries.values.map(\.registration)
    for registration in registrations {
      if registration.retiring == true { continue }
      do {
        if let existing = entries[registration.domainID]?.mount { try await existing.engine.reconnect() }
        else { _ = try await mount(registration.domainID) }
      }
      catch { RemoteLog.error(error) }
    }
  }

  func register(_ registration: RemoteRegistration, credential: FinderCredential) async throws {
    try registration.validate()
    guard !stopping, credential.accountID == registration.accountID,
      credential.driveID == registration.driveID else { throw POSIXError(.EINVAL) }
    let id = registration.domainID
    if let entry = entries[id] {
      if entry.removing { throw POSIXError(.EBUSY) }
      if entry.registration.retiring == true {
        try await resumeRetirement(entry, registration: registration, credential: credential)
      } else if entry.registration != registration { throw POSIXError(.EBUSY) }
      if entry.starting != nil { _ = try await mount(id); return }
      if let current = entry.mount {
        if await current.engine.issue == nil { return }
        try await current.unmount()
        entry.mount = nil
        await current.engine.stop()
      }
    } else {
      entries[id] = RemoteDriveEntry(registration)
      do { try save() }
      catch { entries.removeValue(forKey: id); throw error }
    }
    try FinderCredentialStore.save(credential, domainID: id)
    _ = try await mount(id)
  }

  private func resumeRetirement(_ entry: RemoteDriveEntry, registration: RemoteRegistration,
    credential: FinderCredential) async throws {
    entry.removing = true
    defer { entry.removing = false }
    // The authenticated app supplies a new credential for this same account and drive.
    // Stop the previous mount without publishing or deleting its accepted edits.
    let state = root.appendingPathComponent(registration.domainID)
    if entry.registration.accessWithdrawn == true {
      let writes = try RemoteWriteJournal(url: state.appendingPathComponent("writes.sqlite"),
        namespace: registration.domainID, limit: 256 * 1024 * 1024)
      let mutations = try RemoteMutationJournal(url: state.appendingPathComponent("mutations.sqlite"),
        namespace: registration.domainID)
      guard try writes.pending().isEmpty && mutations.first() == nil else {
        throw NSError(domain: "GardenRemoteRemoval", code: Int(EBUSY), userInfo:
          [NSLocalizedDescriptionKey: "Pending changes on “\(registration.name)” need review after drive access was removed. Your changes are preserved."])
      }
    }
    try await unmount(entry, preserveWrites: true)
    try FinderCredentialStore.save(credential, domainID: registration.domainID)
    let previous = entry.registration
    entry.registration = registration
    do { try save() }
    catch { entry.registration = previous; throw error }
  }

  func rename(accountID: String, driveID: Int, name: String) async throws {
    let registration = RemoteRegistration(accountID: accountID, driveID: driveID, name: name)
    try registration.validate()
    let id = registration.domainID
    guard let entry = entries[id], !entry.removing, entry.starting == nil else { throw POSIXError(.EBUSY) }
    if entry.registration.name == name { return }
    entry.removing = true
    defer { entry.removing = false }
    if let current = entry.mount { try await current.engine.flushAll() }
    try await unmount(entry)
    let previous = entry.registration
    entry.registration.name = name
    do { try save() }
    catch { entry.registration = previous; throw error }
    entry.removing = false
    _ = try await mount(id)
    await publish()
  }

  func status(accountID: String, driveIDs: [Int]) async throws -> [String: [Int]] {
    try validateAccount(accountID)
    var result: [String: [Int]] = ["registered": [], "enabled": [], "disabled": [], "disconnected": []]
    for driveID in driveIDs {
      guard let entry = entries[domainID(accountID, driveID)] else { continue }
      result["registered"]!.append(driveID)
      if entry.registration.retiring != true, let mount = entry.mount, await mount.engine.issue == nil { result["enabled"]!.append(driveID) }
      else { result["disconnected"]!.append(driveID) }
    }
    return result
  }

  func missing(accountID: String, driveIDs: [Int]) async throws -> [Int] {
    try validateAccount(accountID)
    var missing: [Int] = []
    for driveID in driveIDs {
      let id = domainID(accountID, driveID)
      guard let entry = entries[id] else { missing.append(driveID); continue }
      if entry.registration.retiring == true { missing.append(driveID); continue }
      do {
        let current = try await mount(id)
        if await current.engine.issue != nil { try await current.engine.reconnect() }
      } catch GardenAPIError.unauthorized { missing.append(driveID) }
      catch FinderCredentialError.keychain(errSecItemNotFound) { missing.append(driveID) }
    }
    return missing
  }

  func tokenIDs(accountID: String, keeping driveIDs: [Int]? = nil) throws -> [String] {
    try validateAccount(accountID)
    let keep = driveIDs.map(Set.init)
    return try entries.values.filter {
      $0.registration.accountID == accountID && !(keep?.contains($0.registration.driveID) ?? false)
    }.compactMap { entry in
      do { return try FinderCredentialStore.read(entry.registration.domainID).tokenID }
      catch FinderCredentialError.keychain(errSecItemNotFound) where entry.registration.retiring == true {
        // Credential deletion precedes the final registry commit; an interrupted commit can replay this state.
        return nil
      }
    }
  }

  func reconcile(accountID: String, driveIDs: [Int]) async throws {
    try validateAccount(accountID)
    let keep = Set(driveIDs)
    let removed = entries.values.filter {
      $0.registration.accountID == accountID && !keep.contains($0.registration.driveID)
    }.map(\.registration.domainID)
    for id in removed { try await remove(id) }
  }

  func prepareRemoval(accountID: String, keeping driveIDs: [Int]) async throws -> [String] {
    try validateAccount(accountID)
    let keep = Set(driveIDs)
    let removed = entries.values.filter {
      $0.registration.accountID == accountID && !keep.contains($0.registration.driveID)
    }
    for entry in removed {
      guard !entry.removing else { throw POSIXError(.EBUSY) }
      entry.removing = true
      defer { entry.removing = false }
      let previous = entry.registration
      entry.registration.retiring = true
      do { try save() }
      catch { entry.registration = previous; throw error }
      let state = root.appendingPathComponent(entry.registration.domainID)
      let engine: RemoteEngine
      if let mounted = entry.mount { engine = mounted.engine }
      else { engine = try RemoteEngine(domainID: entry.registration.domainID, state: state,
        cache: cache, limit: GardenCachePolicy.read()) }
      var withdrew = false
      let hasPendingWrites = !(try await engine.writes.pending().isEmpty)
      do {
        if entry.mount != nil || hasPendingWrites {
          withdrew = try await engine.checkWithdrawal()
        }
      }
      catch FinderCredentialError.keychain(let code) where code == errSecItemNotFound {
        // An interrupted completed retirement may already have removed its credential.
        let url = state.appendingPathComponent("writes.sqlite")
        if FileManager.default.fileExists(atPath: url.path) {
          let journal = try RemoteWriteJournal(url: url, namespace: entry.registration.domainID, limit: 256 * 1024 * 1024)
          if !(try journal.pending().isEmpty) { await engine.stop(); throw FinderCredentialError.keychain(code) }
        }
      }
      entry.registration.accessWithdrawn = withdrew
      try save()
      try await unmount(entry, preserveWrites: withdrew)
      if !withdrew, hasPendingWrites {
        do { try await engine.preparePendingWrites() }
        catch { await engine.stop(); throw error }
      }
      await engine.stop()

    }
    await publish()
    return try tokenIDs(accountID: accountID, keeping: driveIDs)
  }

  func location(accountID: String, driveID: Int, nodeID: Int?) async throws -> URL {
    try validateAccount(accountID)
    let mount = try await mount(domainID(accountID, driveID))
    let relative = try await mount.engine.path(nodeID)
    return URL(fileURLWithPath: mountPath(accountID, driveID)).appendingPathComponent(relative)
  }

  func reconnect(accountID: String, driveID: Int) async throws {
    try validateAccount(accountID)
    let current = try await mount(domainID(accountID, driveID))
    try await current.engine.reconnect()
  }

  func shutdown() async throws {
    stopping = true
    let current = Array(entries.values)
    for entry in current { entry.starting?.cancel() }
    var failure: Error?
    for entry in current {
      if let pending = entry.starting {
        do {
          let mounted = try await pending.value
          try await mounted.unmount()
          await mounted.engine.stop()
        } catch is CancellationError { }
        catch { failure = failure ?? error; RemoteLog.error(error) }
      }
      if let mount = entry.mount {
        do { try await mount.unmount(); await mount.engine.stop() }
        catch { failure = failure ?? error; RemoteLog.error(error) }
      }
    }
    if let failure { stopping = false; throw failure }
    entries.removeAll()
  }

  func prepareUpdate() async throws {
    for entry in entries.values {
      if let mount = entry.mount, await mount.engine.hasOpenFiles {
        throw NSError(domain: "GardenRemoteUpdate", code: Int(EBUSY), userInfo:
          [NSLocalizedDescriptionKey: "Close files on “\(entry.registration.name)” in other apps, then try Update again. Your pending changes are preserved."])
      }
    }
    try await shutdown()
  }

  private func mount(_ id: String) async throws -> RemoteMount {
    guard !stopping, let entry = entries[id], !entry.removing else { throw POSIXError(.ENODEV) }
    guard entry.registration.retiring != true else {
      throw NSError(domain: "GardenRemoteRemoval", code: Int(EBUSY), userInfo:
        [NSLocalizedDescriptionKey: "Complete the pending drive removal before opening it."])
    }
    if let mount = entry.mount { return mount }
    if let pending = entry.starting { return try await pending.value }
    let registration = entry.registration
    let state = root.appendingPathComponent(id)
    let cache = self.cache
    let pending = Task {
      try Task.checkCancellation()
      try RemotePlatform.requireModule()
      let credential = try FinderCredentialStore.read(id)
      guard credential.accountID == registration.accountID, credential.driveID == registration.driveID else {
        throw GardenAPIError.unauthorized
      }
      let engine = try RemoteEngine(domainID: id, state: state, cache: cache, limit: GardenCachePolicy.read())
      do {
        try await engine.prepare { await self.publish() }
        try Task.checkCancellation()
        return try await RemoteMount.start(engine: engine, path: registration.mountPath, name: "Garden - " + registration.name)
      } catch { await engine.stop(); throw error }
    }
    entry.starting = pending
    defer { entry.starting = nil }
    do {
      let mounted = try await pending.value
      guard !stopping, entries[id] === entry else {
        mounted.stop(); try? await mounted.run(); await mounted.engine.stop(); throw CancellationError()
      }
      entry.mount = mounted
      entry.issue = nil
      await publish()
      Task {
        do { try await mounted.run(); await self.ended(id, mount: mounted, issue: nil) }
        catch { await self.ended(id, mount: mounted, issue: error.localizedDescription) }
      }
      return mounted
    } catch { entry.issue = error.localizedDescription; await publish(); throw error }
  }

  private func ended(_ id: String, mount: RemoteMount, issue: String?) async {
    await mount.engine.stop()
    guard let entry = entries[id], entry.mount === mount else { return }
    entry.mount = nil
    entry.issue = issue ?? "Drive was unmounted."
    await publish()
  }

  private func remove(_ id: String) async throws {
    guard let entry = entries[id] else { return }
    guard !entry.removing, entry.registration.retiring == true else { throw POSIXError(.EBUSY) }
    entry.removing = true
    defer { entry.removing = false }
    try await unmount(entry)
    let journalURL = root.appendingPathComponent(id).appendingPathComponent("writes.sqlite")
    if FileManager.default.fileExists(atPath: journalURL.path) {
      let journal = try RemoteWriteJournal(url: journalURL, namespace: id, limit: 256 * 1024 * 1024)
      guard try entry.registration.accessWithdrawn == true || journal.pending().isEmpty else { throw POSIXError(.EBUSY) }
    }
    try FinderCredentialStore.remove(id)
    entries.removeValue(forKey: id)
    do { try save() }
    catch { entries[id] = entry; throw error }
    await publish()
  }

  private func unmount(_ entry: RemoteDriveEntry, preserveWrites: Bool = false) async throws {
    entry.starting?.cancel()
    if let pending = entry.starting {
      do {
        let mount = try await pending.value
        try await mount.unmount(preserveWrites: preserveWrites)
        await mount.engine.stop()
      } catch is CancellationError { }
    }
    if let mount = entry.mount {
      try await mount.unmount(preserveWrites: preserveWrites)
      await mount.engine.stop()
      entry.mount = nil
    }
  }

  private func save() throws { try registry.save(entries.values.map(\.registration)) }
  private func validateAccount(_ id: String) throws {
    guard UUID(uuidString: id)?.uuidString.lowercased() == id else { throw POSIXError(.EINVAL) }
  }
  private func domainID(_ account: String, _ drive: Int) -> String { "account-\(account)-drive-\(drive)" }
  private func mountPath(_ account: String, _ drive: Int) -> String { "/Volumes/Garden-\(account)-\(drive)" }
}
