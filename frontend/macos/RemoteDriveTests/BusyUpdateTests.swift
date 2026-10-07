import Foundation

@main struct BusyUpdateTests {
  static func main() async throws {
    guard CommandLine.arguments.count == 4, let driveID = Int(CommandLine.arguments[2]) else {
      throw POSIXError(.EINVAL)
    }
    let account = CommandLine.arguments[1]
    let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("GardenRemote")
    let ids = try RemoteRegistry(root: root).read().filter { $0.accountID == account }.map(\.driveID)
    guard ids.contains(driveID) else { throw POSIXError(.ENOENT) }
    let request = GardenRemoteRequest(accountID: account, driveIDs: ids, driveID: driveID)
    let before = try await GardenRemoteBridge.request("status", request) as? [String: [Int]]
    guard before?["enabled"]?.contains(driveID) == true else { throw POSIXError(.ENODEV) }
    let file = try FileHandle(forReadingFrom: URL(fileURLWithPath: CommandLine.arguments[3]))
    defer { try? file.close() }
    guard try file.read(upToCount: 1)?.count == 1 else { throw POSIXError(.EIO) }
    let began = ContinuousClock.now
    do {
      _ = try await GardenRemoteBridge.request("prepareUpdate", GardenRemoteRequest(accountID: ""))
      throw POSIXError(.EIO)
    } catch let error as NSError where error.localizedDescription.contains("Close files on") {
      guard error.localizedDescription.contains("pending changes are preserved"),
        began.duration(to: .now) < .seconds(2) else { throw POSIXError(.EIO) }
      print("Busy update rejected promptly: \(error.localizedDescription)")
    }
    let after = try await GardenRemoteBridge.request("status", request) as? [String: [Int]]
    guard before?.mapValues({ $0.sorted() }) == after?.mapValues({ $0.sorted() }),
      try file.seekToEnd() > 0 else { throw POSIXError(.EIO) }
    print("Busy update: open file remains readable, all account drive statuses preserved, and no update shutdown occurred")
  }
}
