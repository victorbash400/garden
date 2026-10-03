import CryptoKit
import Foundation

struct GardenDownload: Sendable {
  let url: URL?
  let size: Int
  let expiresAt: Date
}

actor GardenRangeCache {
  static let blockSize = 1024 * 1024
  private let permits = GardenReadPermits()
  private let api: GardenAPI
  private let directory: URL
  private let diskLimit: Int
  private var tickets: [String: GardenDownload] = [:]
  private var flights: [String: Task<Data, Error>] = [:]
  private var entries: [String: (size: Int, used: Date)] = [:]
  private var initialized = false
  private(set) var remoteBytes = 0
  private(set) var cacheHits = 0

  init(api: GardenAPI, domainID: String, diskLimit: Int = 512 * 1024 * 1024, directory: URL? = nil) {
    self.api = api
    self.diskLimit = diskLimit
    let name = SHA256.hash(data: Data(domainID.utf8)).map { String(format: "%02x", $0) }.joined()
    self.directory = directory ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("GardenRanges/\(name)", isDirectory: true)
  }

  func invalidate() {
    for task in flights.values { task.cancel() }
    flights.removeAll()
    tickets.removeAll()
  }

  func read(node: GardenNode, offset: Int, length: Int) async throws -> Data {
    guard diskLimit >= Self.blockSize, offset >= 0, length >= 0, length <= 16 * Self.blockSize else { throw GardenAPIError.invalidResponse }
    if offset >= node.size { return Data() }
    let end = offset + min(length, node.size - offset)
    var result = Data()
    var cursor = offset
    while cursor < end {
      try Task.checkCancellation()
      let index = cursor / Self.blockSize
      let bytes = try await block(node: node, index: index)
      let start = cursor % Self.blockSize
      let count = min(end - cursor, bytes.count - start)
      guard count > 0 else { throw GardenAPIError.invalidResponse }
      result.append(bytes[start..<(start + count)])
      cursor += count
    }
    try Task.checkCancellation()
    return result
  }

  private func initialize() throws {
    if initialized { return }
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    for url in try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) {
      let values = try url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
      entries[url.lastPathComponent] = (values.fileSize ?? 0, values.contentModificationDate ?? .distantPast)
    }
    initialized = true
    try evict(adding: 0)
  }

  private func evict(adding: Int) throws {
    var total = entries.values.reduce(0) { $0 + $1.size }
    for (key, entry) in entries.sorted(by: { $0.value.used < $1.value.used }) {
      if total + adding <= diskLimit { break }
      try FileManager.default.removeItem(at: directory.appendingPathComponent(key))
      entries.removeValue(forKey: key)
      total -= entry.size
    }
  }

  private func ticket(node: GardenNode) async throws -> GardenDownload {
    let key = "\(node.id)-\(node.version)"
    if let current = tickets[key], current.expiresAt.timeIntervalSinceNow > 30 { return current }
    let ticket = try await api.download(id: node.id, version: node.version)
    guard ticket.size == node.size else { throw GardenAPIError.invalidResponse }
    tickets[key] = ticket
    return ticket
  }

  private func block(node: GardenNode, index: Int) async throws -> Data {
    try initialize()
    let key = "\(node.id)-\(node.version)-\(index)"
    let length = min(Self.blockSize, node.size - index * Self.blockSize)
    let path = directory.appendingPathComponent(key)
    if entries[key] != nil {
      let data = try Data(contentsOf: path)
      guard data.count == length else { throw GardenAPIError.invalidResponse }
      entries[key] = (length, Date())
      cacheHits += 1
      return data
    }
    if let flight = flights[key] { return try await flight.value }
    let api = self.api
    let offset = index * Self.blockSize
    let permits = self.permits
    let flight = Task<Data, Error> {
      try await permits.acquire()
      defer { Task { await permits.release() } }
      try Task.checkCancellation()
      let ticket = try await self.ticket(node: node)
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
    let data = try await flight.value
    remoteBytes += data.count
    try evict(adding: data.count)
    try data.write(to: path, options: .atomic)
    entries[key] = (data.count, Date())
    return data
  }
}
