import Foundation

@main struct MountTests {
  static func node(_ name: String) throws -> GardenNode {
    try GardenNode(["id": 1, "parentId": 0, "name": name, "kind": "file", "size": 0,
      "version": 1, "updatedAt": "2026-10-04T10:00:00.000Z", "deleted": false])
  }

  static func main() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-mounts-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let cache = root.appendingPathComponent("cache")
    let first = try RemoteEngine(domainID: "account-a-drive-1", state: root.appendingPathComponent("a"), cache: cache, limit: 0)
    let second = try RemoteEngine(domainID: "account-b-drive-1", state: root.appendingPathComponent("b"), cache: cache, limit: 0)
    try await first.metadata.reset(nodes: [node("Account A.txt")], revision: 0)
    try await second.metadata.reset(nodes: [node("Account B.txt")], revision: 0)
    let a = try await RemoteMount.start(engine: first, path: "/Volumes/GardenIsolationA", name: "Garden Isolation A")
    let b: RemoteMount
    do { b = try await RemoteMount.start(engine: second, path: "/Volumes/GardenIsolationB", name: "Garden Isolation B") }
    catch { a.stop(); throw error }
    let loops = Task {
      try await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask { try await a.run() }
        group.addTask { try await b.run() }
        try await group.waitForAll()
      }
    }
    do {
      let namesA = try FileManager.default.contentsOfDirectory(atPath: "/Volumes/GardenIsolationA")
      let namesB = try FileManager.default.contentsOfDirectory(atPath: "/Volumes/GardenIsolationB")
      guard namesA == ["Account A.txt"], namesB == ["Account B.txt"] else { throw GardenAPIError.invalidResponse }
      guard try Data(contentsOf: URL(fileURLWithPath: "/Volumes/GardenIsolationA/Account A.txt")).isEmpty,
        try Data(contentsOf: URL(fileURLWithPath: "/Volumes/GardenIsolationB/Account B.txt")).isEmpty else { throw GardenAPIError.invalidResponse }
      a.stop()
      a.stop()
      guard try FileManager.default.contentsOfDirectory(atPath: "/Volumes/GardenIsolationB") == ["Account B.txt"] else { throw GardenAPIError.invalidResponse }
      b.stop()
      try await loops.value
      await first.stop()
      await second.stop()
      print("Native mounts: simultaneous account isolation, empty-file reads, independent unmount, and repeated stop passed")
    } catch {
      a.stop()
      b.stop()
      _ = try? await loops.value
      await first.stop()
      await second.stop()
      throw error
    }
  }
}
