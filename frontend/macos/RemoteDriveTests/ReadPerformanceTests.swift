import Foundation

@main struct ReadPerformanceTests {
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
    guard try source.read(upToCount: length) == result else { throw GardenAPIError.invalidResponse }
    let warm = ContinuousClock.now
    guard try await engine.read(handle, offset: offset, length: length) == result else { throw GardenAPIError.invalidResponse }
    let duration = warm.duration(to: .now)
    let status = try await GardenDiskCache(directory: cacheURL, limit: limit).status()
    guard status.limit == limit, status.used <= limit, limit != 0 || status.used == 0 else {
      throw GardenAPIError.invalidResponse
    }
    print("Warm range: \(duration); transferred \(await engine.ranges.remoteBytes) bytes; disk payload \(status.used)/\(limit) bytes")
    await engine.stop()
    print("Byte correctness and disk cap passed")
  }
}
