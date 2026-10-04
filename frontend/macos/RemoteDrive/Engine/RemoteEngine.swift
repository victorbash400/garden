import Foundation

actor RemoteEngine {
  let api: GardenAPI
  let ranges: GardenRangeCache
  let metadata: RemoteMetadata
  private let mutations: RemoteMutationJournal
  private var mutationTask: Task<Void, Error>?
  private var invalidate: @Sendable ([String]) -> Void = { _ in }
  private var settled: @Sendable () async -> Void = {}
  private var changed: @Sendable () async -> Void = {}
  private var mutationIssue: String?
  private var handles: [UInt64: GardenNode] = [:]
  private var directories: [UInt64: [GardenNode]] = [:]
  private var nextHandle: UInt64 = 1
  private var subscription: RemoteSubscription?
  var issue: String? {
    get async {
      if let mutationIssue { return mutationIssue }
      return await subscription?.issue
    }
  }

  init(domainID: String, state: URL, cache: URL, limit: Int64) throws {
    api = GardenAPI(domainID: domainID)
    ranges = GardenRangeCache(api: api, domainID: domainID, diskLimit: Int(limit), directory: cache)
    metadata = try RemoteMetadata(url: state.appendingPathComponent("metadata.sqlite"), namespace: domainID)
    mutations = try RemoteMutationJournal(url: state.appendingPathComponent("mutations.sqlite"), namespace: domainID)
  }

  func prepare(changed: @escaping @Sendable () async -> Void = {}) async throws {
    self.changed = changed
    if try metadata.revision == nil {
      let revision = try await api.revision()
      try metadata.beginSnapshot()
      do {
        var after = 0
        while true {
          try Task.checkCancellation()
          let page = try await api.snapshot(after: after)
          try metadata.appendSnapshot(page)
          if page.count < 256 { break }
          guard let next = page.last?.id, next > after else { throw GardenAPIError.invalidResponse }
          after = next
        }
        try metadata.finishSnapshot(revision: revision)
      } catch {
        try metadata.discardSnapshot()
        throw error
      }
    }
    try await catchUp()
    try await recoverMutations()
    let stream = RemoteSubscription(api: api, revision: { try await self.currentRevision() }, changed: changed) { change in
      try await self.receive(change)
    }
    subscription = stream
    try await stream.start()
  }

  private func catchUp() async throws {
    while true {
      let changes = try await api.changes(after: metadata.revision ?? 0)
      for change in changes { try receive(change) }
      if changes.count < 256 { break }
    }
  }

  func mutate(_ mutation: RemoteMutation) async throws {
    try await serializeMutation(mutation)
  }

  private func serializeMutation(_ mutation: RemoteMutation?) async throws {
    // Actor methods can interleave at awaits. Wait for the previous request's completion before accepting another intent.
    while let mutationTask { try await mutationTask.value }
    let task = Task { try await self.executeMutation(mutation) }
    mutationTask = task
    try await task.value
  }

  private func executeMutation(_ mutation: RemoteMutation?) async throws {
    defer { mutationTask = nil }
    do {
      try await self.recoverMutations()
      if let mutation {
        try mutations.append(mutation)
        try await recoverMutations()
      }
      mutationIssue = nil
      await changed()
    } catch {
      if try mutations.first() != nil { mutationIssue = error.localizedDescription }
      await changed()
      throw error
    }
  }

  private func recoverMutations() async throws {
    while let pending = try mutations.first() {
      let events: [GardenChange]
      do {
        guard let records = try await api.call("filesystem", "mutate", [
          "gardenId": try await api.streamCredential().driveID, "request": pending.arguments
        ]) as? [[String: Any]] else { throw GardenAPIError.invalidResponse }
        events = try records.map(GardenChange.init(record:))
      } catch GardenAPIError.filesystem(let failure) {
        // A typed backend rejection confirms rollback. Unknown transport failures retain the intent for replay.
        try mutations.acknowledge(pending.operationId)
        throw POSIXError(failure.code)
      }
      for event in events where event.revision > (try metadata.revision ?? 0) {
        if event.revision == (try metadata.revision ?? 0) + 1 {
          try receive(event)
        } else {
          try await catchUp()
          guard (try metadata.revision ?? 0) >= event.revision else { throw GardenAPIError.invalidResponse }
        }
      }
      try mutations.acknowledge(pending.operationId)
    }
  }

  func currentRevision() throws -> Int { try metadata.revision ?? 0 }

  func reconnect() async throws {
    try await serializeMutation(nil)
    try await subscription?.reconnect()
    await settled()
  }

  func path(_ nodeID: Int?) throws -> String {
    guard let nodeID else { return "" }
    var current = nodeID
    var seen: Set<Int> = []
    var names: [String] = []
    while current != 0 {
      guard seen.insert(current).inserted else { throw POSIXError(.ELOOP) }
      guard let node = try metadata.node(current) else { throw POSIXError(.ENOENT) }
      guard !node.name.isEmpty, node.name != ".", node.name != "..", !node.name.contains("/"),
        !node.name.contains("\0") else { throw POSIXError(.EINVAL) }
      names.append(node.name)
      current = node.parentID
    }
    return names.reversed().joined(separator: "/")
  }

  func setInvalidation(_ callback: @escaping @Sendable ([String]) -> Void,
    settled: @escaping @Sendable () async -> Void) {
    invalidate = callback
    self.settled = settled
  }

  func receive(_ change: GardenChange) throws {
    guard change.revision > (try metadata.revision ?? 0) else { return }
    var paths: Set<String> = []
    if let id = change.node?.id, let old = try metadata.node(id) {
      paths.insert(try invalidationPath(old.id))
      paths.insert(try invalidationPath(old.parentID == 0 ? nil : old.parentID))
    }
    try metadata.apply(change)
    if let node = change.node, !node.deleted {
      // FSKit shares an inode's FUSE handle across local descriptors. Content changes must update that handle too.
      for handle in handles.keys where handles[handle]?.id == node.id { handles[handle] = node }
      paths.insert("/" + (try path(node.id)))
      paths.insert("/" + (try path(node.parentID == 0 ? nil : node.parentID)))
    }
    invalidate(Array(paths))
  }

  private func invalidationPath(_ id: Int?) throws -> String {
    do { return "/" + (try path(id)) }
    catch let error as POSIXError where error.code == .ENOENT {
      // Recursive deletion can remove an ancestor before its children. Invalidate the drive root in that case.
      return "/"
    }
  }

  func lookup(_ path: String, handle: UInt64 = 0) throws -> GardenNode? {
    if handle != 0 {
      if directories[handle] != nil { return handles[handle] }
      guard let node = handles[handle] else { throw POSIXError(.EBADF) }
      return node
    }
    return try metadata.lookup(path)
  }

  func open(_ path: String, directory: Bool) throws -> UInt64 {
    let node = try metadata.lookup(path)
    if directory {
      guard node == nil || node!.folder else { throw POSIXError(.ENOTDIR) }
    } else {
      guard let node else { throw POSIXError(.EISDIR) }
      guard !node.folder else { throw POSIXError(.EISDIR) }
    }
    let handle = nextHandle
    nextHandle += 1
    if let node { handles[handle] = node }
    if directory { directories[handle] = try metadata.children(node?.id ?? 0) }
    return handle
  }

  func close(_ handle: UInt64) { handles.removeValue(forKey: handle); directories.removeValue(forKey: handle) }

  func list(_ handle: UInt64) throws -> [GardenNode] {
    guard let nodes = directories[handle] else { throw POSIXError(.EBADF) }
    return nodes
  }

  func read(_ handle: UInt64, offset: Int, length: Int) async throws -> Data {
    guard let node = handles[handle] else { throw POSIXError(.EBADF) }
    return try await ranges.read(node: node, offset: offset, length: length)
  }

  func stop() async { await subscription?.stop(); await ranges.invalidate() }
}

enum RemoteLog {
  static func error(_ error: Error) {
    try? FileHandle.standardError.write(contentsOf: Data(("Garden remote drive: \(error.localizedDescription)\n").utf8))
  }
}
