import Foundation

@main struct LargeDirectoryTests {
  static func node(_ id: Int, parent: Int, name: String, folder: Bool) throws -> GardenNode {
    try GardenNode(["id": id, "parentId": parent, "name": name, "kind": folder ? "folder" : "file",
      "size": 0, "version": 0, "updatedAt": "2026-10-04T12:00:00.000Z", "deleted": false])
  }

  static func main() async throws {
    let identity = "directory-test-\(UUID())"
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(identity)
    defer { try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: identity, state: root, cache: root.appendingPathComponent("cache"), limit: 0)
    var nodes = try (1...4000).map { try node($0, parent: 0, name: "File-\($0).bin", folder: false) }
    nodes.append(try node(4001, parent: 0, name: "Empty", folder: true))
    nodes.append(try node(4002, parent: 0, name: "Nested", folder: true))
    nodes.append(try node(4003, parent: 4002, name: "Child", folder: true))
    try await engine.metadata.reset(nodes: nodes, revision: 0)
    let path = "/Volumes/GardenDirectoryTest-\(UUID())"
    let mount = try await RemoteMount.start(engine: engine, path: path, name: "Garden Directory Test")
    let loop = Task { try await mount.run() }
    do {
      let started = ContinuousClock.now
      let names = try FileManager.default.contentsOfDirectory(atPath: path)
      guard Set(names) == Set(nodes.filter { $0.parentID == 0 }.map(\.name)) else { throw POSIXError(.EIO) }
      print("Mounted enumeration of 4,002 entries: \(started.duration(to: .now))")
      let navigation = ContinuousClock.now
      for _ in 0..<50 {
        guard try FileManager.default.contentsOfDirectory(atPath: path + "/Empty").isEmpty,
          try FileManager.default.contentsOfDirectory(atPath: path + "/Nested") == ["Child"],
          try FileManager.default.contentsOfDirectory(atPath: path + "/Nested/Child").isEmpty else { throw POSIXError(.EIO) }
      }
      print("150 mounted folder enumerations: \(navigation.duration(to: .now))")
      guard await engine.ranges.remoteBytes == 0 else { throw POSIXError(.EIO) }
      try await mount.unmount()
      try await loop.value
      await engine.stop()
      guard !FileManager.default.fileExists(atPath: path) else { throw POSIXError(.EIO) }
      print("Large directory, repeated empty-folder navigation, no cloud credential or payload reads, and clean unmount passed")
    } catch {
      mount.stop()
      _ = try? await loop.value
      await engine.stop()
      throw error
    }
  }
}
