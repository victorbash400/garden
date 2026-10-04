import Foundation
import ServiceManagement

@main struct ControlTests {
  static func main() async throws {
    let args = CommandLine.arguments
    guard args.count >= 2 else { throw POSIXError(.EINVAL) }
    if args[1] == "enable" {
      let service = SMAppService.agent(plistName: GardenRemoteService.plist)
      try service.register()
      print("Managed background agent status: \(service.status.rawValue)")
      return
    }
    if args[1] == "unregister" {
      try await SMAppService.agent(plistName: GardenRemoteService.plist).unregister()
      print("Managed background agent unregistered")
      return
    }
    guard args.count == 5, let driveID = Int(args[3]) else { throw POSIXError(.EINVAL) }
    let request = GardenRemoteRequest(accountID: args[2], driveIDs: [driveID], driveID: driveID)
    if args[1] == "register" {
      let domain = "account-\(args[2])-drive-\(driveID)"
      var registration = request
      registration.name = args[4]
      registration.credential = try FinderCredentialStore.read(domain)
      try await withThrowingTaskGroup(of: Void.self) { group in
        for _ in 0..<3 { group.addTask { _ = try await GardenRemoteBridge.request("register", registration) } }
        try await group.waitForAll()
      }
    }
    let status = try await GardenRemoteBridge.request("status", request)
    guard let status = status as? [String: [Int]], status["enabled"] == [driveID] else { throw GardenAPIError.invalidResponse }
    guard let path = try await GardenRemoteBridge.request("location", request) as? String else { throw GardenAPIError.invalidResponse }
    guard path == "/Volumes/Garden-\(args[2])-\(driveID)" else { throw GardenAPIError.invalidResponse }
    print("Signed XPC control: drive enabled, mounted path \(path)")
  }
}
