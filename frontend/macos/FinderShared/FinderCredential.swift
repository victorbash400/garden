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
  static func read(_ domainID: String) throws -> FinderCredential {
    let path = try localURL(domainID)
    guard FileManager.default.fileExists(atPath: path.path) else {
      throw FinderCredentialError.keychain(errSecItemNotFound)
    }
    return try JSONDecoder().decode(FinderCredential.self, from: Data(contentsOf: path))
  }

  static func save(_ credential: FinderCredential, domainID: String) throws {
    let data = try JSONEncoder().encode(credential)
    let path = try localURL(domainID)
    try data.write(to: path, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: path.path)
  }

  static func remove(_ domainID: String) throws {
    let path = try localURL(domainID)
    if FileManager.default.fileExists(atPath: path.path) {
      try FileManager.default.removeItem(at: path)
    }
  }

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


}

enum FinderCredentialError: LocalizedError {
  case keychain(OSStatus)

  var errorDescription: String? {
    switch self {
    case .keychain(let status) where status == errSecInteractionNotAllowed || status == errSecAuthFailed:
      return "Garden Finder cannot access its saved connection. Sign in again, then check connections in Garden."
    case .keychain(let status):
      let detail = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Keychain error"
      return "Garden Finder saved-session error \(status): \(detail)"
    }
  }
}
