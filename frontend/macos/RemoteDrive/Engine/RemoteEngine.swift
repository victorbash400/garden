import Foundation

actor RemoteEngine {
  let api: GardenAPI
  let ranges: GardenRangeCache
  let metadata: RemoteMetadata
  private var handles: [UInt64: GardenNode] = [:]
  private var directories: [UInt64: [GardenNode]] = [:]
  private var nextHandle: UInt64 = 1
  private var subscription: RemoteSubscription?
  var issue: String? { get async { await subscription?.issue } }

  init(domainID: String, state: URL, cache: URL, limit: Int64) throws {
    api = GardenAPI(domainID: domainID)
    ranges = GardenRangeCache(api: api, domainID: domainID, diskLimit: Int(limit), directory: cache)
    metadata = try RemoteMetadata(url: state.appendingPathComponent("metadata.sqlite"), namespace: domainID)
  }

  func prepare(changed: @escaping @Sendable () async -> Void = {}) async throws {
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
    // Catch up once before mount. Subsequent changes arrive through the stream.
    while true {
      let changes = try await api.changes(after: metadata.revision ?? 0)
      for change in changes { try metadata.apply(change) }
      if changes.count < 256 { break }
    }
    let stream = RemoteSubscription(api: api, revision: { try await self.currentRevision() }, changed: changed) { change in
      try await self.receive(change)
    }
    subscription = stream
    try await stream.start()
  }

  func currentRevision() throws -> Int { try metadata.revision ?? 0 }

  func reconnect() async throws { try await subscription?.reconnect() }

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

  func receive(_ change: GardenChange) throws { try metadata.apply(change) }

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
