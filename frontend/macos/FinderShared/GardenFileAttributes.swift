import Foundation

struct GardenFileAttributes: Codable, Equatable, Sendable {
  var accessedAt: String?
  var permissions: Int?
  var flags: Int?
  var extended: [String: String]?
  static let maximumBytes = 256 * 1024

  var arguments: [String: Any] {
    var result: [String: Any] = ["__className__": "FileAttributes"]
    if let accessedAt { result["accessedAt"] = accessedAt }
    if let permissions { result["permissions"] = permissions }
    if let flags { result["flags"] = flags }
    if let extended { result["extended"] = extended }
    return result
  }

  func value(_ name: String) throws -> Data {
    guard let value = extended?[name] else { throw POSIXError(.ENOATTR) }
    guard let data = Data(base64Encoded: value) else { throw GardenAPIError.invalidResponse }
    return data
  }

  func setting(_ name: String, bytes: Data?, options: Int) throws -> GardenFileAttributes {
    guard !name.isEmpty, name.utf8.count <= 255, !name.contains("\0"), [0, 2, 4].contains(options) else {
      throw POSIXError(.EINVAL)
    }
    var result = self
    var values = extended ?? [:]
    if bytes == nil || options == 4 {
      guard values[name] != nil else { throw POSIXError(.ENOATTR) }
    } else if options == 2 && values[name] != nil { throw POSIXError(.EEXIST) }
    if let bytes { values[name] = bytes.base64EncodedString() }
    else { values.removeValue(forKey: name) }
    result.extended = values
    try result.validate()
    return result
  }

  func validate() throws {
    if let permissions, permissions < 0 || permissions > 0o777 { throw POSIXError(.EINVAL) }
    if let flags, flags < 0 || flags & ~0x8001 != 0 { throw POSIXError(.ENOTSUP) }
    let values = extended ?? [:]
    guard values.count <= 64 else { throw POSIXError(.E2BIG) }
    var total = 0
    for (name, value) in values {
      guard !name.isEmpty, name.utf8.count <= 255, !name.contains("\0"), value.count <= (Self.maximumBytes + 2) / 3 * 4,
        let bytes = Data(base64Encoded: value), bytes.base64EncodedString() == value else { throw POSIXError(.EINVAL) }
      total += name.utf8.count + bytes.count
      guard total <= Self.maximumBytes else { throw POSIXError(.E2BIG) }
    }
  }

  static func date(_ value: String) throws -> Date {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let date = formatter.date(from: value) { return date }
    formatter.formatOptions = [.withInternetDateTime]
    guard let date = formatter.date(from: value) else { throw GardenAPIError.invalidResponse }
    return date
  }

  static func string(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: date)
  }
}
