import Foundation

@main struct MountControlTests {
  static func main() async throws {
    let account = UUID().uuidString.lowercased()
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-mount-control-" + UUID().uuidString, isDirectory: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let cache = root.appendingPathComponent("cache", isDirectory: true)
    let registry = try RemoteRegistry(root: root)
    try registry.save([RemoteRegistration(accountID: account, driveID: 1, name: "Test drive")])
    let manager = try RemoteManager(root: root, cache: cache)
    try await manager.setMounted(accountID: account, driveID: 1, enabled: false)
    guard try registry.read().first?.suspended == true else { fatalError("Unmount preference was not saved") }
    let restored = try RemoteManager(root: root, cache: cache)
    await restored.restore()
    var status = try await restored.status(accountID: account, driveIDs: [1])
    guard status["disabled"] == [1], status["disconnected"] == [] else { fatalError("Unmounted drive was restored as disconnected") }
    try await restored.rename(accountID: account, driveID: 1, name: "Renamed drive")
    try await restored.reconcile(accountID: account, driveIDs: [1])
    status = try await restored.status(accountID: account, driveIDs: [1])
    guard status["disabled"] == [1], try registry.read().first?.name == "Renamed drive" else { fatalError("Renaming or refresh remounted the drive") }
    print("Mount control persistence and restore tests passed")
  }
}
