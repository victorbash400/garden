import Foundation

private final class ReadTiming: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
  private let lock = NSLock()
  private var timing: (Double, Double, String)?

  func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
    guard let transfer = metrics.transactionMetrics.last, let start = transfer.requestStartDate,
      let response = transfer.responseStartDate, let end = transfer.responseEndDate else { return }
    lock.withLock { timing = (response.timeIntervalSince(start), end.timeIntervalSince(response),
      transfer.networkProtocolName ?? "unknown") }
  }

  var result: (Double, Double, String)? { lock.withLock { timing } }
}

@main struct ReadConcurrencyTests {
  static func main() async throws {
    setbuf(stdout, nil)
    let args = CommandLine.arguments
    guard args.count == 5, let offset = Int(args[4]) else { throw POSIXError(.EINVAL) }
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-read-concurrency-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: args[1], state: root, cache: root.appendingPathComponent("cache"), limit: 0)
    try await engine.prepare()
    guard let node = try await engine.lookup(args[2]), let url = try await engine.api.download(id: node.id, version: node.version).url else {
      throw GardenAPIError.invalidResponse
    }
    let source = try FileHandle(forReadingFrom: URL(fileURLWithPath: args[3]))
    defer { try? source.close() }
    let block = 1024 * 1024
    let length = 8 * block
    try source.seek(toOffset: UInt64(offset))
    guard let expected = try source.read(upToCount: length), expected.count == length else { throw POSIXError(.EIO) }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.urlCache = nil
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    let session = URLSession(configuration: configuration)
    defer { session.invalidateAndCancel() }
    for concurrency in [3, 6, 1, 6, 3, 1] {
      let started = ContinuousClock.now
      let results = try await withThrowingTaskGroup(of: (Int, Data, Double, Double, String).self) { group in
        var next = 0
        func schedule(_ index: Int) {
          group.addTask {
            var request = URLRequest(url: url)
            let start = offset + index * block
            request.timeoutInterval = 60
            request.setValue("bytes=\(start)-\(start + block - 1)", forHTTPHeaderField: "Range")
            let timing = ReadTiming()
            let (bytes, response) = try await session.data(for: request, delegate: timing)
            guard let response = response as? HTTPURLResponse, response.statusCode == 206,
              response.value(forHTTPHeaderField: "Content-Range") == "bytes \(start)-\(start + block - 1)/\(node.size)",
              bytes.count == block, let metrics = timing.result else { throw GardenAPIError.invalidResponse }
            return (index, bytes, metrics.0, metrics.1, metrics.2)
          }
        }
        for index in 0..<min(concurrency, 8) { schedule(index); next += 1 }
        var result: [(Int, Data, Double, Double, String)] = []
        while let received = try await group.next() {
          result.append(received)
          if next < 8 { schedule(next); next += 1 }
        }
        return result.sorted { $0.0 < $1.0 }
      }
      var actual = Data()
      for result in results { actual.append(result.1) }
      guard actual == expected else { throw POSIXError(.EIO) }
      let responses = results.map { $0.2 }.sorted()
      let transfers = results.map { $0.3 }.sorted()
      let ttfb = (responses[3] + responses[4]) / 2
      let transfer = (transfers[3] + transfers[4]) / 2
      print("Concurrency \(concurrency): total \(started.duration(to: .now)), median response \(ttfb)s, median transfer \(transfer)s, slowest transfer \(transfers[7])s, protocols \(Set(results.map { $0.4 }).sorted())")
    }
    await engine.stop()
    print("Six byte-correct 8 MiB trials; no disk read cache")
  }
}
