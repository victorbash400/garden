import CryptoKit
import Darwin
import Foundation

@main struct MountedMediaWriteTests {
  static func require(_ value: Bool, _ message: String) throws {
    guard value else { throw NSError(domain: "MountedMediaWriteTests", code: 1,
      userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async {
    setbuf(stdout, nil)
    do { try await run() }
    catch {
      let error = error as NSError
      print("Mounted media test failed: \(error.domain) (\(error.code)): \(error.localizedDescription)")
      exit(1)
    }
  }

  static func run() async throws {
    let args = CommandLine.arguments
    guard args.count == 3 else { throw POSIXError(.EINVAL) }
    let bytes = try Data(contentsOf: URL(fileURLWithPath: args[2]))
    guard bytes.count > 1024 * 1024, bytes.count <= 32 * 1024 * 1024 else { throw POSIXError(.EINVAL) }
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-media-write-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: args[1], state: root.appendingPathComponent("state"),
      cache: root.appendingPathComponent("cache"), limit: 0)
    try await engine.prepare()
    let mountPath = "/Volumes/GardenMediaWriteTest-\(UUID())"
    let mount = try await RemoteMount.start(engine: engine, path: mountPath, name: "Garden Media Write Test")
    let running = Task { try await mount.run() }
    let name = "media-write-test-\(UUID()).mov"
    let path = mountPath + "/" + name
    var descriptor: Int32 = -1
    var fixture: Int?
    do {
      descriptor = open(path, O_CREAT | O_EXCL | O_RDWR, 0o600)
      guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
      fixture = try await engine.lookup("/" + name)?.id
      guard let fixture else { throw POSIXError(.ENOENT) }
      let began = ContinuousClock.now
      var offset = 0
      while offset < bytes.count {
        let length = min(65536, bytes.count - offset)
        let written = bytes.withUnsafeBytes { pwrite(descriptor, $0.baseAddress!.advanced(by: offset), length, off_t(offset)) }
        try require(written == length, "Media write must accept all bytes at \(offset), errno \(errno)")
        offset += length
      }
      try require(fsync(descriptor) == 0, "Media fsync must succeed")
      try require(close(descriptor) == 0, "Media close must succeed")
      descriptor = -1
      try await engine.flushAll()
      let writeTime = began.duration(to: .now)
      print("Media writes published: \(bytes.count) bytes in \(writeTime)")
      let mounted = try Data(contentsOf: URL(fileURLWithPath: path))
      try require(mounted == bytes, "Mounted media must preserve every byte; expected \(bytes.count), read \(mounted.count)")
      print("Mounted media matches the original; checking external size changes")
      let file = try await engine.api.get(fixture)
      let writer = try RemoteEngine(domainID: args[1], state: root.appendingPathComponent("writer-state"),
        cache: root.appendingPathComponent("writer-cache"), limit: 0)
      try await writer.prepare()
      let handle = try await writer.open("/" + name, directory: false)
      try await writer.truncate("/" + name, handle: handle, size: 96)
      try await writer.flush(handle)
      try await engine.reconnect()
      var expected = Data(bytes.prefix(96))
      try require(try Data(contentsOf: URL(fileURLWithPath: path)) == expected,
        "An externally changed file must expose its smaller EOF without remounting")
      try await writer.truncate("/" + name, handle: handle, size: 512)
      let patch = Data((0..<100).map { UInt8($0 + 1) })
      try await writer.write(handle, offset: 400, bytes: patch, append: false)
      try await writer.flush(handle)
      try await writer.close(handle)
      await writer.stop()
      try await engine.reconnect()
      expected.append(Data(repeating: 0, count: 416))
      expected.replaceSubrange(400..<500, with: patch)
      try require(try Data(contentsOf: URL(fileURLWithPath: path)) == expected,
        "An externally changed file must expose its larger EOF and exact sparse bytes without remounting")
      print("Mounted external shrink, growth and sparse-byte refresh passed")
      var cloud = Data(capacity: bytes.count)
      while cloud.count < bytes.count {
        let length = min(256 * 1024, bytes.count - cloud.count)
        let block = try await engine.api.read(id: file.id, version: file.version,
          offset: cloud.count, length: length)
        try require(block.count == length, "Independent backend read must return the complete range")
        cloud.append(block)
      }
      try require(cloud == bytes, "Independent backend media download must preserve every byte")
      try require(try await engine.writes.pending().isEmpty, "Published media must leave no pending writes")
      print("Mounted media and backend range roundtrip passed: \(bytes.count) bytes, writes \(writeTime), SHA256 \(SHA256.hash(data: cloud))")
      try await mount.unmount()
      try await running.value
      await engine.stop()
      try await engine.api.delete(fixture)
    } catch {
      if descriptor >= 0 { close(descriptor) }
      do { try await mount.unmount(); try await running.value }
      catch { print("Media test unmount failed: \(error.localizedDescription)") }
      await engine.stop()
      if let fixture { try await engine.api.delete(fixture) }
      throw error
    }
  }
}
