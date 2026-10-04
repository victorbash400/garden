import Foundation

@main struct ConnectionRecoveryTests {
  static func main() async throws {
    setbuf(stdout, nil)
    guard CommandLine.arguments.count == 2 else { throw POSIXError(.EINVAL) }
    let domain = CommandLine.arguments[1]
    let api = GardenAPI(domainID: domain)
    let folder = try await api.create(parentID: 0, name: "connection-recovery-\(UUID())", folder: true)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-connection-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: domain, state: root, cache: root.appendingPathComponent("cache"), limit: 0)
    var subscription: RemoteSubscription?
    do {
      let file = try await api.create(parentID: folder.id, name: "Recovered.bin", folder: false)
      try await engine.prepare()
      await engine.stop()
      let handle = try await engine.open("/\(folder.name)/Recovered.bin", directory: false)
      try await engine.write(handle, offset: 0, bytes: Data([1, 2, 3, 4]), append: false)
      await engine.scheduledPublications[file.id]?.cancel()
      let stream = RemoteSubscription(api: engine.api, revision: { try await engine.currentRevision() },
        connected: { await engine.connectionRestored() }) { change in try await engine.receive(change) }
      subscription = stream
      try await stream.start()
      let first = try await api.get(file.id)
      guard first.size == 4, try await engine.writes.pending().isEmpty,
        try await api.read(id: file.id, version: first.version, offset: 0, length: 4) == Data([1, 2, 3, 4]) else {
        throw POSIXError(.EIO)
      }
      try await engine.write(handle, offset: 1, bytes: Data([9, 8]), append: false)
      await engine.scheduledPublications[file.id]?.cancel()
      try await stream.reconnect()
      let second = try await api.get(file.id)
      guard second.version != first.version, try await engine.writes.pending().isEmpty,
        try await api.read(id: file.id, version: second.version, offset: 0, length: 4) == Data([1, 9, 8, 4]) else {
        throw POSIXError(.EIO)
      }
      await stream.stop()
      let revision = try await engine.currentRevision()
      let moved = try await api.move(id: file.id, parentID: folder.id, name: "Moved.bin")
      let nested = try await api.create(parentID: folder.id, name: "Offline-folder", folder: true)
      let replay = try await RemoteChanges.connect(api: api, revision: revision) { change in try await engine.receive(change) }
      replay.close()
      guard try await engine.lookup("/\(folder.name)/Moved.bin")?.id == moved.id,
        try await engine.lookup("/\(folder.name)/Offline-folder")?.id == nested.id else { throw POSIXError(.EIO) }
      try await engine.close(handle)
      await engine.stop()
      try await api.delete(folder.id)
      print("Connection recovery: pending edits publish on connection and reconnection; disconnected rename/create replay updates local paths")
    } catch {
      await subscription?.stop()
      await engine.stop()
      try await api.delete(folder.id)
      throw error
    }
  }
}
