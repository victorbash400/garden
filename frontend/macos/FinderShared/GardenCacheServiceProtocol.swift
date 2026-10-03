import Foundation

@objc protocol GardenCacheServiceProtocol {
  func subscribeCache(reply: @escaping (String?) -> Void)
  func clearCache(reply: @escaping (NSDictionary?, String?) -> Void)
  func cacheStatus(reply: @escaping (NSDictionary?, String?) -> Void)
  func setCacheLimit(_ bytes: Int64, reply: @escaping (NSDictionary?, String?) -> Void)
}

@objc protocol GardenCacheObserverProtocol {
  func cacheChanged(_ value: NSDictionary)
  func cacheFailed(_ message: String)
}

enum GardenCacheServiceName {
  static let value = NSFileProviderServiceName("com.victorbash.garden.cache")
}
