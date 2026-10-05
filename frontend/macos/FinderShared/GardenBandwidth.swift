import Foundation

struct GardenBandwidthLimits: Codable, Equatable, Sendable {
  var upload: Int64 = 0
  var download: Int64 = 0
  var dictionary: [String: Any] { ["upload": upload, "download": download] }

  func validate() throws {
    let maximum: Int64 = 1024 * 1024 * 1024
    guard upload >= 0, download >= 0, upload <= maximum, download <= maximum else {
      throw POSIXError(.EINVAL)
    }
  }
}

// Reservations share one payload budget across drives and the Flutter transfer client.
// Rates are averaged over requests, not instantaneous limits on the network interface.
actor GardenBandwidth {
  static let shared = GardenBandwidth()
  private let file: URL
  private var limits: GardenBandwidthLimits?
  private var uploadUntil = ContinuousClock.now
  private var downloadUntil = ContinuousClock.now

  init(file: URL = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/Application Support/GardenRemote/bandwidth.json")) {
    self.file = file
  }

  func status() throws -> GardenBandwidthLimits {
    if let limits { return limits }
    let value: GardenBandwidthLimits
    if FileManager.default.fileExists(atPath: file.path) {
      value = try JSONDecoder().decode(GardenBandwidthLimits.self, from: Data(contentsOf: file))
    } else { value = GardenBandwidthLimits() }
    try value.validate()
    limits = value
    return value
  }

  func set(_ value: GardenBandwidthLimits) throws {
    try value.validate()
    try FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
    try JSONEncoder().encode(value).write(to: file, options: .atomic)
    try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
    limits = value
    uploadUntil = .now
    downloadUntil = .now
  }

  func reserve(bytes: Int64, upload: Bool) throws -> Double {
    guard bytes >= 0, bytes <= 1024 * 1024 * 1024 else { throw POSIXError(.EINVAL) }
    let value = try status()
    let rate = upload ? value.upload : value.download
    if rate == 0 || bytes == 0 { return 0 }
    let now = ContinuousClock.now
    let previous = upload ? uploadUntil : downloadUntil
    let until = max(now, previous).advanced(by: .seconds(Double(bytes) / Double(rate)))
    if upload { uploadUntil = until } else { downloadUntil = until }
    let duration = now.duration(to: until).components
    return Double(duration.seconds) + Double(duration.attoseconds) / 1e18
  }

  func pace(bytes: Int64, upload: Bool) async throws {
    let seconds = try reserve(bytes: bytes, upload: upload)
    if seconds > 0 { try await Task.sleep(for: .seconds(seconds)) }
    try Task.checkCancellation()
  }
}
