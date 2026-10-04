import Foundation

@main struct ReadTransportTests {
  static func main() async throws {
    setbuf(stdout, nil)
    let args = CommandLine.arguments
    guard args.count == 5, let offset = Int(args[4]) else { throw POSIXError(.EINVAL) }
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-transport-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: args[1], state: root, cache: root.appendingPathComponent("cache"), limit: 0)
    let preparing = ContinuousClock.now
    try await engine.prepare()
    print("Metadata and stream setup: \(preparing.duration(to: .now))")
    guard let node = try await engine.lookup(args[2]) else { throw POSIXError(.ENOENT) }
    let authorizing = ContinuousClock.now
    let ticket = try await engine.api.download(id: node.id, version: node.version)
    print("Read authorization: \(authorizing.duration(to: .now))")
    guard let url = ticket.url else { throw GardenAPIError.invalidResponse }
    let length = 8 * 1024 * 1024
    let source = try FileHandle(forReadingFrom: URL(fileURLWithPath: args[3]))
    defer { try? source.close() }
    try source.seek(toOffset: UInt64(offset))
    guard let expected = try source.read(upToCount: length), expected.count == length else { throw POSIXError(.EIO) }
    for partSize in [1024 * 1024, 4 * 1024 * 1024, 8 * 1024 * 1024] {
      let started = ContinuousClock.now
      let blocks = try await withThrowingTaskGroup(of: (Int, Data).self) { group in
        let count = length / partSize
        var next = 0
        for index in 0..<min(3, count) {
          group.addTask { (index, try await read(url, offset: offset + index * partSize, length: partSize, size: node.size)) }
          next += 1
        }
        var received: [Int: Data] = [:]
        while let (index, bytes) = try await group.next() {
          received[index] = bytes
          if next < count {
            let index = next
            group.addTask { (index, try await read(url, offset: offset + index * partSize, length: partSize, size: node.size)) }
            next += 1
          }
        }
        return received
      }
      var actual = Data()
      for index in 0..<(length / partSize) {
        guard let bytes = blocks[index] else { throw POSIXError(.EIO) }
        actual.append(bytes)
      }
      guard actual == expected else { throw POSIXError(.EIO) }
      print("S3 8 MiB, \(partSize / 1024) KiB requests, at most three concurrent: \(started.duration(to: .now))")
    }
    await engine.stop()
    print("All transport ranges byte-correct; no disk payload cache")
  }

  static func read(_ url: URL, offset: Int, length: Int, size: Int) async throws -> Data {
    var request = URLRequest(url: url)
    request.timeoutInterval = 60
    request.setValue("bytes=\(offset)-\(offset + length - 1)", forHTTPHeaderField: "Range")
    let (bytes, response) = try await GardenObjectRequests.read(request)
    guard let response = response as? HTTPURLResponse, response.statusCode == 206,
      response.value(forHTTPHeaderField: "Content-Range") == "bytes \(offset)-\(offset + length - 1)/\(size)",
      bytes.count == length else { throw GardenAPIError.invalidResponse }
    return bytes
  }
}
