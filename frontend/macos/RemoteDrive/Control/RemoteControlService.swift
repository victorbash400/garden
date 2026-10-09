import Foundation

final class RemoteControlService: NSObject, NSXPCListenerDelegate, GardenRemoteControlProtocol {
  let manager: RemoteManager
  private let cache: RemoteCacheControl

  init(manager: RemoteManager, cache: GardenDiskCache) {
    self.manager = manager
    self.cache = RemoteCacheControl(cache: cache)
  }

  func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
    guard connection.effectiveUserIdentifier == getuid() else { return false }
    connection.setCodeSigningRequirement(GardenRemoteService.clientRequirement)
    connection.exportedInterface = NSXPCInterface(with: GardenRemoteControlProtocol.self)
    connection.exportedObject = self
    connection.remoteObjectInterface = NSXPCInterface(with: GardenRemoteObserverProtocol.self)
    connection.resume()
    return true
  }

  func request(_ method: String, payload: Data, reply: @escaping (Data?, String?) -> Void) {
    Task {
      do {
        let request = try JSONDecoder().decode(GardenRemoteRequest.self, from: payload)
        let value = try await perform(method, request: request)
        reply(try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed]), nil)
      } catch {
        let failure = error as NSError
        let code: Int
        if case GardenAPIError.unauthorized = error { code = 401 }
        else if failure.domain == NSURLErrorDomain && failure.code == NSURLErrorTimedOut { code = 408 }
        else if failure.domain == NSPOSIXErrorDomain && failure.code == Int(EACCES) { code = 403 }
        else if failure.domain == NSPOSIXErrorDomain && failure.code == Int(ENODEV) { code = 503 }
        else { code = 500 }
        let detail = try? JSONSerialization.data(withJSONObject: ["code": code])
        reply(detail, error.localizedDescription)
      }
    }
  }

  private func perform(_ method: String, request: GardenRemoteRequest) async throws -> Any {
    switch method {
    case "missing":
      guard let ids = request.driveIDs else { throw POSIXError(.EINVAL) }
      return try await manager.missing(accountID: request.accountID, driveIDs: ids)
    case "status":
      guard let ids = request.driveIDs else { throw POSIXError(.EINVAL) }
      let status = try await manager.status(accountID: request.accountID, driveIDs: ids)
      return status
    case "register":
      guard let driveID = request.driveID, let name = request.name, let credential = request.credential else {
        throw POSIXError(.EINVAL)
      }
      try await manager.register(RemoteRegistration(accountID: request.accountID, driveID: driveID, name: name), credential: credential)
    case "rename":
      guard let driveID = request.driveID, let name = request.name else { throw POSIXError(.EINVAL) }
      try await manager.rename(accountID: request.accountID, driveID: driveID, name: name)
    case "reconcile":
      guard let ids = request.driveIDs else { throw POSIXError(.EINVAL) }
      try await manager.reconcile(accountID: request.accountID, driveIDs: ids)
    case "prepareRemoval":
      guard let ids = request.driveIDs else { throw POSIXError(.EINVAL) }
      return try await manager.prepareRemoval(accountID: request.accountID, keeping: ids)
    case "signOut": try await manager.reconcile(accountID: request.accountID, driveIDs: [])
    case "tokenIDs": return try await manager.tokenIDs(accountID: request.accountID)
    case "retiredTokenIDs":
      guard let ids = request.driveIDs else { throw POSIXError(.EINVAL) }
      return try await manager.tokenIDs(accountID: request.accountID, keeping: ids)
    case "location":
      guard let driveID = request.driveID else { throw POSIXError(.EINVAL) }
      return try await manager.location(accountID: request.accountID, driveID: driveID, nodeID: request.nodeID).path
    case "reconnect":
      guard let driveID = request.driveID else { throw POSIXError(.EINVAL) }
      try await manager.reconnect(accountID: request.accountID, driveID: driveID)
    case "prepareUpdate": try await manager.prepareUpdate()
    default: throw POSIXError(.ENOSYS)
    }
    return NSNull()
  }

  func subscribeActivity(_ account: String, reply: @escaping (String?) -> Void) {
    guard let connection = NSXPCConnection.current(), UUID(uuidString: account) != nil else {
      reply("Invalid activity account."); return
    }
    connection.remoteObjectInterface = NSXPCInterface(with: GardenActivityObserverProtocol.self)
    guard let observer = connection.remoteObjectProxy as? GardenActivityObserverProtocol else {
      reply("Activity connection is unavailable."); return
    }
    let task = Task {
      let stream = await GardenActivity.shared.updates(account: account)
      reply(nil)
      do {
        for try await data in stream {
          if Task.isCancelled { break }
          observer.activityChanged(data)
        }
      } catch { observer.activityFailed(error.localizedDescription) }
    }
    connection.invalidationHandler = { task.cancel() }
    connection.interruptionHandler = { task.cancel() }
  }
  func clearActivity(_ account: String, reply: @escaping () -> Void) {
    Task { await GardenActivity.shared.clear(account: account); reply() }
  }
  func subscribeCache(reply: @escaping (String?) -> Void) { cache.subscribe(reply: reply) }
  func subscribeDrives(_ payload: Data, reply: @escaping (String?) -> Void) {
    guard let connection = NSXPCConnection.current(),
      let observer = connection.remoteObjectProxy as? GardenRemoteObserverProtocol else {
      reply("Drive status connection is unavailable.")
      return
    }
    let task = Task {
      var subscribed = false
      do {
        let request = try JSONDecoder().decode(GardenRemoteRequest.self, from: payload)
        guard let ids = request.driveIDs else { throw POSIXError(.EINVAL) }
        let updates = try await manager.updates(accountID: request.accountID, driveIDs: ids)
        reply(nil)
        subscribed = true
        for try await status in updates {
          try Task.checkCancellation()
          observer.drivesChanged(status as NSDictionary)
        }
      } catch {
        if !subscribed { reply(error.localizedDescription) }
        else if !Task.isCancelled { observer.drivesFailed(error.localizedDescription) }
      }
    }
    connection.invalidationHandler = { task.cancel() }
    connection.interruptionHandler = { task.cancel() }
  }
  func bandwidthStatus(reply: @escaping (NSDictionary?, String?) -> Void) {
    Task {
      do { reply(try await GardenBandwidth.shared.status().dictionary as NSDictionary, nil) }
      catch { reply(nil, error.localizedDescription) }
    }
  }
  func setBandwidth(_ upload: Int64, download: Int64, reply: @escaping (String?) -> Void) {
    Task {
      do { try await GardenBandwidth.shared.set(GardenBandwidthLimits(upload: upload, download: download)); reply(nil) }
      catch { reply(error.localizedDescription) }
    }
  }
  func reserveBandwidth(_ bytes: Int64, upload: Bool, reply: @escaping (Double, String?) -> Void) {
    Task {
      do { reply(try await GardenBandwidth.shared.reserve(bytes: bytes, upload: upload), nil) }
      catch { reply(0, error.localizedDescription) }
    }
  }
  func cacheStatus(reply: @escaping (NSDictionary?, String?) -> Void) { cache.perform("status", reply: reply) }
  func clearCache(reply: @escaping (NSDictionary?, String?) -> Void) { cache.perform("clear", reply: reply) }
  func setCacheLimit(_ bytes: Int64, reply: @escaping (NSDictionary?, String?) -> Void) { cache.perform("setLimit", bytes: bytes, reply: reply) }
}
