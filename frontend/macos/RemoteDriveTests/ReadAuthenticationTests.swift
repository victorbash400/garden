import Foundation

actor ReadAuthorizationProbe {
  private var authorized = false
  func allow() { authorized = true }
  func read(offset: Int, length: Int) throws -> Data {
    guard authorized else { throw GardenAPIError.unauthorized }
    return Data((offset..<(offset + length)).map { UInt8($0 % 251) })
  }
}

@main struct ReadAuthenticationTests {
  static func main() async throws {
    setbuf(stdout, nil)
    guard CommandLine.arguments.count == 2 else { throw POSIXError(.EINVAL) }
    let source = CommandLine.arguments[1]
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-read-auth-test-\(UUID())")
    let probe = ReadAuthorizationProbe()
    let engine = try RemoteEngine(domainID: source, state: root, cache: root.appendingPathComponent("cache"), limit: 0,
      readRange: { _, offset, length in try await probe.read(offset: offset, length: length) })
    do {
      try await engine.prepare()
      let nodes = try await engine.api.snapshot(after: 0)
      guard let node = nodes.first(where: { !$0.folder && $0.size >= 16 }) else { throw POSIXError(.ENOENT) }
      let path = try await engine.path(node.id)
      let handle = try await engine.open("/" + path, directory: false)
      do {
        _ = try await engine.read(handle, offset: 0, length: 16)
        throw POSIXError(.EIO)
      } catch GardenAPIError.unauthorized {}
      guard await engine.issue == GardenAPIError.unauthorized.localizedDescription else { throw POSIXError(.EIO) }
      await probe.allow()
      try await engine.reconnect()
      guard await engine.issue == nil else { throw POSIXError(.EIO) }
      let bytes = try await engine.read(handle, offset: 0, length: 16)
      guard bytes == Data((0..<16).map(UInt8.init)) else { throw POSIXError(.EIO) }
      try await engine.close(handle)
      await engine.stop()
      try FileManager.default.removeItem(at: root)
      print("Read authentication: injected unauthorized range surfaces drive issue; real reconnection clears it; subsequent read returns exact bytes")
    } catch {
      await engine.stop()
      try FileManager.default.removeItem(at: root)
      throw error
    }
  }
}
