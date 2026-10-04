import Darwin
import Foundation

@main struct NamespaceTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async throws {
    setbuf(stdout, nil)
    guard CommandLine.arguments.count == 2 ||
      (CommandLine.arguments.count == 3 && CommandLine.arguments[2] == "--cleanup-test-fixtures") else { throw POSIXError(.EINVAL) }
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-namespace-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let domain = CommandLine.arguments[1]
    let api = GardenAPI(domainID: domain)
    if CommandLine.arguments.count == 3 {
      var cursor = 0
      var removed = 0
      while true {
        let nodes = try await api.list(parentID: 0, after: cursor)
        for node in nodes {
          for prefix in ["remote-namespace-test-", "remote-namespace-recovery-"] where node.name.hasPrefix(prefix) {
            guard UUID(uuidString: String(node.name.dropFirst(prefix.count))) != nil else { continue }
            try await api.delete(node.id)
            removed += 1
          }
        }
        if nodes.count < 256 { break }
        guard let next = nodes.last?.id, next > cursor else { throw GardenAPIError.invalidResponse }
        cursor = next
      }
      print("Removed \(removed) namespace test fixtures")
      return
    }
    let recoveryName = "remote-namespace-recovery-\(UUID())"
    let pending = try RemoteMutation(operation: .createFolder, path: "/" + recoveryName)
    do {
      let journal = try RemoteMutationJournal(url: root.appendingPathComponent("state/mutations.sqlite"), namespace: domain)
      try journal.append(pending)
    }
    // Simulate a committed request whose response was lost before the helper could acknowledge it.
    guard let receipt = try await api.call("filesystem", "mutate", [
      "gardenId": try await api.streamCredential().driveID, "request": pending.arguments
    ]) as? [[String: Any]], let record = receipt.first?["node"] as? [String: Any] else {
      throw GardenAPIError.invalidResponse
    }
    var recoveryFixture: Int? = try GardenNode(record).id
    let engine = try RemoteEngine(domainID: domain, state: root.appendingPathComponent("state"),
      cache: root.appendingPathComponent("cache"), limit: 0)
    try await engine.prepare()
    try require(try await engine.lookup("/" + recoveryName)?.id == recoveryFixture,
      "Startup replay must retain the committed folder identity")
    let mountPath = "/Volumes/GardenNamespaceTest"
    let mount = try await RemoteMount.start(engine: engine, path: mountPath, name: "Garden Namespace Test")
    let running = Task { try await mount.run() }
    let name = "remote-namespace-test-\(UUID())"
    let directory = mountPath + "/" + name
    var fixture: Int?
    do {
      print("Namespace test mounted")
      let created = mkdir(directory, 0o755)
      let createError = errno
      print("Namespace mkdir result: \(created), errno: \(createError)")
      do { fixture = try await engine.lookup("/" + name)?.id }
      catch let error as POSIXError where error.code == .ENOENT {}
      guard created == 0 else { throw POSIXError(POSIXErrorCode(rawValue: createError) ?? .EIO) }
      try require(fixture != nil, "mkdir must publish metadata before returning")
      try require(try FileManager.default.contentsOfDirectory(atPath: directory).isEmpty, "New folders must open empty")
      let child = directory + "/Before"
      try require(mkdir(child, 0o755) == 0, "Nested mkdir must work")
      try require(rmdir(directory) == -1 && errno == ENOTEMPTY, "Nonempty rmdir must return ENOTEMPTY")
      try require(rename(child, directory + "/After") == 0, "Mounted rename must work")
      try require(try FileManager.default.contentsOfDirectory(atPath: directory) == ["After"], "Rename must update the mounted directory")
      let removedFolder = unlink(directory + "/After")
      let folderError = errno
      try require(removedFolder == -1 && (folderError == EISDIR || folderError == EPERM), "unlink must reject a directory")
      try require(rmdir(directory + "/After") == 0, "Empty rmdir must work")

      let file = try await engine.api.create(parentID: fixture!, name: "Sample.bin", folder: false)
      let expected = Data([4, 3, 2, 1, 0])
      let source = root.appendingPathComponent("Sample.bin")
      try expected.write(to: source)
      _ = try await engine.api.upload(id: file.id, baseVersion: file.version, fileURL: source)
      try await engine.reconnect()
      let currentFile = try await engine.lookup("/" + name + "/Sample.bin")
      print("Namespace engine content size: \(currentFile?.size ?? -1), version: \(currentFile?.version ?? -1)")
      let filePath = directory + "/Sample.bin"
      print("Namespace folder operations passed; opening uploaded content")
      var descriptor = open(filePath, O_RDONLY)
      guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
      defer { if descriptor >= 0 { close(descriptor) } }
      var attributes = stat()
      let statResult = fstat(descriptor, &attributes)
      print("Namespace stat: result=\(statResult), size=\(attributes.st_size), blocks=\(attributes.st_blocks)")
      try require(statResult == 0 && attributes.st_size == 5 && attributes.st_blocks == 0,
        "Mounted content must retain logical size without allocated payload blocks")
      var initialBytes = [UInt8](repeating: 255, count: 5)
      let initialCount = initialBytes.withUnsafeMutableBytes { pread(descriptor, $0.baseAddress, 5, 0) }
      print("Namespace initial read: count=\(initialCount), bytes=\(initialBytes)")
      try require(initialCount == 5 && Data(initialBytes) == expected, "Committed content must read before namespace changes")
      let writable = open(filePath, O_WRONLY)
      if writable >= 0 {
        defer { close(writable) }
        let result = expected.withUnsafeBytes { write(writable, $0.baseAddress, expected.count) }
        try require(result == -1 && errno == EROFS, "Unsupported content writes must fail explicitly")
      } else {
        try require(errno == EROFS || errno == EACCES, "Unsupported writable access must fail explicitly")
      }
      try require(rename(filePath, directory + "/Renamed.bin") == 0, "File rename must work")
      _ = fstat(descriptor, &attributes)
      print("Namespace renamed descriptor size: \(attributes.st_size)")
      try require(unlink(directory + "/Renamed.bin") == 0, "File unlink must work")
      _ = fstat(descriptor, &attributes)
      print("Namespace unlinked descriptor size: \(attributes.st_size)")
      var bytes = [UInt8](repeating: 255, count: 5)
      let count = bytes.withUnsafeMutableBytes { pread(descriptor, $0.baseAddress, 5, 0) }
      print("Namespace pinned read: count=\(count), errno=\(errno), bytes=\(bytes)")
      try require(count == 5 && Data(bytes) == expected, "An open handle must still range-read after rename and unlink")
      try require(rmdir(directory) == 0, "Fixture folder must become empty after unlink")
      fixture = nil
      try require(rmdir(mountPath + "/" + recoveryName) == 0, "Recovered fixture must be removable")
      recoveryFixture = nil
      let journal = try RemoteMutationJournal(url: root.appendingPathComponent("state/mutations.sqlite"), namespace: domain)
      try require(try journal.first() == nil, "Successful and rejected operations must clear their journal entries")
      close(descriptor)
      descriptor = -1
      try await mount.unmount()
      try await running.value
      await engine.stop()
      print("Hosted native namespace: mkdir, empty folders, rename, unlink, errno, pinned reads, zero blocks, journal acknowledgement, and unmount passed")
    } catch {
      mount.stop()
      _ = try? await running.value
      await engine.stop()
      if let fixture { try await engine.api.delete(fixture) }
      if let recoveryFixture { try await api.delete(recoveryFixture) }
      throw error
    }
  }
}
