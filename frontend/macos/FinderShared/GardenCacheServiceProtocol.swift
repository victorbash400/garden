import Foundation

@objc protocol GardenCacheServiceProtocol {
  func clearCache(reply: @escaping (NSDictionary?, String?) -> Void)
  func cacheStatus(reply: @escaping (NSDictionary?, String?) -> Void)
  func setCacheLimit(_ bytes: Int64, reply: @escaping (NSDictionary?, String?) -> Void)
}

enum GardenCacheServiceName {
  static let value = NSFileProviderServiceName("com.victorbash.garden.cache")
}
