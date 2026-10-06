import CryptoKit
import Foundation

struct GardenDownload: Sendable {
  let url: URL?
  let size: Int
  let expiresAt: Date
}

actor GardenRangeCache {
  static let blockSize = 1024 * 1024
  private static let smallBlockSize = GardenReadWindow.pageSize
  private static let traceReads = ProcessInfo.processInfo.environment["GARDEN_FUSE_TRACE"] == "1"
  private let permits = GardenReadPermits.shared
  private let api: GardenAPI
  private let disk: GardenDiskCache
  private let domain: String
  private let namespace: String
  private var tickets: [String: GardenDownload] = [:]
  private var ticketFlights: [String: Task<GardenDownload, Error>] = [:]
  private struct Flight {
    let id: UUID
    let offset: Int
    let length: Int
    let task: Task<Data, Error>
  }
  private var flights: [String: Flight] = [:]
  private var windows: [String: GardenReadWindow] = [:]
  private var indexes: [String: GardenWebMIndex] = [:]
  private var mp4Indexes: [String: GardenMP4Index] = [:]
  private var readAhead: [String: (UUID, Task<Void, Never>)] = [:]
  private var readAheadDone: [String: Set<Int>] = [:]
  private var readAheadCursor: [String: Int] = [:]
  private var generation = 0
  private let readRange: (@Sendable (GardenNode, Int, Int) async throws -> Data)?
  private(set) var remoteBytes = 0
  private(set) var cacheHits = 0

  init(api: GardenAPI, domainID: String, diskLimit: Int? = nil, directory: URL? = nil,
    readRange: (@Sendable (GardenNode, Int, Int) async throws -> Data)? = nil) {
    self.api = api
    self.readRange = readRange
    domain = domainID
    namespace = SHA256.hash(data: Data(domainID.utf8)).map { String(format: "%02x", $0) }.joined()
    disk = directory != nil || diskLimit != nil
      ? GardenDiskCache(directory: directory, limit: diskLimit.map(Int64.init)) : .shared
  }

  func invalidate() async {
    generation += 1
    let pendingReads = Array(readAhead.values.map(\.1))
    let pendingFlights = Array(flights.values.map(\.task))
    let pendingTickets = Array(ticketFlights.values)
    windows.removeAll()
    indexes.removeAll()
    mp4Indexes.removeAll()
    for (_, task) in readAhead.values { task.cancel() }
    readAhead.removeAll()
    readAheadDone.removeAll()
    readAheadCursor.removeAll()
    for flight in flights.values { flight.task.cancel() }
    flights.removeAll()
    for task in ticketFlights.values { task.cancel() }
    ticketFlights.removeAll()
    tickets.removeAll()
    for task in pendingTickets { _ = await task.result }
    for task in pendingFlights { _ = await task.result }
    for task in pendingReads { await task.value }
  }

  func read(node: GardenNode, offset: Int, length: Int, persist: Bool = true, path: String? = nil) async throws -> Data {
    guard offset >= 0, length >= 0, length <= 16 * Self.blockSize else { throw GardenAPIError.invalidResponse }
    if offset >= node.size { return Data() }
    let end = offset + min(length, node.size - offset)
    guard end > offset else { return Data() }
    let blockSize = Self.smallBlockSize
    let windowKey = "\(node.id)-\(node.version)"
    var window = windows[windowKey] ?? GardenReadWindow()
    let fetchSize = persist ? window.observe(offset: offset, length: length) : blockSize
    if windows.count >= 128, windows[windowKey] == nil { windows.removeAll() }
    windows[windowKey] = window
    let first = offset / blockSize
    let last = (end - 1) / blockSize
    let blocks = try await withThrowingTaskGroup(of: (Int, Data).self) { group in
      var next = first
      for _ in 0..<min(GardenReadPermits.capacity, last - first + 1) {
        let index = next
        group.addTask { (index, try await self.block(node: node, index: index, fetchSize: fetchSize, persist: persist, path: path)) }
        next += 1
      }
      var result: [Int: Data] = [:]
      while let (index, bytes) = try await group.next() {
        result[index] = bytes
        if next <= last {
          let index = next
          group.addTask { (index, try await self.block(node: node, index: index, fetchSize: fetchSize, persist: persist, path: path)) }
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
    if persist {
      if fetchSize == GardenReadWindow.maximumSize {
        schedulePayload(node: node, after: end, path: path, count: window.payloadReadAheadBlocks)
      }
      scheduleReadAhead(node: node, offset: offset, path: path)
    }
    return result
  }

  private func schedulePayload(node: GardenNode, after offset: Int, path: String?, count: Int) {
    let start = ((offset - 1) / Self.blockSize + 1) * Self.blockSize
    guard start < node.size else { return }
    for index in 0..<min(count, (node.size - 1 - start) / Self.blockSize + 1) {
      prefetchPayload(node: node, start: start + index * Self.blockSize, path: path)
    }
  }

  private func prefetchPayload(node: GardenNode, start: Int, path: String?) {
    guard start < node.size, readAhead.count < 48 else { return }
    let end = min(start + Self.blockSize, node.size)
    let key = "\(node.id)-\(node.version)-payload-\(start)"
    guard readAhead[key] == nil else { return }
    let id = UUID()
    let task = Task {
      defer { if readAhead[key]?.0 == id { readAhead.removeValue(forKey: key) } }
      do {
        for page in stride(from: start, to: end, by: Self.smallBlockSize) {
          try Task.checkCancellation()
          _ = try await self.block(node: node, index: page / Self.smallBlockSize,
            fetchSize: Self.blockSize, persist: true, path: path, speculative: true)
        }
      } catch is CancellationError { }
      catch { FileHandle.standardError.write(Data("Garden payload read-ahead: \(error.localizedDescription)\n".utf8)) }
    }
    readAhead[key] = (id, task)
  }

  private func scheduleReadAhead(node: GardenNode, offset: Int, path: String?) {
    let name = "\(node.id)-\(node.version)"
    guard indexes[name] != nil || mp4Indexes[name] != nil else { return }
    readAheadCursor[name] = offset
    let excluded = readAheadDone[name] ?? []
    let pages: [Int]
    if let index = indexes[name] { pages = index.nextPages(after: offset, count: 12, excluding: excluded) }
    else if let index = mp4Indexes[name] { pages = index.nextPages(after: offset, count: 12, excluding: excluded) }
    else { return }
    for page in pages {
      let key = "\(name)-\(page)"
      guard readAhead[key] == nil, readAheadDone[name]?.contains(page) != true else { continue }
      guard readAhead.count < 48 else { break }
      let id = UUID()
      let task = Task {
        defer { if readAhead[key]?.0 == id { readAhead.removeValue(forKey: key) } }
        do {
          _ = try await self.block(node: node, index: page, fetchSize: Self.smallBlockSize,
            persist: true, path: path, speculative: true)
          try Task.checkCancellation()
          self.readAheadDone[name, default: []].insert(page)
          if self.readAhead[key]?.0 == id { self.readAhead.removeValue(forKey: key) }
          if let cursor = self.readAheadCursor[name] {
            self.scheduleReadAhead(node: node, offset: cursor, path: path)
          }
        } catch is CancellationError { }
        catch { FileHandle.standardError.write(Data("Garden read-ahead: \(error.localizedDescription)\n".utf8)) }
      }
      readAhead[key] = (id, task)
    }
  }

  private func discoverIndex(node: GardenNode, data: Data, offset: Int) {
    let name = "\(node.id)-\(node.version)"
    if var index = mp4Indexes[name] {
      index.discoverFooter(data, offset: offset, fileSize: node.size)
      mp4Indexes[name] = index
      return
    }
    if offset == 0, indexes[name] == nil, mp4Indexes.count < 128,
      let index = GardenMP4Index.parse(data, fileSize: node.size) {
      mp4Indexes[name] = index
      prefetchMP4Footer(node: node)
      return
    }
    var index = indexes[name]
    let initial = index == nil
    if index == nil, offset == 0, indexes.count < 128 {
      index = GardenWebMIndex.parse(data, fileSize: node.size)
    }
    guard var index else { return }
    index.discoverClusters(in: data, offset: offset, fileSize: node.size)
    indexes[name] = index
    if initial { prefetchPayload(node: node, start: 0, path: nil) }
  }

  private func prefetchMP4Footer(node: GardenNode) {
    guard readAhead.count < 48 else { return }
    let key = "\(node.id)-\(node.version)-footer"
    guard readAhead[key] == nil else { return }
    let id = UUID()
    let task = Task {
      defer { if readAhead[key]?.0 == id { readAhead.removeValue(forKey: key) } }
      do {
        _ = try await self.block(node: node, index: (node.size - 1) / Self.smallBlockSize,
          fetchSize: Self.smallBlockSize, persist: true, path: nil, speculative: true)
        try Task.checkCancellation()
        self.scheduleReadAhead(node: node, offset: self.readAheadCursor["\(node.id)-\(node.version)"] ?? 0, path: nil)
      } catch is CancellationError { }
      catch { FileHandle.standardError.write(Data("Garden MP4 index read: \(error.localizedDescription)\n".utf8)) }
    }
    readAhead[key] = (id, task)
  }

  private func ticket(node: GardenNode) async throws -> GardenDownload {
    let key = "\(node.id)-\(node.version)"
    if let current = tickets[key], current.expiresAt.timeIntervalSinceNow > 30 { return current }
    if let flight = ticketFlights[key] { return try await flight.value }
    let api = self.api
    let currentGeneration = generation
    let flight = Task {
      let ticket = try await api.download(id: node.id, version: node.version)
      guard ticket.size == node.size else { throw GardenAPIError.invalidResponse }
      return ticket
    }
    ticketFlights[key] = flight
    defer { if generation == currentGeneration { ticketFlights.removeValue(forKey: key) } }
    let ticket = try await flight.value
    try Task.checkCancellation()
    guard generation == currentGeneration else { throw CancellationError() }
    tickets[key] = ticket
    return ticket
  }

  private func key(_ node: GardenNode, index: Int) -> String {
    "\(namespace)/\(node.id)-\(node.version)-\(Self.smallBlockSize)-\(index)"
  }

  private func cached(node: GardenNode, index: Int, persist: Bool) async throws -> Data? {
    let offset = index * Self.smallBlockSize
    // Read old bulk blocks as well, so changing request sizes does not download the same data again.
    for size in [Self.blockSize, Self.smallBlockSize] {
      let start = offset / size * size
      let cacheKey = "\(namespace)/\(node.id)-\(node.version)-\(size)-\(offset / size)"
      let expected = min(size, node.size - start)
      var bytes = await GardenReadBuffer.shared.read(cacheKey)
      if bytes == nil, persist { bytes = try await disk.read(cacheKey, expected: expected) }
      if let bytes {
        guard bytes.count == expected else { throw GardenAPIError.invalidResponse }
        let end = min(offset + Self.smallBlockSize, node.size) - start
        return Data(bytes[(offset - start)..<end])
      }
    }
    return nil
  }

  private func block(node: GardenNode, index: Int, fetchSize: Int, persist: Bool, path: String?, speculative: Bool = false) async throws -> Data {
    let started = Date()
    let offset = index * Self.smallBlockSize
    let length = min(Self.smallBlockSize, node.size - offset)
    if let data = try await cached(node: node, index: index, persist: persist) {
      discoverIndex(node: node, data: data, offset: offset)
      cacheHits += 1
      await GardenActivity.shared.record(domain: domain, name: path ?? node.name, action: "Read", source: "Cache",
        node: node.id, bytes: data.count, milliseconds: Date().timeIntervalSince(started) * 1000)
      return data
    }
    let prefix = "\(node.id)-\(node.version)-"
    if let flight = flights.first(where: { name, flight in
      name.hasPrefix(prefix) && flight.offset <= offset && flight.offset + flight.length >= offset + length
    })?.value {
      if !speculative { await permits.promote(flight.id) }
      let data = try await flight.task.value
      return Data(data[(offset - flight.offset)..<(offset - flight.offset + length)])
    }
    let start = offset / fetchSize * fetchSize
    let end = min(start + fetchSize, node.size)
    let flightKey = "\(prefix)\(start)-\(end)"
    let id = UUID()
    let currentGeneration = generation
    let existingFlights = flights.filter { $0.key.hasPrefix(prefix) }.map(\.value)
    let task = Task<Data, Error> {
      var result = Data()
      var missingStart: Int?
      for page in stride(from: start, to: end, by: Self.smallBlockSize) {
        try Task.checkCancellation()
        if let data = try await self.cached(node: node, index: page / Self.smallBlockSize, persist: persist) {
          if let missingStart {
            result.append(try await self.fetchAndStore(node: node, offset: missingStart, end: page,
              persist: persist, path: path, speculative: speculative, permitID: id,
              generation: currentGeneration, started: started))
          }
          missingStart = nil
          result.append(data)
        } else if let existing = existingFlights.first(where: {
          $0.offset <= page && $0.offset + $0.length >= min(page + Self.smallBlockSize, end)
        }) {
          if let missingStart {
            result.append(try await self.fetchAndStore(node: node, offset: missingStart, end: page,
              persist: persist, path: path, speculative: speculative, permitID: id,
              generation: currentGeneration, started: started))
          }
          missingStart = nil
          if !speculative { await self.permits.promote(existing.id) }
          let bytes = try await existing.task.value
          let pageEnd = min(page + Self.smallBlockSize, end)
          result.append(bytes[(page - existing.offset)..<(pageEnd - existing.offset)])
        } else if missingStart == nil { missingStart = page }
      }
      if let missingStart {
        result.append(try await self.fetchAndStore(node: node, offset: missingStart, end: end,
          persist: persist, path: path, speculative: speculative, permitID: id,
          generation: currentGeneration, started: started))
      }
      return result
    }
    flights[flightKey] = Flight(id: id, offset: start, length: end - start, task: task)
    defer {
      if flights[flightKey]?.id == id { flights.removeValue(forKey: flightKey) }
      Task { await self.permits.forget(id) }
    }
    do {
      let data = try await task.value
      return Data(data[(offset - start)..<(offset - start + length)])
    } catch {
      await GardenActivity.shared.record(domain: domain, name: path ?? node.name, action: "Read failed", source: "Cloud",
        node: node.id, milliseconds: Date().timeIntervalSince(started) * 1000, error: error.localizedDescription)
      throw error
    }
  }

  private func fetchAndStore(node: GardenNode, offset: Int, end: Int, persist: Bool,
    path: String?, speculative: Bool, permitID: UUID, generation: Int, started: Date) async throws -> Data {
    let bytes = try await download(node: node, offset: offset, length: end - offset,
      speculative: speculative, permitID: permitID)
    guard bytes.count == end - offset else { throw GardenAPIError.invalidResponse }
    try Task.checkCancellation()
    guard generation == self.generation else { throw CancellationError() }
    remoteBytes += bytes.count
    await GardenActivity.shared.record(domain: domain, name: path ?? node.name, action: "Read", source: "Cloud",
      node: node.id, bytes: bytes.count, milliseconds: Date().timeIntervalSince(started) * 1000)
    for page in stride(from: offset, to: end, by: Self.smallBlockSize) {
      let pageEnd = min(page + Self.smallBlockSize, end)
      let data = Data(bytes[(page - offset)..<(pageEnd - offset)])
      discoverIndex(node: node, data: data, offset: page)
      let pageKey = key(node, index: page / Self.smallBlockSize)
      await GardenReadBuffer.shared.store(data, key: pageKey)
      if persist { try await disk.store(data, key: pageKey) }
    }
    return bytes
  }

  private func download(node: GardenNode, offset: Int, length: Int, speculative: Bool, permitID: UUID) async throws -> Data {
    if let readRange { return try await readRange(node, offset, length) }
    let started = ContinuousClock.now
    let ticket = try await ticket(node: node)
    let authorized = ContinuousClock.now
    try await permits.acquire(id: permitID, speculative: speculative)
    let acquired = ContinuousClock.now
    defer { Task { await self.permits.release() } }
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
      let bytes = try await api.read(id: node.id, version: node.version, offset: offset + data.count, length: count)
      guard bytes.count == count else { throw GardenAPIError.invalidResponse }
      data.append(bytes)
    }
    return data
  }
}
