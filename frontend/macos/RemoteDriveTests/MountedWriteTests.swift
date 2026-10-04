import Darwin
import Foundation

@main struct MountedWriteTests {
  static func require(_ value: Bool, _ message: String) throws {
    if !value { throw NSError(domain: "RemoteTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async {
    setbuf(stdout, nil)
    do { try await run() }
    catch { print("Mounted write test failed: \(error.localizedDescription)"); exit(1) }
  }

  static func run() async throws {
    guard CommandLine.arguments.count == 2 else { throw POSIXError(.EINVAL) }
    let domain = CommandLine.arguments[1]
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-mounted-write-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: domain, state: root.appendingPathComponent("state"),
      cache: root.appendingPathComponent("cache"), limit: 0, writeLimit: 1024 * 1024)
    try await engine.prepare()
    let mountPath = "/Volumes/GardenWriteTest-\(UUID())"
    let mount = try await RemoteMount.start(engine: engine, path: mountPath, name: "Garden Write Test")
    let running = Task { try await mount.run() }
    let name = "remote-mounted-write-\(UUID())"
    let directory = mountPath + "/" + name
    var fixture: Int?
    var descriptor: Int32 = -1
    do {
      guard mkdir(directory, 0o755) == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
      fixture = try await engine.lookup("/" + name)?.id
      let filePath = directory + "/Data.bin"
      descriptor = open(filePath, O_CREAT | O_EXCL | O_RDWR, 0o644)
      guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
      let unit = Data((0..<(256 * 1024)).map { UInt8($0 % 251) })
      for index in 0..<12 {
        let written = unit.withUnsafeBytes { write(descriptor, $0.baseAddress, unit.count) }
        try require(written == unit.count, "Mounted sequential write \(index) must succeed, errno \(errno)")
      }
      print("Mounted create and 3 MiB writes passed under a 1 MiB staging budget")
      var tail = [UInt8](repeating: 0, count: 32)
      let count = tail.withUnsafeMutableBytes { pread(descriptor, $0.baseAddress, 32, 3 * 1024 * 1024 - 32) }
      try require(count == 32 && Data(tail) == Data(unit.suffix(32)), "Mounted reads must see staged bytes")
      let sync = fsync(descriptor)
      let syncError = errno
      try require(sync == 0, "Mounted fsync must succeed for durably accepted bytes, errno \(syncError)")
      guard let file = try await engine.lookup("/" + name + "/Data.bin") else { throw POSIXError(.ENOENT) }
      let committed = try GardenNode(await engine.api.object(engine.api.call("files", "get", ["nodeId": file.id])))
      let cloudSynced = committed.size == 3 * 1024 * 1024 && committed.version != 0
      if !cloudSynced {
        print("FSKit fsync returned without publishing: cloud size \(committed.size), visible size \(file.size)")
        try require(try await engine.writes.state(file.id) != nil, "Unpublished bytes must remain durable in the journal")
        if let scheduled = await engine.scheduledPublications[file.id] { await scheduled.value }
        if let publishing = await engine.publications[file.id] { try await publishing.value }
        let automatic = try await engine.api.get(file.id)
        try require(automatic.size == file.size, "Write-triggered publication must upload a file while its descriptor remains open")
        print("Write-triggered publication committed the open file; mounted fsync does not guarantee cloud confirmation")
      }
      var attributes = stat()
      let attributeResult = fstat(descriptor, &attributes)
      try require(attributeResult == 0 && attributes.st_size == file.size && attributes.st_blocks == 0,
        "Mounted logical size must update while payload allocation stays zero: size \(attributes.st_size), blocks \(attributes.st_blocks), errno \(errno)")
      try require(ftruncate(descriptor, 32) == 0, "Mounted shrink must succeed")
      try require(ftruncate(descriptor, 96) == 0, "Mounted sparse growth must succeed")
      try require(fsync(descriptor) == 0, "Truncation must commit on fsync")
      if let scheduled = await engine.scheduledPublications[file.id] { await scheduled.value }
      if let publishing = await engine.publications[file.id] { try await publishing.value }
      let truncated = try GardenNode(await engine.api.object(engine.api.call("files", "get", ["nodeId": file.id])))
      let bytes = try await engine.api.read(id: file.id, version: truncated.version, offset: 0, length: 96)
      var expected = Data(unit.prefix(32))
      expected.append(Data(repeating: 0, count: 64))
      try require(bytes == expected, "Shrink then grow must preserve the prefix and zero the discarded bytes")
      try require(close(descriptor) == 0, "Closing the committed descriptor must succeed")
      descriptor = -1
      descriptor = open(filePath, O_WRONLY | O_APPEND)
      guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
      let appended = Data([8, 9, 10])
      try require(appended.withUnsafeBytes { write(descriptor, $0.baseAddress, 3) } == 3, "Mounted append must succeed")
      try require(close(descriptor) == 0, "Close must flush pending appended bytes")
      descriptor = -1
      let closed = try GardenNode(await engine.api.object(engine.api.call("files", "get", ["nodeId": file.id])))
      try require(closed.size == 99, "Ordinary close must publish before returning")
      try require(try await engine.api.read(id: file.id, version: closed.version, offset: 96, length: 3) == appended,
        "Appended bytes must land at the end of the cloud file")
      try require(try await engine.writes.pending().isEmpty, "Successful mounted saves must leave no pending edits")
      print("Mounted truncate, sparse growth, append and close publication passed")
      try require(chmod(filePath, 0o600) == 0, "Mounted permissions must persist")
      let metadata = Data((0..<32).map { UInt8($0) })
      let key = "com.apple.FinderInfo"
      let set = metadata.withUnsafeBytes { buffer in
        filePath.withCString { path in key.withCString { name in setxattr(path, name, buffer.baseAddress, metadata.count, 0, 0) } }
      }
      try require(set == 0, "Mounted extended attribute must save, errno \(errno)")
      var received = [UInt8](repeating: 0, count: 32)
      let got = received.withUnsafeMutableBytes { buffer in
        filePath.withCString { path in key.withCString { name in getxattr(path, name, buffer.baseAddress, buffer.count, 0, 0) } }
      }
      try require(got == 32 && Data(received) == metadata, "Mounted binary metadata must read back exactly")
      let storedMetadata = try GardenNode(await engine.api.object(engine.api.call("files", "get", ["nodeId": file.id])))
      try require(storedMetadata.attributes?.permissions == 0o600 && storedMetadata.attributes?.value(key) == metadata,
        "Finder metadata must exist in cloud node attributes")
      let removed = filePath.withCString { path in key.withCString { name in removexattr(path, name, 0) } }
      try require(removed == 0, "Mounted extended attribute must remove")
      var dates = [timeval(tv_sec: 1_700_000_000, tv_usec: 123_000), timeval(tv_sec: 1_700_000_001, tv_usec: 456_000)]
      let dated = dates.withUnsafeMutableBufferPointer { utimes(filePath, $0.baseAddress) }
      try require(dated == 0, "Mounted modification date must save")
      let datedNode = try await engine.api.get(file.id)
      try require(abs(datedNode.modifiedDate.timeIntervalSince1970 - 1_700_000_001.456) < 0.001,
        "Cloud modification date must match the supplied filesystem date")
      print("Mounted permissions and binary extended attributes passed")
      let localCopy = root.appendingPathComponent("Local.bin")
      let copyBytes = Data((0..<4096).map { UInt8($0 % 251) })
      try copyBytes.write(to: localCopy)
      let copiedPath = directory + "/Copied.bin"
      try FileManager.default.copyItem(at: localCopy, to: URL(fileURLWithPath: copiedPath))
      try require(try Data(contentsOf: URL(fileURLWithPath: copiedPath)) == copyBytes, "Ordinary FileManager copy must preserve bytes")
      try require(unlink(copiedPath) == 0, "Copied file must delete normally")
      print("Mounted FileManager copy and cleanup passed")
      try require(rename(filePath, directory + "/Renamed.bin") == 0, "A written file must rename normally")
      try require(unlink(directory + "/Renamed.bin") == 0 && rmdir(directory) == 0, "A written file and empty fixture folder must delete normally")
      fixture = nil
      try await mount.unmount()
      try await running.value
      await engine.stop()
      print("Mounted write checks passed: create, bounded backpressure, read-your-writes, zero blocks, truncate, append, close publication, rename, delete and unmount")
    } catch {
      if descriptor >= 0 { close(descriptor); descriptor = -1 }
      do { try await mount.unmount(); try await running.value }
      catch { print("Write test unmount failed: \(error.localizedDescription)") }
      await engine.stop()
      if let fixture { try await engine.api.delete(fixture) }
      throw error
    }
  }
}
