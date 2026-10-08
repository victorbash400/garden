import Foundation
import Security
import LocalAuthentication

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
    #if GARDEN_MANUAL_INSTALL
    let path = try localURL(domainID)
    guard FileManager.default.fileExists(atPath: path.path) else {
      throw FinderCredentialError.keychain(errSecItemNotFound)
    }
    return try JSONDecoder().decode(FinderCredential.self, from: Data(contentsOf: path))
    #else
    var query = baseQuery(domainID)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess, let data = result as? Data else {
      throw FinderCredentialError.keychain(status)
    }
    return try JSONDecoder().decode(FinderCredential.self, from: data)
    #endif
  }

  static func save(_ credential: FinderCredential, domainID: String) throws {
    let data = try JSONEncoder().encode(credential)
    #if GARDEN_MANUAL_INSTALL
    let path = try localURL(domainID)
    try data.write(to: path, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: path.path)
    #else
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
    #endif
  }

  static func remove(_ domainID: String) throws {
    #if GARDEN_MANUAL_INSTALL
    let path = try localURL(domainID)
    if FileManager.default.fileExists(atPath: path.path) {
      try FileManager.default.removeItem(at: path)
    }
    #else
    let status = SecItemDelete(baseQuery(domainID) as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw FinderCredentialError.keychain(status)
    }
    #endif
  }

  #if GARDEN_MANUAL_INSTALL
  private static func localURL(_ domainID: String) throws -> URL {
    guard !domainID.isEmpty, domainID.utf8.count <= 120 else { throw POSIXError(.EINVAL) }
    let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("GardenRemote/Connections", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    let attributes = try FileManager.default.attributesOfItem(atPath: root.path)
    guard attributes[.type] as? FileAttributeType == .typeDirectory,
      attributes[.ownerAccountID] as? UInt32 == getuid() else { throw POSIXError(.EACCES) }
    try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: root.path)
    let filename = domainID.utf8.map { String(format: "%02x", $0) }.joined()
    let path = root.appendingPathComponent(filename + ".json")
    if FileManager.default.fileExists(atPath: path.path) {
      let item = try FileManager.default.attributesOfItem(atPath: path.path)
      guard item[.type] as? FileAttributeType == .typeRegular,
        item[.ownerAccountID] as? UInt32 == getuid() else { throw POSIXError(.EACCES) }
      try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: path.path)
    }
    return path
  }
  #endif

  private static func baseQuery(_ domainID: String) -> [String: Any] {
    let authentication = LAContext()
    authentication.interactionNotAllowed = true
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecUseDataProtectionKeychain as String: true,
      kSecUseAuthenticationContext as String: authentication,
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
    case .keychain(let status) where status == errSecInteractionNotAllowed || status == errSecAuthFailed:
      return "Garden Finder cannot access its saved connection. Unlock your Mac, then check connections in Garden."
    case .keychain(let status):
      let detail = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Keychain error"
      return "Garden Finder Keychain error \(status): \(detail)"
    }
  }
}
