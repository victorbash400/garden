import Foundation

actor RemoteEngine {
  let api: GardenAPI
  let ranges: GardenRangeCache
  let metadata: RemoteMetadata
  private let mutations: RemoteMutationJournal
  let writes: RemoteWriteJournal
  var publications: [Int: Task<Void, Error>] = [:]
  var scheduledPublications: [Int: Task<Void, Never>] = [:]
  private var writeIssue: String?
  private var mutationTask: Task<Void, Error>?
  private var invalidate: @Sendable ([String]) -> Void = { _ in }
  private var settled: @Sendable () async -> Void = {}
  private var changed: @Sendable () async -> Void = {}
  private var mutationIssue: String?
  private var handles: [UInt64: GardenNode] = [:]
  private var directories: [UInt64: [GardenNode]] = [:]
  private var nextHandle: UInt64 = 1
  private var subscription: RemoteSubscription?
  private var driveRole: RemoteDrivePermission?
  var issue: String? {
    get async {
      if let writeIssue { return writeIssue }
      if let mutationIssue { return mutationIssue }
      return await subscription?.issue
    }
  }

  let activityDomain: String

  init(domainID: String, state: URL, cache: URL, limit: Int64, writeLimit: Int = 256 * 1024 * 1024) throws {
    activityDomain = domainID
    api = GardenAPI(domainID: domainID)
    ranges = GardenRangeCache(api: api, domainID: domainID, diskLimit: Int(limit), directory: cache)
    metadata = try RemoteMetadata(url: state.appendingPathComponent("metadata.sqlite"), namespace: domainID)
    mutations = try RemoteMutationJournal(url: state.appendingPathComponent("mutations.sqlite"), namespace: domainID)
    writes = try RemoteWriteJournal(url: state.appendingPathComponent("writes.sqlite"), namespace: domainID, limit: writeLimit)
  }

  func prepare(changed: @escaping @Sendable () async -> Void = {}) async throws {
    self.changed = changed
    try await refreshPermission()
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
    if driveRole != .viewer {
      try await recoverMutations()
      try await flushAll()
    }
    let stream = RemoteSubscription(api: api, revision: { try await self.currentRevision() }, changed: { await self.subscriptionChanged() },
      connected: { await self.connectionRestored() }) { change in
      if change.operation == "permissions" { try await self.refreshPermission() }
      try await self.receive(change)
    }
    subscription = stream
    try await stream.start()
  }

  func catchUp() async throws {
    while true {
      let changes = try await api.changes(after: metadata.revision ?? 0)
      for change in changes {
        if change.operation == "permissions" { try await refreshPermission() }
        try receive(change)
      }
      if changes.count < 256 { break }
    }
  }

  func mutate(_ mutation: RemoteMutation) async throws {
    try requireWrite()
    if mutation.operation == .unlink || mutation.operation == .rename {
      if let node = try metadata.lookup(mutation.path), !node.folder { try await publish(node.id) }
      if let destination = mutation.destination {
        let target: GardenNode?
        do { target = try metadata.lookup(destination) }
        catch let error as POSIXError where error.code == .ENOENT { target = nil }
        if let target, !target.folder { try await publish(target.id) }
      }
    }
    try await serializeMutation(mutation)
    let action: String?
    switch mutation.operation {
    case .createFile, .createFolder: action = "Create"
    case .rename: action = "Rename"
    case .unlink, .rmdir: action = "Delete"
    default: action = nil
    }
    if let action { await GardenActivity.shared.record(domain: activityDomain, name: mutation.destination ?? mutation.path, action: action) }
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
    try await refreshPermission()
    if driveRole != .viewer {
      try await serializeMutation(nil)
      try await flushAll()
    }
    try await subscription?.reconnect()
    await settled()
  }

  func connectionRestored() async {
    do {
      try await refreshPermission()
      if driveRole != .viewer { try await flushAll() }
    }
    catch { RemoteLog.error(error) }
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
    try requireRead()
    if handle != 0 {
      if directories[handle] != nil { return try visible(handles[handle]) }
      guard let node = handles[handle] else { throw POSIXError(.EBADF) }
      return try visible(node)
    }
    return try visible(metadata.lookup(path))
  }

  func open(_ path: String, directory: Bool) throws -> UInt64 {
    try requireRead()
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
    if !directory {
      Task { await GardenActivity.shared.record(domain: activityDomain, name: path, action: "Open") }
    }
    return handle
  }

  func close(_ handle: UInt64) async throws {
    defer { handles.removeValue(forKey: handle); directories.removeValue(forKey: handle) }
    if let node = handles[handle], !node.folder { try await publish(node.id) }
  }

  func list(_ handle: UInt64) throws -> [GardenNode] {
    try requireRead()
    guard let nodes = directories[handle] else { throw POSIXError(.EBADF) }
    return try nodes.map { try visible($0)! }
  }

  func read(_ handle: UInt64, offset: Int, length: Int) async throws -> Data {
    try requireRead()
    guard let node = handles[handle] else { throw POSIXError(.EBADF) }
    if let draft = try writes.state(node.id) {
      let bytes = try await RemoteWriteReader.read(draft, journal: writes, ranges: ranges, offset: offset, length: length)
      try requireRead()
      return bytes
    }
    let bytes = try await ranges.read(node: node, offset: offset, length: length, path: try path(node.id))
    try requireRead()
    return bytes
  }

  func stop() async {
    for task in scheduledPublications.values { task.cancel() }
    scheduledPublications.removeAll()
    await subscription?.stop()
    await ranges.invalidate()
  }

  private func visible(_ node: GardenNode?) throws -> GardenNode? {
    guard var node else { return nil }
    if let draft = try writes.state(node.id) {
      node.size = draft.size
      node.modifiedDate = draft.modified
    }
    if driveRole == .viewer {
      var attributes = node.attributes ?? GardenFileAttributes()
      attributes.permissions = (attributes.permissions ?? (node.folder ? 0o755 : 0o644)) & 0o555
      node.attributes = attributes
    }
    return node
  }

  func requireRead() throws {
    guard driveRole != nil else { throw POSIXError(.EACCES) }
  }

  func requireWrite() throws {
    try requireRead()
    guard driveRole != .viewer else { throw POSIXError(.EROFS) }
  }

  private func refreshPermission() async throws {
    driveRole = nil
    do {
      let credential = try await api.streamCredential()
      guard let value = try await api.call("garden", "connect", ["gardenId": credential.driveID]) as? [String: Any],
        let role = value["role"] as? String else {
        throw GardenAPIError.invalidResponse
      }
      driveRole = try RemoteDrivePermission(role: role)
      invalidate(["/"])
    } catch {
      driveRole = nil
      await ranges.invalidate()
      invalidate(["/"])
      throw error
    }
  }

  private func subscriptionChanged() async {
    if await subscription?.issue != nil {
      driveRole = nil
      await ranges.invalidate()
      invalidate(["/"])
    }
    await changed()
  }

  func writeStatus(_ issue: String?, paths: [String] = []) async {
    writeIssue = issue
    if !paths.isEmpty { invalidate(paths) }
    await changed()
  }
}

enum RemoteLog {
  static func error(_ error: Error) {
    try? FileHandle.standardError.write(contentsOf: Data(("Garden remote drive: \(error.localizedDescription)\n").utf8))
  }
}


enum RemoteDrivePermission: Sendable {
  case owner, manager, editor, viewer

  init(role: String) throws {
    switch role {
    case "Owner": self = .owner
    case "Manager": self = .manager
    case "Editor", "Member": self = .editor
    case "Viewer": self = .viewer
    default: throw GardenAPIError.invalidResponse
    }
  }
}
