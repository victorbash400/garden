import FileProvider
import Foundation

final class GardenCacheService: NSObject, NSFileProviderServiceSource, NSXPCListenerDelegate, GardenCacheServiceProtocol {
  let serviceName = GardenCacheServiceName.value
  private let listener = NSXPCListener.anonymous()

  override init() {
    super.init()
    listener.delegate = self
    listener.resume()
  }

  func makeListenerEndpoint() throws -> NSXPCListenerEndpoint { listener.endpoint }

  func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
    connection.exportedInterface = NSXPCInterface(with: GardenCacheServiceProtocol.self)
    connection.exportedObject = self
    connection.remoteObjectInterface = NSXPCInterface(with: GardenCacheObserverProtocol.self)
    connection.resume()
    return true
  }

  func subscribeCache(reply: @escaping (String?) -> Void) {
    guard let connection = NSXPCConnection.current(),
          let observer = connection.remoteObjectProxy as? GardenCacheObserverProtocol else {
      reply("Cache usage connection is unavailable.")
      return
    }
    let task = Task {
      var subscribed = false
      do {
        let updates = try await GardenDiskCache.shared.updates()
        reply(nil)
        subscribed = true
        for try await status in updates {
          if Task.isCancelled { break }
          observer.cacheChanged(status.dictionary as NSDictionary)
        }
      } catch {
        if subscribed {
          if !Task.isCancelled { observer.cacheFailed(error.localizedDescription) }
        } else { reply(error.localizedDescription) }
      }
    }
    connection.invalidationHandler = { task.cancel() }
    connection.interruptionHandler = { task.cancel() }
  }

  func clearCache(reply: @escaping (NSDictionary?, String?) -> Void) {
    Task {
      do { reply(try await GardenDiskCache.shared.clear().dictionary as NSDictionary, nil) }
      catch { reply(nil, error.localizedDescription) }
    }
  }

  func cacheStatus(reply: @escaping (NSDictionary?, String?) -> Void) {
    Task {
      do { reply(try await GardenDiskCache.shared.status().dictionary as NSDictionary, nil) }
      catch { reply(nil, error.localizedDescription) }
    }
  }

  func setCacheLimit(_ bytes: Int64, reply: @escaping (NSDictionary?, String?) -> Void) {
    Task {
      do { reply(try await GardenDiskCache.shared.setLimit(bytes).dictionary as NSDictionary, nil) }
      catch { reply(nil, error.localizedDescription) }
    }
  }
}
