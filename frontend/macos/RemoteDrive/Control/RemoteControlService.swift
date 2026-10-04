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
      } catch { reply(nil, error.localizedDescription) }
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
    default: throw POSIXError(.ENOSYS)
    }
    return NSNull()
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
  func cacheStatus(reply: @escaping (NSDictionary?, String?) -> Void) { cache.perform("status", reply: reply) }
  func clearCache(reply: @escaping (NSDictionary?, String?) -> Void) { cache.perform("clear", reply: reply) }
  func setCacheLimit(_ bytes: Int64, reply: @escaping (NSDictionary?, String?) -> Void) { cache.perform("setLimit", bytes: bytes, reply: reply) }
}
