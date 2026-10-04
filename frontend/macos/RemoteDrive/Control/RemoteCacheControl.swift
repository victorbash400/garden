import Foundation

final class RemoteCacheControl {
  let cache: GardenDiskCache
  init(cache: GardenDiskCache) { self.cache = cache }

  func subscribe(reply: @escaping (String?) -> Void) {
    guard let connection = NSXPCConnection.current(),
      let observer = connection.remoteObjectProxy as? GardenCacheObserverProtocol else {
      reply("Cache usage connection is unavailable.")
      return
    }
    let task = Task {
      var subscribed = false
      do {
        let updates = try await cache.updates()
        reply(nil)
        subscribed = true
        for try await status in updates {
          try Task.checkCancellation()
          observer.cacheChanged(status.dictionary as NSDictionary)
        }
      } catch {
        if subscribed { if !Task.isCancelled { observer.cacheFailed(error.localizedDescription) } }
        else { reply(error.localizedDescription) }
      }
    }
    connection.invalidationHandler = { task.cancel() }
    connection.interruptionHandler = { task.cancel() }
  }

  func perform(_ method: String, bytes: Int64? = nil, reply: @escaping (NSDictionary?, String?) -> Void) {
    Task {
      do {
        let status: GardenCacheStatus
        switch method {
        case "clear": status = try await cache.clear()
        case "setLimit":
          guard let bytes else { throw POSIXError(.EINVAL) }
          status = try await cache.setLimit(bytes)
        default: status = try await cache.status()
        }
        reply(status.dictionary as NSDictionary, nil)
      } catch { reply(nil, error.localizedDescription) }
    }
  }
}
