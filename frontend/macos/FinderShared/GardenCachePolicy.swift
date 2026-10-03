import Foundation
import Security

struct GardenCacheStatus: Equatable, Sendable {
  let limit: Int64
  let used: Int64
  let blocks: Int

  var dictionary: [String: Any] {
    ["limitBytes": limit, "usedBytes": used, "blocks": blocks]
  }
}

enum GardenCachePolicy {
  static let defaultLimit: Int64 = 20 * 1024 * 1024 * 1024
  private static let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccessGroup as String: "387H4ZZF2K.com.victorbash.garden",
    kSecAttrService as String: "Garden Cache",
    kSecAttrAccount as String: "limit",
  ]

  static func read(defaultLimit: Int64 = defaultLimit) throws -> Int64 {
    var request = query
    request[kSecReturnData as String] = true
    var result: CFTypeRef?
    let status = SecItemCopyMatching(request as CFDictionary, &result)
    if status == errSecItemNotFound { return defaultLimit }
    guard status == errSecSuccess, let data = result as? Data else {
      throw FinderCredentialError.keychain(status)
    }
    let limit = try JSONDecoder().decode(Int64.self, from: data)
    try validate(limit)
    return limit
  }

  static func save(_ limit: Int64) throws {
    try validate(limit)
    let data = try JSONEncoder().encode(limit)
    let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
    if status == errSecSuccess { return }
    guard status == errSecItemNotFound else { throw FinderCredentialError.keychain(status) }
    var values = query
    values[kSecValueData as String] = data
    values[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    let added = SecItemAdd(values as CFDictionary, nil)
    guard added == errSecSuccess else { throw FinderCredentialError.keychain(added) }
  }

  static func validate(_ limit: Int64) throws {
    guard limit >= 0, limit <= 100 * 1024 * 1024 * 1024 else {
      throw NSError(domain: "GardenCache", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Cache limit must be between 0 and 100 GiB."])
    }
  }
}
