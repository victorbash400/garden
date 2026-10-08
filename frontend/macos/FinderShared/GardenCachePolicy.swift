import Foundation

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


  static func read(defaultLimit: Int64 = defaultLimit) throws -> Int64 {
    let path = try localPolicyURL()
    guard FileManager.default.fileExists(atPath: path.path) else { return defaultLimit }
    let limit = try JSONDecoder().decode(Int64.self, from: Data(contentsOf: path))
    try validate(limit)
    return limit
  }

  static func save(_ limit: Int64) throws {
    try validate(limit)
    let data = try JSONEncoder().encode(limit)
    let path = try localPolicyURL()
    try data.write(to: path, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: path.path)
  }

  private static func localPolicyURL() throws -> URL {
    let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("GardenRemote", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    return root.appendingPathComponent("local-cache-limit.json")
  }

  static func validate(_ limit: Int64) throws {
    guard limit >= 0, limit <= 100 * 1024 * 1024 * 1024 else {
      throw NSError(domain: "GardenCache", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Cache limit must be between 0 and 100 GiB."])
    }
  }
}
