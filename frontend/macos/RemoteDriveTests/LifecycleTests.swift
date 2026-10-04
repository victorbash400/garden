import Foundation

@main struct LifecycleTests {
  static func main() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("garden-lifecycle-\(UUID())")
    defer { try? FileManager.default.removeItem(at: directory) }
    let path = "/Volumes/GardenLifecycle-\(UUID().uuidString)"
    for external in [false, false, false, true] {
      let engine = try RemoteEngine(domainID: "lifecycle", state: directory,
        cache: directory.appendingPathComponent("cache"), limit: 0)
      try await engine.metadata.reset(nodes: [], revision: 0)
      let mount = try await RemoteMount.start(engine: engine, path: path, name: "Garden Lifecycle")
      guard try FileManager.default.contentsOfDirectory(atPath: path).isEmpty else { throw POSIXError(.EIO) }
      if external {
        try await Task.detached {
          let process = Process()
          process.executableURL = URL(fileURLWithPath: "/sbin/umount")
          process.arguments = [path]
          try process.run()
          process.waitUntilExit()
          guard process.terminationStatus == 0 else { throw POSIXError(.EIO) }
        }.value
      } else {
        mount.stop()
        mount.stop()
      }
      try await mount.run()
      await engine.stop()
      guard !FileManager.default.fileExists(atPath: path) else {
        throw NSError(domain: "GardenLifecycle", code: 1,
          userInfo: [NSLocalizedDescriptionKey: "Unmount left a stale mount directory at \(path)"])
      }
    }
    print("Mount lifecycle: four mounts at the same path, repeated stop, external unmount, and complete directory cleanup passed")
  }
}
