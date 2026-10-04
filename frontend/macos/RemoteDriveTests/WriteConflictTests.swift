import Foundation

@main struct WriteConflictTests {
  static func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw NSError(domain: "WriteConflictTests", code: 1,
      userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async throws {
    setbuf(stdout, nil)
    guard CommandLine.arguments.count == 2 else { throw POSIXError(.EINVAL) }
    let domain = CommandLine.arguments[1]
    let api = GardenAPI(domainID: domain)
    let folder = try await api.create(parentID: 0, name: "write-conflict-\(UUID())", folder: true)
    let file = try await api.create(parentID: folder.id, name: "Shared.bin", folder: false)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-write-conflict-\(UUID())")
    let first = try RemoteEngine(domainID: domain, state: root.appendingPathComponent("first"),
      cache: root.appendingPathComponent("cache"), limit: 0)
    let second = try RemoteEngine(domainID: domain, state: root.appendingPathComponent("second"),
      cache: root.appendingPathComponent("cache"), limit: 0)
    do {
      try await first.prepare()
      try await second.prepare()
      let path = "/\(folder.name)/Shared.bin"
      let firstHandle = try await first.open(path, directory: false)
      let secondHandle = try await second.open(path, directory: false)
      let firstBytes = Data([1, 2, 3, 4])
      let secondBytes = Data([9, 8, 7, 6, 5])
      try await first.write(firstHandle, offset: 0, bytes: firstBytes, append: false)
      await first.scheduledPublications[file.id]?.cancel()
      try await second.write(secondHandle, offset: 0, bytes: secondBytes, append: false)
      await second.scheduledPublications[file.id]?.cancel()
      try require(try await second.writes.state(file.id)?.base.version == file.version,
        "Both editors must retain the same original base")
      try await first.flush(firstHandle)
      do {
        try await second.flush(secondHandle)
        throw NSError(domain: "WriteConflictTests", code: 2,
          userInfo: [NSLocalizedDescriptionKey: "Concurrent edit must report its conflict copy"])
      } catch let error as NSError {
        try require(error.domain == "GardenWriteConflict", "Conflict must be visible to the editor")
      }
      let children = try await api.list(parentID: folder.id, after: 0)
      guard children.count == 2, let original = children.first(where: { $0.id == file.id }),
        let conflict = children.first(where: { $0.id != file.id }) else { throw GardenAPIError.invalidResponse }
      try require(try await api.read(id: original.id, version: original.version, offset: 0, length: firstBytes.count) == firstBytes,
        "The first edit must remain unchanged")
      try require(try await api.read(id: conflict.id, version: conflict.version, offset: 0, length: secondBytes.count) == secondBytes,
        "The second edit must be preserved completely in its conflict file")
      let journal = await second.writes
      try require(try journal.pending().isEmpty && journal.used == 0,
        "Only confirmed conflict publication may release the journal")
      try require(await second.issue?.contains(conflict.name) == true,
        "The visible error must identify the saved conflict file")
      try require(try await second.lookup("/\(folder.name)/\(conflict.name)")?.id == conflict.id,
        "The local metadata mirror must expose the conflict file")
      try await first.close(firstHandle)
      try await second.close(secondHandle)
      await first.stop()
      await second.stop()
      try await api.delete(folder.id)
      try FileManager.default.removeItem(at: root)
      print("Native concurrent editors: exact bytes preserved in both cloud files, visible conflict name, metadata replay and confirmed journal release passed")
    } catch {
      await first.stop()
      await second.stop()
      FileHandle.standardError.write(Data("Retained conflict fixture node \(folder.id), state \(root.path)\n".utf8))
      throw error
    }
  }
}
