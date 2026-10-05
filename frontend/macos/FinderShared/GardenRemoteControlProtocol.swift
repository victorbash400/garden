import Foundation

enum GardenRemoteService {
  static let name = "com.victorbash.garden.remote"
  static let plist = name + ".plist"
  static let clientRequirement = "anchor apple generic and identifier \"com.victorbash.garden\" and certificate leaf[subject.OU] = \"387H4ZZF2K\""
  static let serverRequirement = "anchor apple generic and identifier \"com.victorbash.garden.remote\" and certificate leaf[subject.OU] = \"387H4ZZF2K\""
}

@objc protocol GardenRemoteControlProtocol: GardenCacheServiceProtocol {
  func subscribeActivity(_ account: String, reply: @escaping (String?) -> Void)
  func clearActivity(_ account: String, reply: @escaping () -> Void)
  func bandwidthStatus(reply: @escaping (NSDictionary?, String?) -> Void)
  func setBandwidth(_ upload: Int64, download: Int64, reply: @escaping (String?) -> Void)
  func reserveBandwidth(_ bytes: Int64, upload: Bool, reply: @escaping (Double, String?) -> Void)
  func request(_ method: String, payload: Data, reply: @escaping (Data?, String?) -> Void)
  func subscribeDrives(_ payload: Data, reply: @escaping (String?) -> Void)
}

@objc protocol GardenRemoteObserverProtocol: GardenCacheObserverProtocol {
  func drivesChanged(_ value: NSDictionary)
  func drivesFailed(_ message: String)
}

struct GardenRemoteRequest: Codable {
  let accountID: String
  var driveIDs: [Int]?
  var driveID: Int?
  var name: String?
  var credential: FinderCredential?
  var nodeID: Int?
}
