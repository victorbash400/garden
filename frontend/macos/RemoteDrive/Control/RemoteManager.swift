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
      if entry.removing || entry.registration != registration { throw POSIXError(.EBUSY) }
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

  func status(accountID: String, driveIDs: [Int]) async throws -> [String: [Int]] {
    try validateAccount(accountID)
    var result: [String: [Int]] = ["registered": [], "enabled": [], "disabled": [], "disconnected": []]
    for driveID in driveIDs {
      guard let entry = entries[domainID(accountID, driveID)] else { continue }
      result["registered"]!.append(driveID)
      if let mount = entry.mount, await mount.engine.issue == nil { result["enabled"]!.append(driveID) }
      else { result["disconnected"]!.append(driveID) }
    }
    return result
  }

  func missing(accountID: String, driveIDs: [Int]) async throws -> [Int] {
    try validateAccount(accountID)
    var missing: [Int] = []
    for driveID in driveIDs {
      let id = domainID(accountID, driveID)
      guard entries[id] != nil else { missing.append(driveID); continue }
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
    }.map { try FinderCredentialStore.read($0.registration.domainID).tokenID }
  }

  func reconcile(accountID: String, driveIDs: [Int]) async throws {
    try validateAccount(accountID)
    let keep = Set(driveIDs)
    let removed = entries.values.filter {
      $0.registration.accountID == accountID && !keep.contains($0.registration.driveID)
    }.map(\.registration.domainID)
    for id in removed { try await remove(id) }
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

  private func mount(_ id: String) async throws -> RemoteMount {
    guard !stopping, let entry = entries[id], !entry.removing else { throw POSIXError(.ENODEV) }
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
    guard !entry.removing else { throw POSIXError(.EBUSY) }
    entry.removing = true
    defer { entry.removing = false }
    entry.starting?.cancel()
    if let pending = entry.starting {
      do {
        let mount = try await pending.value
        try await mount.unmount()
        await mount.engine.stop()
      } catch is CancellationError { }
    }
    if let mount = entry.mount {
      try await mount.unmount()
      await mount.engine.stop()
    }
    entries.removeValue(forKey: id)
    do { try save() }
    catch { entries[id] = entry; throw error }
    try FinderCredentialStore.remove(id)
    await publish()
  }

  private func save() throws { try registry.save(entries.values.map(\.registration)) }
  private func validateAccount(_ id: String) throws {
    guard UUID(uuidString: id)?.uuidString.lowercased() == id else { throw POSIXError(.EINVAL) }
  }
  private func domainID(_ account: String, _ drive: Int) -> String { "account-\(account)-drive-\(drive)" }
  private func mountPath(_ account: String, _ drive: Int) -> String { "/Volumes/Garden-\(account)-\(drive)" }
}
