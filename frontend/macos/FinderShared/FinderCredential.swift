import Foundation
import Security

struct FinderCredential: Codable {
  let serverURL: String
  let accountID: String
  let driveID: Int
  let tokenID: String
  var token: String
  var refreshToken: String
}

enum FinderCredentialStore {
  private static let accessGroup = "387H4ZZF2K.com.victorbash.garden"
  private static let service = "Garden Finder"

  static func read(_ domainID: String) throws -> FinderCredential {
    var query = baseQuery(domainID)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess, let data = result as? Data else {
      throw FinderCredentialError.keychain(status)
    }
    return try JSONDecoder().decode(FinderCredential.self, from: data)
  }

  static func save(_ credential: FinderCredential, domainID: String) throws {
    let data = try JSONEncoder().encode(credential)
    let query = baseQuery(domainID)
    let status = SecItemUpdate(
      query as CFDictionary,
      [kSecValueData as String: data] as CFDictionary
    )
    if status == errSecSuccess { return }
    guard status == errSecItemNotFound else {
      throw FinderCredentialError.keychain(status)
    }
    var values = query
    values[kSecValueData as String] = data
    values[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    let addStatus = SecItemAdd(values as CFDictionary, nil)
    guard addStatus == errSecSuccess else {
      throw FinderCredentialError.keychain(addStatus)
    }
  }

  static func remove(_ domainID: String) throws {
    let status = SecItemDelete(baseQuery(domainID) as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw FinderCredentialError.keychain(status)
    }
  }

  private static func baseQuery(_ domainID: String) -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccessGroup as String: accessGroup,
      kSecAttrService as String: service,
      kSecAttrAccount as String: domainID,
    ]
  }
}

enum FinderCredentialError: LocalizedError {
  case keychain(OSStatus)

  var errorDescription: String? {
    switch self {
    case .keychain(let status):
      let detail = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Keychain error"
      return "Garden Finder Keychain error \(status): \(detail)"
    }
  }
}
