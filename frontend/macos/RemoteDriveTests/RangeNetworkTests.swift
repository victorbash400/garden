import Foundation

@main struct RangeNetworkTests {
  static func main() async throws {
    guard CommandLine.arguments.count == 4, let nodeID = Int(CommandLine.arguments[2]) else { throw POSIXError(.EINVAL) }
    let api = GardenAPI(domainID: CommandLine.arguments[1])
    let node = try await api.get(nodeID)
    guard let url = try await api.download(id: node.id, version: node.version).url else { throw GardenAPIError.invalidResponse }
    let local = URL(fileURLWithPath: CommandLine.arguments[3])
    for parallel in [6,12,24] {
      let started = ContinuousClock.now
      try await withThrowingTaskGroup(of: Void.self) { group in
        var next = 0
        func enqueue(_ index: Int) {
          group.addTask {
            let offset = 64 * 1024 * (index * 73 + parallel * 7)
            let length = min(65536, node.size - offset)
            guard length > 0 else { throw POSIXError(.EINVAL) }
            var request = URLRequest(url: url)
            request.setValue("bytes=\(offset)-\(offset + length - 1)", forHTTPHeaderField: "Range")
            let (data,response) = try await GardenObjectRequests.read(request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 206,
              response.value(forHTTPHeaderField: "Content-Range") == "bytes \(offset)-\(offset + length - 1)/\(node.size)" else { throw GardenAPIError.invalidResponse }
            let handle = try FileHandle(forReadingFrom: local)
            defer { try? handle.close() }
            try handle.seek(toOffset: UInt64(offset))
            guard try handle.read(upToCount: length) == data else { throw POSIXError(.EIO) }
          }
        }
        for _ in 0..<parallel { enqueue(next); next += 1 }
        while try await group.next() != nil {
          if next < 48 { enqueue(next); next += 1 }
        }
      }
      print("48 byte-correct sparse 64 KiB S3 ranges, concurrency \(parallel): \(started.duration(to: .now))")
    }
  }
}
