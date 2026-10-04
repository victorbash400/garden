import Foundation
import Security

@main struct WriteFailureTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-write-failure-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let state = root.appendingPathComponent("state")
    let identity = "uncredentialed-test-\(UUID())"
    let engine = try RemoteEngine(domainID: identity, state: state, cache: root.appendingPathComponent("cache"), limit: 0, writeLimit: 1024)
    let node = try GardenNode(["id": 1, "parentId": 0, "name": "Pending.bin", "kind": "file", "size": 0,
      "version": 0, "updatedAt": "2026-10-04T12:00:00.000Z", "deleted": false])
    try await engine.metadata.reset(nodes: [node], revision: 0)
    let handle = try await engine.open("/Pending.bin", directory: false)
    let bytes = Data([1, 2, 3, 4])
    try await engine.write(handle, offset: 0, bytes: bytes, append: false)
    guard let scheduled = await engine.scheduledPublications[node.id] else { throw POSIXError(.EIO) }
    await scheduled.value
    guard let pending = try await engine.writes.state(node.id) else { throw POSIXError(.EIO) }
    try require(pending.sealed && pending.size == bytes.count, "An authorization failure must retain sealed pending bytes")
    try require(await engine.issue != nil, "Publication failure must be visible")
    try require(try await engine.read(handle, offset: 0, length: bytes.count) == bytes, "Pending data must remain readable without cloud credentials")
    do {
      try await engine.write(handle, offset: 0, bytes: Data([9]), append: false)
      throw NSError(domain: "RemoteTests", code: 2)
    } catch FinderCredentialError.keychain(let status) {
      try require(status == errSecItemNotFound, "The test identity must have no stored credential")
    }
    try require(try await engine.read(handle, offset: 0, length: bytes.count) == bytes, "A rejected write must not change accepted bytes")
    do {
      try await engine.close(handle)
      throw NSError(domain: "RemoteTests", code: 3)
    } catch FinderCredentialError.keychain(let status) {
      try require(status == errSecItemNotFound, "Failed close must report the missing credential")
    }
    await engine.stop()
    let reopened = try RemoteEngine(domainID: identity, state: state, cache: root.appendingPathComponent("cache"), limit: 0, writeLimit: 1024)
    let retained = try await reopened.writes.state(node.id)
    try require(retained?.operationID == pending.operationID && retained?.generation == pending.generation,
      "Restart must preserve the retry identity after a failed close")
    try require(try await reopened.writes.used == bytes.count, "Failure must not release uncommitted staging bytes")
    await reopened.stop()
    print("Write failure: event-triggered publication, visible authorization error, retained reads, rejected-write atomicity, failed close and restart identity passed")
  }
}
