import Darwin
import Foundation

@main struct WriteRecoveryTests {
  struct Receipt: Codable {
    let operation: UUID
    let generation: Int
    let version: Int?
  }

  static let bytes = Data((0..<(512 * 1024)).map { UInt8($0 % 251) })

  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func engine(_ domain: String, _ root: URL) throws -> RemoteEngine {
    try RemoteEngine(domainID: domain, state: root.appendingPathComponent("state"),
      cache: root.appendingPathComponent("cache"), limit: 0)
  }

  static func main() async {
    setbuf(stdout, nil)
    do {
      let arguments = CommandLine.arguments
      if arguments.count == 6, arguments[1] == "--child" {
        try await crash(domain: arguments[2], root: URL(fileURLWithPath: arguments[3]),
          path: arguments[4], committed: arguments[5] == "committed")
      } else {
        guard arguments.count == 2 else { throw POSIXError(.EINVAL) }
        try await run(arguments[1])
      }
    } catch { print("Write recovery failed: \(error.localizedDescription)"); exit(1) }
  }

  static func crash(domain: String, root: URL, path: String, committed: Bool) async throws {
    let remote = try engine(domain, root)
    try await remote.prepare()
    let handle = try await remote.open(path, directory: false)
    try await remote.write(handle, offset: 0, bytes: bytes, append: false)
    guard let node = try await remote.lookup(path) else { throw POSIXError(.ENOENT) }
    // Freeze the fixture before any timer can acknowledge it. The subprocess exits without close or stop.
    await remote.scheduledPublications[node.id]?.cancel()
    let draft = try await remote.writes.seal(node.id)
    var version: Int?
    if committed {
      let publisher = await RemoteWritePublisher(api: remote.api, ranges: remote.ranges, journal: remote.writes)
      version = try await publisher.publish(draft).version
    }
    let receipt = Receipt(operation: draft.operationID, generation: draft.generation, version: version)
    try JSONEncoder().encode(receipt).write(to: root.appendingPathComponent("receipt.json"), options: .atomic)
    _exit(71)
  }

  static func run(_ domain: String) async throws {
    let api = GardenAPI(domainID: domain)
    let folder = try await api.create(parentID: 0, name: "write-recovery-\(UUID())", folder: true)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-recovery-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    do {
      for committed in [false, true] {
        let name = committed ? "Committed.bin" : "Pending.bin"
        let node = try await api.create(parentID: folder.id, name: name, folder: false)
        let state = root.appendingPathComponent(name)
        let child = Process()
        child.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
        child.arguments = ["--child", domain, state.path, "/\(folder.name)/\(name)", committed ? "committed" : "pending"]
        try child.run()
        child.waitUntilExit()
        try require(child.terminationStatus == 71, "The child must terminate without closing its engine")
        let receipt = try JSONDecoder().decode(Receipt.self, from: Data(contentsOf: state.appendingPathComponent("receipt.json")))
        let recovered = try engine(domain, state)
        guard let draft = try await recovered.writes.state(node.id) else { throw POSIXError(.EIO) }
        try require(draft.operationID == receipt.operation && draft.generation == receipt.generation,
          "Process recovery must preserve the immutable upload identity")
        try require(try await recovered.writes.used == bytes.count, "Unacknowledged bytes must survive process termination")
        try await recovered.prepare()
        let cloud = try await api.get(node.id)
        if let version = receipt.version {
          try require(cloud.version == version, "A committed upload must recover without creating another version")
        }
        try require(cloud.size == bytes.count && cloud.version != 0, "Startup must publish the pending file")
        try require(try await recovered.ranges.read(node: cloud, offset: 0, length: bytes.count) == bytes,
          "Recovered cloud content must match every accepted byte")
        let journal = await recovered.writes
        try require(try journal.used == 0 && journal.pending().isEmpty,
          "Only a confirmed cloud commit may release the recovered journal")
        await recovered.stop()
        print("Abrupt process recovery passed: \(name)")
      }
      try await api.delete(folder.id)
    } catch {
      try await api.delete(folder.id)
      throw error
    }
  }
}
