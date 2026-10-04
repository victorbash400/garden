import Foundation

@main struct MetadataTests {
  static func node(_ id: Int, parent: Int = 0, name: String, folder: Bool = false,
    version: Int = 1, deleted: Bool = false) throws -> GardenNode {
    try GardenNode(["id": id, "parentId": parent, "name": name, "kind": folder ? "folder" : "file",
      "size": folder ? 0 : 5_000_000_000, "version": version, "updatedAt": "2026-10-04T10:00:00.000Z", "deleted": deleted])
  }

  static func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("garden-metadata-\(UUID())")
    defer { try? FileManager.default.removeItem(at: directory) }
    let url = directory.appendingPathComponent("metadata.sqlite")
    let metadata = try RemoteMetadata(url: url, namespace: "test")
    var nodes = [try node(1, name: "Videos", folder: true), try node(2, name: "Empty", folder: true)]
    for id in 3...4002 { nodes.append(try node(id, parent: 1, name: "Movie \(id).mov")) }
    try metadata.reset(nodes: nodes, revision: 50)
    try require(try metadata.children(1).count == 4000, "Large directory must not truncate")
    try require(try metadata.children(2).isEmpty, "Empty directory must be valid")
    try require(try metadata.lookup("/videos/MOVIE 3.MOV")?.size == 5_000_000_000, "Case-insensitive lookup and 64-bit size")
    let moved = try node(3, parent: 2, name: "Moved.mov", version: 2)
    try metadata.apply(GardenChange(revision: 51, operation: "move", node: moved, previousParentID: 1))
    try require(try metadata.children(1).count == 3999 && metadata.children(2).count == 1, "Move must update both parents")
    try metadata.apply(GardenChange(revision: 51, operation: "move", node: moved, previousParentID: 1))
    try require(try metadata.revision == 51, "Replay must be idempotent")
    do {
      try metadata.apply(GardenChange(revision: 53, operation: "delete", node: try node(3, name: "Moved.mov", deleted: true), previousParentID: nil))
      throw NSError(domain: "RemoteTests", code: 2)
    } catch GardenAPIError.invalidResponse {}
    try require(try metadata.revision == 51 && metadata.node(3) != nil, "Gap must roll back without data loss")
    try metadata.apply(GardenChange(revision: 52, operation: "delete", node: try node(3, name: "Moved.mov", deleted: true), previousParentID: nil))
    let reopened = try RemoteMetadata(url: url, namespace: "test")
    try require(try reopened.revision == 52 && reopened.node(3) == nil, "Revision and deletion must survive restart")
    do {
      _ = try RemoteMetadata(url: url, namespace: "other-account-drive")
      throw NSError(domain: "RemoteTests", code: 5)
    } catch let error as NSError {
      try require(error.domain == "GardenRemoteMetadata", "Index must reject another drive's identity")
    }
    do { _ = try metadata.lookup("/Videos/../Empty"); throw NSError(domain: "RemoteTests", code: 3) }
    catch let error as POSIXError { try require(error.code == .EINVAL, "Traversal must fail") }
    let engine = try RemoteEngine(domainID: "test", state: directory, cache: directory.appendingPathComponent("blocks"), limit: 0)
    let handle = try await engine.open("/Videos/Movie 4.mov", directory: false)
    try await engine.receive(GardenChange(revision: 53, operation: "update", node: try node(4, parent: 1, name: "Movie 4.mov", version: 2), previousParentID: nil))
    let old = try await engine.lookup("", handle: handle)
    let fresh = try await engine.lookup("/Videos/Movie 4.mov")
    try require(old?.version == 1 && fresh?.version == 2, "Open handles must retain their immutable version")
    let empty = try await engine.open("/Empty", directory: true)
    try require(try await engine.list(empty).isEmpty, "Empty folder must open")
    await engine.close(handle)
    do { _ = try await engine.lookup("", handle: handle); throw NSError(domain: "RemoteTests", code: 4) }
    catch let error as POSIXError { try require(error.code == .EBADF, "Closed handles must fail") }
    print("Remote metadata: large directories, empty folders, move/delete, restart, revision gaps, and immutable handles passed")
  }
}
