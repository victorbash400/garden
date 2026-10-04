import Foundation

@main struct ReadPerformanceTests {
  static func payloadStorage(_ directory: URL) throws -> (bytes: Int64, count: Int) {
    var allocated: Int64 = 0
    var payloads = 0
    let folders = try FileManager.default.contentsOfDirectory(at: directory,
      includingPropertiesForKeys: [.isDirectoryKey])
    for folder in folders where try folder.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true {
      let files = try FileManager.default.contentsOfDirectory(at: folder,
        includingPropertiesForKeys: [.isRegularFileKey, .fileAllocatedSizeKey])
      for file in files {
        let values = try file.resourceValues(forKeys: [.isRegularFileKey, .fileAllocatedSizeKey])
        if values.isRegularFile == true {
          guard let size = values.fileAllocatedSize else { throw POSIXError(.EIO) }
          allocated += Int64(size)
          payloads += 1
        }
      }
    }
    return (allocated, payloads)
  }

  static func main() async throws {
    setbuf(stdout, nil)
    let args = CommandLine.arguments
    guard args.count == 8, let offset = Int(args[5]), let length = Int(args[6]),
      let limit = Int64(args[7]) else { throw POSIXError(.EINVAL) }
    try GardenCachePolicy.validate(limit)
    let root = URL(fileURLWithPath: args[2])
    let cacheURL = root.appendingPathComponent("blocks")
    let engine = try RemoteEngine(domainID: args[1], state: root.appendingPathComponent("state"), cache: cacheURL, limit: limit)
    try await engine.prepare()
    let handle = try await engine.open(args[3], directory: false)
    let started = ContinuousClock.now
    let result = try await engine.read(handle, offset: offset, length: length)
    print("Cold range: \(started.duration(to: .now))")
    let source = try FileHandle(forReadingFrom: URL(fileURLWithPath: args[4]))
    defer { try? source.close() }
    try source.seek(toOffset: UInt64(offset))
    guard try source.read(upToCount: length) == result else {
      throw NSError(domain: "GardenReadTest", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Remote bytes differ from the source at offset \(offset)."])
    }
    let warm = ContinuousClock.now
    guard try await engine.read(handle, offset: offset, length: length) == result else {
      throw NSError(domain: "GardenReadTest", code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Warm bytes differ from the cold read."])
    }
    let duration = warm.duration(to: .now)
    let status = try await GardenDiskCache(directory: cacheURL, limit: limit).status()
    guard status.limit == limit, status.used <= limit, limit != 0 || status.used == 0 else {
      throw NSError(domain: "GardenReadTest", code: 3,
        userInfo: [NSLocalizedDescriptionKey: "Cache index exceeds the requested limit."])
    }
    let payloads = try payloadStorage(cacheURL)
    print("Cache index: \(status.used) bytes, \(status.blocks) blocks; physical payload: \(payloads.bytes) bytes, \(payloads.count) files")
    guard payloads.bytes <= limit, status.used == payloads.bytes, status.blocks == payloads.count else {
      throw NSError(domain: "GardenReadTest", code: 4,
        userInfo: [NSLocalizedDescriptionKey: "Physical cache payload differs from the index or exceeds its limit."])
    }
    print("Warm range: \(duration); transferred \(await engine.ranges.remoteBytes) bytes; disk payload \(status.used)/\(limit) bytes")
    await engine.stop()
    print("Byte correctness and disk cap passed")
  }
}
