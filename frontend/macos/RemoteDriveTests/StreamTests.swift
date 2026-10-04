import Foundation

actor StreamProbe {
  let metadata: RemoteMetadata
  let events: AsyncStream<GardenChange>
  private let continuation: AsyncStream<GardenChange>.Continuation

  init(url: URL, namespace: String) throws {
    metadata = try RemoteMetadata(url: url, namespace: namespace)
    (events, continuation) = AsyncStream.makeStream(bufferingPolicy: .bufferingNewest(256))
  }

  func reset(_ nodes: [GardenNode], revision: Int) throws { try metadata.reset(nodes: nodes, revision: revision) }
  func revision() throws -> Int { try metadata.revision ?? 0 }
  func receive(_ change: GardenChange) throws {
    try metadata.apply(change)
    continuation.yield(change)
  }
  func node(_ id: Int) throws -> GardenNode? { try metadata.node(id) }
}

@main struct StreamTests {
  static func next(_ stream: AsyncStream<GardenChange>, nodeID: Int, operation: String) async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
      group.addTask {
        for await change in stream where change.node?.id == nodeID && change.operation == operation { return }
        throw GardenAPIError.invalidResponse
      }
      group.addTask {
        try await Task.sleep(for: .seconds(20))
        throw URLError(.timedOut)
      }
      try await group.next()
      group.cancelAll()
    }
  }

  static func main() async throws {
    guard CommandLine.arguments.count == 2 else { throw POSIXError(.EINVAL) }
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-stream-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let api = GardenAPI(domainID: CommandLine.arguments[1])
    let probe = try StreamProbe(url: root.appendingPathComponent("metadata.sqlite"), namespace: CommandLine.arguments[1])
    let revision = try await api.revision()
    var nodes: [GardenNode] = []
    var cursor = 0
    while true {
      let page = try await api.snapshot(after: cursor)
      nodes.append(contentsOf: page)
      if page.count < 256 { break }
      guard let next = page.last?.id, next > cursor else { throw GardenAPIError.invalidResponse }
      cursor = next
    }
    try await probe.reset(nodes, revision: revision)
    let subscription = RemoteSubscription(api: api, revision: { try await probe.revision() }) { change in
      try await probe.receive(change)
    }
    try await subscription.start()
    let events = probe.events
    var fixture: Int?
    do {
      let folder = try await api.create(parentID: 0, name: "remote-stream-test-\(UUID())", folder: true)
      fixture = folder.id
      try await next(events, nodeID: folder.id, operation: "create")
      guard try await probe.node(folder.id)?.name == folder.name else { throw GardenAPIError.invalidResponse }
      try await subscription.reconnect()
      let moved = try await api.move(id: folder.id, parentID: 0, name: folder.name + "-renamed")
      try await next(events, nodeID: folder.id, operation: "move")
      guard try await probe.node(folder.id)?.name == moved.name else { throw GardenAPIError.invalidResponse }
      try await api.delete(folder.id)
      fixture = nil
      try await next(events, nodeID: folder.id, operation: "delete")
      guard try await probe.node(folder.id) == nil else { throw GardenAPIError.invalidResponse }
      await subscription.stop()
      print("Hosted stream: authenticated replay, create, explicit reconnect, rename, delete, and local metadata updates passed")
    } catch {
      await subscription.stop()
      if let fixture { try await api.delete(fixture) }
      throw error
    }
  }
}
