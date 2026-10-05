import CryptoKit
import Foundation

struct GardenDownload: Sendable {
  let url: URL?
  let size: Int
  let expiresAt: Date
}

actor GardenRangeCache {
  static let blockSize = 1024 * 1024
  private static let smallBlockSize = 64 * 1024
  private static let traceReads = ProcessInfo.processInfo.environment["GARDEN_FUSE_TRACE"] == "1"
  private let permits = GardenReadPermits.shared
  private let api: GardenAPI
  private let disk: GardenDiskCache
  private let domain: String
  private let namespace: String
  private var tickets: [String: GardenDownload] = [:]
  private var ticketFlights: [String: Task<GardenDownload, Error>] = [:]
  private var flights: [String: Task<Data, Error>] = [:]
  private(set) var remoteBytes = 0
  private(set) var cacheHits = 0

  init(api: GardenAPI, domainID: String, diskLimit: Int? = nil, directory: URL? = nil) {
    self.api = api
    domain = domainID
    namespace = SHA256.hash(data: Data(domainID.utf8)).map { String(format: "%02x", $0) }.joined()
    disk = directory != nil || diskLimit != nil
      ? GardenDiskCache(directory: directory, limit: diskLimit.map(Int64.init)) : .shared
  }

  func invalidate() {
    for task in flights.values { task.cancel() }
    flights.removeAll()
    for task in ticketFlights.values { task.cancel() }
    ticketFlights.removeAll()
    tickets.removeAll()
  }

  func read(node: GardenNode, offset: Int, length: Int, persist: Bool = true, path: String? = nil) async throws -> Data {
    guard offset >= 0, length >= 0, length <= 16 * Self.blockSize else { throw GardenAPIError.invalidResponse }
    if offset >= node.size { return Data() }
    let end = offset + min(length, node.size - offset)
    guard end > offset else { return Data() }
    let blockSize = length <= 128 * 1024 ? Self.smallBlockSize : Self.blockSize
    let first = offset / blockSize
    let last = (end - 1) / blockSize
    let blocks = try await withThrowingTaskGroup(of: (Int, Data).self) { group in
      var next = first
      for _ in 0..<min(GardenReadPermits.capacity, last - first + 1) {
        let index = next
        group.addTask { (index, try await self.block(node: node, index: index, blockSize: blockSize, persist: persist, path: path)) }
        next += 1
      }
      var result: [Int: Data] = [:]
      while let (index, bytes) = try await group.next() {
        result[index] = bytes
        if next <= last {
          let index = next
          group.addTask { (index, try await self.block(node: node, index: index, blockSize: blockSize, persist: persist, path: path)) }
          next += 1
        }
      }
      return result
    }
    var result = Data(capacity: end - offset)
    for index in first...last {
      try Task.checkCancellation()
      guard let bytes = blocks[index] else { throw GardenAPIError.invalidResponse }
      let start = max(offset - index * blockSize, 0)
      let count = min(end - (index * blockSize + start), bytes.count - start)
      guard count > 0 else { throw GardenAPIError.invalidResponse }
      result.append(bytes[start..<(start + count)])
    }
    guard result.count == end - offset else { throw GardenAPIError.invalidResponse }
    return result
  }

  private func ticket(node: GardenNode) async throws -> GardenDownload {
    let key = "\(node.id)-\(node.version)"
    if let current = tickets[key], current.expiresAt.timeIntervalSinceNow > 30 { return current }
    if let flight = ticketFlights[key] { return try await flight.value }
    let api = self.api
    let flight = Task {
      let ticket = try await api.download(id: node.id, version: node.version)
      guard ticket.size == node.size else { throw GardenAPIError.invalidResponse }
      return ticket
    }
    ticketFlights[key] = flight
    defer { ticketFlights.removeValue(forKey: key) }
    let ticket = try await flight.value
    tickets[key] = ticket
    return ticket
  }

  private func block(node: GardenNode, index: Int, blockSize: Int, persist: Bool, path: String?) async throws -> Data {
    let started = Date()
    let key = "\(node.id)-\(node.version)-\(blockSize)-\(index)"
    let length = min(blockSize, node.size - index * blockSize)
    let diskKey = "\(namespace)/\(key)"
    if let data = await GardenReadBuffer.shared.read(diskKey) {
      guard data.count == length else { throw GardenAPIError.invalidResponse }
      cacheHits += 1
      await GardenActivity.shared.record(domain: domain, name: path ?? node.name, action: "Read", source: "Memory cache", node: node.id, bytes: data.count, milliseconds: Date().timeIntervalSince(started) * 1000)
      return data
    }
    if persist, let data = try await disk.read(diskKey, expected: length) {
      await GardenReadBuffer.shared.store(data, key: diskKey)
      cacheHits += 1
      await GardenActivity.shared.record(domain: domain, name: path ?? node.name, action: "Read", source: "Disk cache", node: node.id, bytes: data.count, milliseconds: Date().timeIntervalSince(started) * 1000)
      return data
    }
    if let flight = flights[key] { return try await flight.value }
    let api = self.api
    let offset = index * blockSize
    let permits = self.permits
    let flight = Task<Data, Error> {
      let started = ContinuousClock.now
      let ticket = try await self.ticket(node: node)
      let authorized = ContinuousClock.now
      try await permits.acquire()
      let acquired = ContinuousClock.now
      defer { Task { await permits.release() } }
      defer {
        if Self.traceReads {
          let message = "Range node=\(node.id) version=\(node.version) offset=\(offset) length=\(length) "
            + "authorization=\(started.duration(to: authorized)) queue=\(authorized.duration(to: acquired)) "
            + "transfer=\(acquired.duration(to: .now))\n"
          FileHandle.standardError.write(Data(message.utf8))
        }
      }
      try Task.checkCancellation()
      if let url = ticket.url {
        var request = URLRequest(url: url)
        request.timeoutInterval = 60
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("bytes=\(offset)-\(offset + length - 1)", forHTTPHeaderField: "Range")
        let (data, response) = try await GardenObjectRequests.read(request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 206,
              response.value(forHTTPHeaderField: "Content-Range") == "bytes \(offset)-\(offset + length - 1)/\(node.size)",
              data.count == length else { throw GardenAPIError.invalidResponse }
        return data
      }
      var data = Data()
      while data.count < length {
        try Task.checkCancellation()
        let count = min(256 * 1024, length - data.count)
        let bytes = try await api.read(id: node.id, version: node.version,
          offset: offset + data.count, length: count)
        guard bytes.count == count else { throw GardenAPIError.invalidResponse }
        data.append(bytes)
      }
      return data
    }
    flights[key] = flight
    defer { flights.removeValue(forKey: key) }
    let data: Data
    do { data = try await flight.value }
    catch {
      await GardenActivity.shared.record(domain: domain, name: path ?? node.name, action: "Read failed", source: "Cloud",
        node: node.id, milliseconds: Date().timeIntervalSince(started) * 1000, error: error.localizedDescription)
      throw error
    }
    remoteBytes += data.count
    await GardenActivity.shared.record(domain: domain, name: path ?? node.name, action: "Read", source: "Cloud", node: node.id, bytes: data.count, milliseconds: Date().timeIntervalSince(started) * 1000)
    await GardenReadBuffer.shared.store(data, key: diskKey)
    if persist { try await disk.store(data, key: diskKey) }
    return data
  }
}
