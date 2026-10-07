import Foundation

extension RemoteEngine {
  func validatePaths() throws {
    func require(_ value: Bool) throws { if !value { throw POSIXError(.EIO) } }
    func node(_ id: Int, parent: Int, name: String, deleted: Bool = false) throws -> GardenNode {
      try GardenNode(["id": id, "parentId": parent, "name": name, "kind": "folder", "size": 0,
        "version": 1, "updatedAt": "2026-10-07T00:00:00.000Z", "deleted": deleted])
    }
    var nodes: [GardenNode] = []
    for id in 1...8 { nodes.append(try node(id, parent: id - 1, name: id == 4 ? "Photos ü" : "Folder \(id)")) }
    try metadata.reset(nodes: nodes, revision: 1)
    let expected = nodes.map(\.name).joined(separator: "/")
    try require(try path(8) == expected && path(nil) == "" && path(0) == "")
    let started = ContinuousClock.now
    for _ in 0..<10_000 { try require(try path(8) == expected) }
    print("10000 eight-level paths: \(started.duration(to: .now))")
    try receive(GardenChange(revision: 2, operation: "move", node: try node(4, parent: 0, name: "Renamed ü"), previousParentID: 3))
    try require(try path(8) == "Renamed ü/Folder 5/Folder 6/Folder 7/Folder 8")
    try receive(GardenChange(revision: 3, operation: "delete", node: try node(4, parent: 0, name: "Renamed ü", deleted: true), previousParentID: 0))
    do { _ = try path(8); throw POSIXError(.EIO) }
    catch let error as POSIXError { try require(error.code == .ENOENT) }
    try metadata.reset(nodes: [node(1, parent: 2, name: "A"), node(2, parent: 1, name: "B")], revision: 1)
    do { _ = try path(1); throw POSIXError(.EIO) }
    catch let error as POSIXError { try require(error.code == .ELOOP) }
    for name in ["", ".", "..", "a/b", "before\0after"] {
      try metadata.reset(nodes: [node(1, parent: 0, name: name)], revision: 1)
      do { _ = try path(1); throw POSIXError(.EIO) }
      catch let error as POSIXError { try require(error.code == .EINVAL) }
    }
    print("Path rename, Unicode, missing ancestors, cycles and invalid names passed")
  }
}

@main struct PathReadTests {
  static func main() async throws {
    setbuf(stdout, nil)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-path-tests-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: "path-tests", state: root, cache: root.appendingPathComponent("cache"), limit: 0)
    try await engine.validatePaths()
    await engine.stop()
  }
}
