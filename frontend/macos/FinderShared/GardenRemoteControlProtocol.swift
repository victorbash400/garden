import Foundation

enum GardenRemoteService {
  static let name = "com.victorbash.garden.remote"
  static let plist = name + ".plist"
  static let clientRequirement = "anchor apple generic and identifier \"com.victorbash.garden\" and certificate leaf[subject.OU] = \"387H4ZZF2K\""
  static let serverRequirement = "anchor apple generic and identifier \"com.victorbash.garden.remote\" and certificate leaf[subject.OU] = \"387H4ZZF2K\""
}

@objc protocol GardenRemoteControlProtocol: GardenCacheServiceProtocol {
  func request(_ method: String, payload: Data, reply: @escaping (Data?, String?) -> Void)
}

struct GardenRemoteRequest: Codable {
  let accountID: String
  var driveIDs: [Int]?
  var driveID: Int?
  var name: String?
  var credential: FinderCredential?
  var nodeID: Int?
}
