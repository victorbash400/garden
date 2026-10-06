import Foundation

@main struct DriveCursorTests {
  static func main() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-cursor-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let metadata = try RemoteMetadata(url: root.appendingPathComponent("metadata.sqlite"), namespace: "cursor-test")
    try metadata.beginSnapshot()
    try metadata.finishSnapshot(revision: 553)
    for revision in 554...556 {
      try metadata.apply(GardenChange(revision: revision, operation: "chat", node: nil, previousParentID: nil))
    }
    guard try metadata.revision == 556 else { throw POSIXError(.EIO) }
    try metadata.apply(GardenChange(revision: 557, operation: "permissions", node: nil, previousParentID: nil))
    do {
      try metadata.apply(GardenChange(revision: 558, operation: "unknown", node: nil, previousParentID: nil))
      throw POSIXError(.EIO)
    } catch GardenAPIError.invalidResponse { }
    guard try metadata.revision == 557 else { throw POSIXError(.EIO) }
    print("Drive cursor: chat and permission events advance; unknown events fail without changing the cursor")
  }
}
