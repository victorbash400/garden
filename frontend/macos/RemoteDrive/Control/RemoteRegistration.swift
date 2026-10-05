import Foundation

struct RemoteRegistration: Codable, Equatable, Sendable {
  let accountID: String
  let driveID: Int
  var name: String
  var retiring: Bool? = nil
  var accessWithdrawn: Bool? = nil

  var domainID: String { "account-\(accountID)-drive-\(driveID)" }
  var mountPath: String { "/Volumes/Garden-\(accountID)-\(driveID)" }

  func validate() throws {
    guard UUID(uuidString: accountID)?.uuidString.lowercased() == accountID, driveID > 0,
      !name.isEmpty, name.utf8.count < 400, !name.contains("\0") else { throw POSIXError(.EINVAL) }
  }
}

final class RemoteRegistry {
  private let url: URL

  init(root: URL) throws {
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    url = root.appendingPathComponent("drives.json")
  }

  func read() throws -> [RemoteRegistration] {
    guard FileManager.default.fileExists(atPath: url.path) else { return [] }
    let registrations = try JSONDecoder().decode([RemoteRegistration].self, from: Data(contentsOf: url))
    for registration in registrations { try registration.validate() }
    guard Set(registrations.map(\.domainID)).count == registrations.count else { throw POSIXError(.EINVAL) }
    return registrations
  }

  func save(_ registrations: [RemoteRegistration]) throws {
    for registration in registrations { try registration.validate() }
    guard Set(registrations.map(\.domainID)).count == registrations.count else { throw POSIXError(.EINVAL) }
    try JSONEncoder().encode(registrations.sorted { $0.domainID < $1.domainID }).write(to: url, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
  }
}
