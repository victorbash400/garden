import Darwin
import Foundation

@main struct WritePublisherTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async {
    setbuf(stdout, nil)
    do { try await run() }
    catch { print("Write publisher test failed: \(error.localizedDescription)"); exit(1) }
  }

  static func run() async throws {
    guard CommandLine.arguments.count == 2 else { throw POSIXError(.EINVAL) }
    let domain = CommandLine.arguments[1]
    let api = GardenAPI(domainID: domain)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-publish-\(UUID())")
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let folder = try await api.create(parentID: 0, name: "remote-write-test-\(UUID())", folder: true)
    do {
      let journalURL = root.appendingPathComponent("writes.sqlite")
      let journal = try RemoteWriteJournal(url: journalURL, namespace: domain, limit: 64 * 1024 * 1024)
      let ranges = GardenRangeCache(api: api, domainID: domain, diskLimit: 0, directory: root.appendingPathComponent("cache"))
      let publisher = RemoteWritePublisher(api: api, ranges: ranges, journal: journal)
      let empty = try await api.create(parentID: folder.id, name: "Empty.bin", folder: false)
      try journal.truncate(empty, size: 0)
      let emptyState = try journal.seal(empty.id)
      let committedEmpty = try await publisher.publish(emptyState)
      try require(committedEmpty.size == 0 && committedEmpty.version != 0, "An empty file must commit without any data parts")
      try journal.acknowledge(emptyState)

      let small = try await api.create(parentID: folder.id, name: "Sparse.bin", folder: false)
      try journal.write(small, offset: 7, bytes: Data([5, 6, 7]))
      try journal.truncate(small, size: 64)
      let sparseState = try journal.seal(small.id)
      var expectedSparse = Data(repeating: 0, count: 64)
      expectedSparse.replaceSubrange(7..<10, with: Data([5, 6, 7]))
      try require(try await RemoteWriteReader.read(sparseState, journal: journal, ranges: ranges, offset: 0, length: 64) == expectedSparse,
        "Read-your-writes must preserve holes without requesting empty base content")
      let committedSmall = try await publisher.publish(sparseState)
      try require(try await api.read(id: small.id, version: committedSmall.version, offset: 0, length: 64) == expectedSparse,
        "Small file publication must preserve exact dirty bytes and holes")
      try journal.acknowledge(sparseState)
      print("Empty and sparse small file publication passed")

      let fresh = try await api.create(parentID: folder.id, name: "Fresh.bin", folder: false)
      let freshBytes = Data((0..<(2 * 1024 * 1024)).map { UInt8($0 % 251) })
      try journal.write(fresh, offset: 0, bytes: freshBytes)
      let freshState = try journal.seal(fresh.id)
      let beforeFresh = await ranges.remoteBytes
      let committedFresh = try await publisher.publish(freshState)
      try require(await ranges.remoteBytes == beforeFresh, "Publishing entirely dirty content must not read cloud payload")
      try require(try await api.read(id: fresh.id, version: committedFresh.version, offset: freshBytes.count - 32, length: 32) == Data(freshBytes.suffix(32)),
        "Fresh multipart publication must preserve tail bytes")
      try journal.acknowledge(freshState)
      print("Fresh multipart file published without cloud reads")

      let file = try await api.create(parentID: folder.id, name: "Partial.bin", folder: false)
      let source = root.appendingPathComponent("Partial.bin")
      try Data().write(to: source)
      let handle = try FileHandle(forWritingTo: source)
      let unit = Data((0..<(1024 * 1024)).map { UInt8($0 % 251) })
      for _ in 0..<24 { try handle.write(contentsOf: unit) }
      try handle.close()
      let base = try await api.upload(id: file.id, baseVersion: file.version, fileURL: source)
      let patch = Data(repeating: 255, count: 32)
      try journal.write(base, offset: 111, bytes: patch)
      let state = try journal.seal(base.id)
      try require(try await RemoteWriteReader.read(state, journal: journal, ranges: ranges, offset: 111, length: 32) == patch,
        "An entirely dirty read must return the accepted bytes immediately")
      let before = await ranges.remoteBytes
      let edited = try await publisher.publish(state)
      let downloaded = await ranges.remoteBytes - before
      try require(downloaded <= 12 * 1024 * 1024, "An edit in one part must not download the unchanged 16 MiB")
      try require(try journal.state(base.id) != nil, "Cloud success must not acknowledge the local journal implicitly")
      let recovered = try RemoteWriteJournal(url: journalURL, namespace: domain, limit: 64 * 1024 * 1024)
      let replayPublisher = RemoteWritePublisher(api: api, ranges: ranges, journal: recovered)
      let replay = try await replayPublisher.publish(recovered.seal(base.id))
      try require(replay.version == edited.version, "A lost commit response must replay the exact cloud version")
      try require(try await api.read(id: file.id, version: edited.version, offset: 111, length: 32) == patch, "Dirty bytes must be committed")
      for offset in [0, 8 * 1024 * 1024 + 111, 16 * 1024 * 1024 + 111, base.size - 32] {
        let expected = Data((offset..<(offset + 32)).map { UInt8(($0 % unit.count) % 251) })
        try require(try await api.read(id: file.id, version: edited.version, offset: offset, length: 32) == expected,
          "Copied base ranges must remain exact")
      }
      try require(try await api.read(id: file.id, version: base.version, offset: 111, length: 32) == Data((111..<143).map { UInt8($0 % 251) }),
        "The original committed base must stay immutable")
      try recovered.acknowledge(state)
      try require(try recovered.used == 0 && recovered.pending().isEmpty, "Confirmed commits must release all accepted staging bytes")
      try await api.delete(folder.id)
      await ranges.invalidate()
      print("Hosted write publisher passed: empty, sparse, fresh multipart, partial edit, \(downloaded) cloud bytes read, retained journal, restart replay and explicit acknowledgement")
    } catch {
      print("Removing failed write fixture \(folder.id)")
      try await api.delete(folder.id)
      throw error
    }
  }
}
