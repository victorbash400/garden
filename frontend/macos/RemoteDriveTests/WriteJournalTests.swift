import Darwin
import Foundation

@main struct WriteJournalTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func node(_ id: Int = 1) throws -> GardenNode {
    try GardenNode(["id": id, "parentId": 0, "name": "Edit.bin", "kind": "file",
      "size": 512, "version": 10, "updatedAt": "2026-10-04T12:00:00.000Z", "deleted": false])
  }

  static func contents(_ journal: RemoteWriteJournal, _ node: GardenNode, original: Data) throws -> Data {
    guard let draft = try journal.state(node.id) else { return original }
    var data = Data(repeating: 0, count: draft.size)
    let count = min(draft.size, draft.baseLimit)
    data.replaceSubrange(0..<count, with: original.prefix(count))
    for extent in try journal.extents(node.id, offset: 0, length: draft.size) {
      data.replaceSubrange(extent.offset..<(extent.offset + extent.bytes.count), with: extent.bytes)
    }
    return data
  }

  static func main() throws {
    if CommandLine.arguments.count == 3, CommandLine.arguments[1] == "--crash-write" {
      let journal = try RemoteWriteJournal(url: URL(fileURLWithPath: CommandLine.arguments[2]), namespace: "account-drive", limit: 4096)
      try journal.write(node(), offset: 111, bytes: Data([8, 7, 6, 5]))
      _exit(71)
    }
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-write-journal-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let url = root.appendingPathComponent("writes.sqlite")
    let file = try node()
    let legacy = RemoteWriteState(operationID: UUID(), base: file, size: file.size, baseLimit: file.size, generation: 1)
    var record = try JSONSerialization.jsonObject(with: JSONEncoder().encode(legacy)) as! [String: Any]
    record.removeValue(forKey: "sealed")
    record.removeValue(forKey: "modified")
    let migrated = try JSONDecoder().decode(RemoteWriteState.self, from: JSONSerialization.data(withJSONObject: record))
    try require(!migrated.sealed && migrated.modified == file.modifiedDate && migrated.operationID == legacy.operationID,
      "Legacy pending journals must preserve their edit identity when publication fields are introduced")
    let original = Data((0..<512).map { UInt8($0 % 251) })
    var expected = original
    do {
      let journal = try RemoteWriteJournal(url: url, namespace: "account-drive", limit: 4096)
      var random: UInt64 = 1234
      for index in 0..<300 {
        random = random &* 6364136223846793005 &+ 1
        if index % 7 == 0 {
          let size = Int(random % 1024)
          try journal.truncate(file, size: size)
          if size < expected.count { expected = Data(expected.prefix(size)) }
          else { expected.append(Data(repeating: 0, count: size - expected.count)) }
        } else {
          let offset = Int(random % 1024)
          let count = Int((random >> 10) % 63) + 1
          let bytes = Data(repeating: UInt8(index % 251), count: count)
          try journal.write(file, offset: offset, bytes: bytes)
          if offset + count > expected.count { expected.append(Data(repeating: 0, count: offset + count - expected.count)) }
          expected.replaceSubrange(offset..<(offset + count), with: bytes)
        }
        try require(try contents(journal, file, original: original) == expected,
          "Overlaps, truncation and holes must match ordinary file semantics")
        let extents = try journal.extents(file.id, offset: 0, length: RemoteWriteJournal.fileLimit)
        for pair in zip(extents, extents.dropFirst()) {
          try require(pair.0.offset + pair.0.bytes.count <= pair.1.offset, "Dirty ranges must never overlap")
        }
      }
      let old = try journal.state(file.id)!
      try journal.write(file, offset: 0, bytes: Data([255]))
      expected.replaceSubrange(0..<1, with: Data([255]))
      do { try journal.acknowledge(old); throw POSIXError(.EINVAL) }
      catch let error as POSIXError { try require(error.code == .EBUSY, "An old upload must not discard newer accepted writes") }
    }
    let reopened = try RemoteWriteJournal(url: url, namespace: "account-drive", limit: 4096)
    try require(try contents(reopened, file, original: original) == expected, "Reopen must retain exact edits and logical size")
    let current = try reopened.seal(file.id)
    do { try reopened.write(file, offset: 0, bytes: Data([1])); throw POSIXError(.EINVAL) }
    catch let error as POSIXError { try require(error.code == .EBUSY, "An in-flight publication must freeze its accepted bytes") }
    do { try reopened.truncate(file, size: 0); throw POSIXError(.EINVAL) }
    catch let error as POSIXError { try require(error.code == .EBUSY, "An in-flight publication must freeze its size") }
    try require(try reopened.seal(file.id).operationID == current.operationID,
      "A publication retry must reuse the same immutable edit identity")
    try reopened.acknowledge(current)
    try require(try reopened.used == 0 && reopened.pending().isEmpty, "Acknowledged edits must release staging space")
    do {
      _ = try RemoteWriteJournal(url: url, namespace: "other-account", limit: 4096)
      throw POSIXError(.EINVAL)
    } catch let error as POSIXError { try require(error.code == .EACCES, "Accounts must not share staged edits") }
    let child = Process()
    child.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
    child.arguments = ["--crash-write", url.path]
    try child.run()
    child.waitUntilExit()
    try require(child.terminationStatus == 71, "Crash fixture must exit without closing SQLite")
    let crashed = try RemoteWriteJournal(url: url, namespace: "account-drive", limit: 4096)
    try require(try crashed.extents(file.id, offset: 111, length: 4).first?.bytes == Data([8, 7, 6, 5]), "Abrupt termination must preserve accepted bytes")
    let retained = try crashed.state(file.id)!
    let capped = try RemoteWriteJournal(url: url, namespace: "account-drive", limit: 4)
    try capped.write(file, offset: 111, bytes: Data([4, 3, 2, 1]))
    let before = try capped.state(file.id)!
    do { try capped.write(node(2), offset: 0, bytes: Data([9])); throw POSIXError(.EINVAL) }
    catch let error as POSIXError { try require(error.code == .ENOSPC, "The staging cap must apply across files") }
    try require(try capped.used == 4 && capped.state(2) == nil && capped.state(1)?.generation == before.generation,
      "Overflow must roll back the whole write and retain accepted data")
    try require(before.operationID == retained.operationID, "Overwrites and restarts must retain the upload identity")
    try capped.truncate(file, size: 0)
    try capped.truncate(file, size: RemoteWriteJournal.fileLimit)
    try require(try capped.used == 0 && capped.state(file.id)?.baseLimit == 0,
      "Sparse growth must allocate no payload and must not resurrect truncated content")
    let large = try RemoteWriteJournal(url: root.appendingPathComponent("large.sqlite"), namespace: "account-drive", limit: 1024 * 1024)
    let payload = Data(repeating: 1, count: 2 * RemoteWriteJournal.blockSize + 31)
    try large.write(file, offset: 0, bytes: payload)
    try large.write(file, offset: RemoteWriteJournal.blockSize - 4, bytes: Data(repeating: 2, count: 12))
    let segments = try large.extents(file.id, offset: 0, length: payload.count)
    try require(segments.allSatisfy { $0.bytes.count <= RemoteWriteJournal.blockSize } && large.used == payload.count,
      "Large writes must be segmented and overlapping replacement must not consume extra capacity")
    var combined = Data(repeating: 0, count: payload.count)
    for segment in segments { combined.replaceSubrange(segment.offset..<(segment.offset + segment.bytes.count), with: segment.bytes) }
    var expectedLarge = payload
    expectedLarge.replaceSubrange((RemoteWriteJournal.blockSize - 4)..<(RemoteWriteJournal.blockSize + 8), with: Data(repeating: 2, count: 12))
    try require(combined == expectedLarge, "A patch across two blocks must preserve every other byte")
    do { try large.write(file, offset: RemoteWriteJournal.fileLimit, bytes: Data([1])); throw POSIXError(.EIO) }
    catch let error as POSIXError { try require(error.code == .EINVAL, "Invalid file ranges must fail before changing accepted edits") }
    print("Write journal: 300 file-semantics operations, restart, abrupt crash, capped rollback, sparse growth, stale acknowledgement and account isolation passed")
  }
}
