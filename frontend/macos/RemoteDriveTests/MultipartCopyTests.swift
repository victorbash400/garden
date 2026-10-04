import Darwin
import Foundation

@main struct MultipartCopyTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async {
    do { try await run() }
    catch {
      print("Partial-copy test failed: \(error.localizedDescription)")
      exit(1)
    }
  }

  static func run() async throws {
    setbuf(stdout, nil)
    guard CommandLine.arguments.count == 2 ||
      (CommandLine.arguments.count == 3 && CommandLine.arguments[2] == "--cleanup-test-fixtures") else { throw POSIXError(.EINVAL) }
    let api = GardenAPI(domainID: CommandLine.arguments[1])
    if CommandLine.arguments.count == 3 {
      var cursor = 0
      var removed = 0
      while true {
        let nodes = try await api.list(parentID: 0, after: cursor)
        let prefix = "remote-copy-test-"
        for node in nodes where node.name.hasPrefix(prefix) {
          guard UUID(uuidString: String(node.name.dropFirst(prefix.count))) != nil else { continue }
          try await api.delete(node.id)
          removed += 1
        }
        if nodes.count < 256 { break }
        guard let next = nodes.last?.id, next > cursor else { throw GardenAPIError.invalidResponse }
        cursor = next
      }
      print("Removed \(removed) partial-copy test fixtures")
      return
    }
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-copy-\(UUID())")
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let folder = try await api.create(parentID: 0, name: "remote-copy-test-\(UUID())", folder: true)
    do {
      let file = try await api.create(parentID: folder.id, name: "Partial.bin", folder: false)
      let source = root.appendingPathComponent("Partial.bin")
      try Data().write(to: source)
      let handle = try FileHandle(forWritingTo: source)
      let unit = Data((0..<(1024 * 1024)).map { UInt8($0 % 251) })
      for _ in 0..<24 { try handle.write(contentsOf: unit) }
      try handle.close()
      let base = try await api.upload(id: file.id, baseVersion: file.version, fileURL: source)
      print("Created 24 MiB multipart fixture")
      let upload = try await api.object(api.call("content", "beginMultipart", [
        "nodeId": file.id, "baseVersion": base.version, "size": base.size,
      ]))
      guard let id = upload["id"] as? Int, let partSize = upload["partSize"] as? Int,
        partSize == 8 * 1024 * 1024 else { throw GardenAPIError.invalidResponse }
      let read = try FileHandle(forReadingFrom: source)
      guard var changed = try read.read(upToCount: partSize), changed.count == partSize else { throw POSIXError(.EIO) }
      try read.close()
      let patch = Data(repeating: 255, count: 32)
      changed.replaceSubrange(111..<143, with: patch)
      guard let urls = try await api.call("content", "uploadParts", [
        "versionId": id, "first": 1, "count": 1,
      ]) as? [String], let address = urls.first, let url = URL(string: address), url.scheme == "https" else {
        throw GardenAPIError.invalidResponse
      }
      var request = URLRequest(url: url)
      request.httpMethod = "PUT"
      request.timeoutInterval = 120
      try await GardenObjectRequests.upload(request, data: changed)
      print("Uploaded changed 8 MiB part")
      for _ in 0..<2 {
        _ = try await api.call("content", "copyParts", ["versionId": id, "first": 2, "count": 2])
        print("Copied unchanged parts inside S3")
      }
      guard let parts = try await api.call("content", "uploadedParts", ["versionId": id]) as? [[String: Any]] else {
        throw GardenAPIError.invalidResponse
      }
      try require(parts.count == 3 && parts.allSatisfy { ($0["size"] as? Int) == partSize }, "Copied parts must have exact lengths")
      let updated = try GardenNode(await api.object(api.call("content", "finish", ["versionId": id])))
      print("Committed partial edit")
      let replay = try GardenNode(await api.object(api.call("content", "finish", ["versionId": id])))
      try require(updated.version == id && replay.version == id && updated.size == base.size, "Finish must publish and replay the same version")
      try require(try await api.read(id: file.id, version: id, offset: 111, length: 32) == patch, "Changed bytes must be published")
      for offset in [0, partSize - 16, partSize + 111, 2 * partSize + 111, base.size - 32] {
        let count = offset == partSize - 16 ? 16 : 32
        let expected = Data((offset..<(offset + count)).map { UInt8(($0 % unit.count) % 251) })
        try require(try await api.read(id: file.id, version: id, offset: offset, length: count) == expected, "Unchanged bytes must remain exact")
      }
      let original = Data((111..<143).map { UInt8($0 % 251) })
      try require(try await api.read(id: file.id, version: base.version, offset: 111, length: 32) == original, "The committed base must stay immutable")
      try await api.delete(folder.id)
      print("Hosted partial edit passed: 8 MiB uploaded, 16 MiB copied inside S3, replay and immutable base verified")
    } catch {
      print("Partial edit failed: \(error.localizedDescription); removing fixture \(folder.id)")
      try await api.delete(folder.id)
      throw error
    }
  }
}
