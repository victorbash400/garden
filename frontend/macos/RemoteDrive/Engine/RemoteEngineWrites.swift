import Foundation

extension RemoteEngine {
  func setBirthtime(_ name: String?, handle: UInt64, date: Date) async throws {
    try await setAttributes(name, handle: handle, created: date, modified: nil, attributes: nil)
  }

  func write(_ handle: UInt64, offset: Int, bytes: Data, append: Bool) async throws {
    guard let original = try lookup("/", handle: handle), !original.folder else { throw POSIXError(.EISDIR) }
    if let pending = publications[original.id] { try await pending.value }
    if try writes.state(original.id)?.sealed == true { try await publish(original.id) }
    guard let node = try lookup("/", handle: handle) else { throw POSIXError(.EBADF) }
    guard try metadata.node(node.id) != nil else { throw POSIXError(.ENOENT) }
    let position = append ? node.size : offset
    do { try writes.write(node, offset: position, bytes: bytes) }
    catch let error as POSIXError where error.code == .ENOSPC {
      try await flushAll()
      guard let current = try lookup("/", handle: handle) else { throw POSIXError(.EBADF) }
      try writes.write(current, offset: append ? current.size : offset, bytes: bytes)
    }
    schedulePublication(node.id)
  }

  func truncate(_ path: String, handle: UInt64, size: Int) async throws {
    guard let original = try lookup(path, handle: handle), !original.folder else { throw POSIXError(.EISDIR) }
    if original.size == size { return }
    if let pending = publications[original.id] { try await pending.value }
    if try writes.state(original.id)?.sealed == true { try await publish(original.id) }
    guard let current = try lookup(path, handle: handle) else { throw POSIXError(.ENOENT) }
    guard try metadata.node(current.id) != nil else { throw POSIXError(.ENOENT) }
    try writes.truncate(current, size: size)
    schedulePublication(current.id)
  }

  func flush(_ handle: UInt64) async throws {
    guard let node = try lookup("/", handle: handle) else { throw POSIXError(.EBADF) }
    if !node.folder { try await publish(node.id) }
  }

  func flushAll() async throws {
    for draft in try writes.pending() { try await publish(draft.base.id) }
  }

  func publish(_ node: Int) async throws {
    scheduledPublications.removeValue(forKey: node)?.cancel()
    if let pending = publications[node] { try await pending.value; return }
    guard try writes.state(node) != nil else { return }
    let pending = Task { try await self.publishDraft(node) }
    publications[node] = pending
    defer { publications.removeValue(forKey: node) }
    try await pending.value
  }

  func schedulePublication(_ node: Int) {
    scheduledPublications.removeValue(forKey: node)?.cancel()
    scheduledPublications[node] = Task {
      do { try await Task.sleep(for: .seconds(2)) }
      catch { return }
      self.scheduledPublications.removeValue(forKey: node)
      do { try await self.publish(node) }
      catch { RemoteLog.error(error) }
    }
  }

  private func publishDraft(_ node: Int) async throws {
    do {
      let draft = try writes.seal(node)
      let publisher = RemoteWritePublisher(api: api, ranges: ranges, journal: writes)
      let started = Date()
      let committed = try await publisher.publish(draft)
      await GardenActivity.shared.record(domain: activityDomain, name: draft.base.name, action: "Upload",
        source: "Remote disk", bytes: draft.size, milliseconds: Date().timeIntervalSince(started) * 1000)
      try await catchUp()
      try writes.acknowledge(draft)
      if committed.id != node {
        throw NSError(domain: "GardenWriteConflict", code: Int(EEXIST), userInfo:
          [NSLocalizedDescriptionKey: "Edits to \(draft.base.name) were saved as \(committed.name)."])
      }
      await writeStatus(nil, paths: ["/" + (try path(node))])
    } catch {
      await writeStatus(error.localizedDescription)
      throw error
    }
  }
}
