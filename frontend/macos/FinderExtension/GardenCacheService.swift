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
    connection.resume()
    return true
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
