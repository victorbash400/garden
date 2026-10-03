import Foundation

actor GardenDiskCache {
  static let shared = GardenDiskCache()
  private let directory: URL
  private let initialLimit: Int64?
  private var database: GardenCacheDatabase?
  private var watch: GardenCacheWatch?
  private var lastPublished: GardenCacheStatus?
  private var observers: [UUID: AsyncThrowingStream<GardenCacheStatus, Error>.Continuation] = [:]

  init(directory: URL? = nil, limit: Int64? = nil) {
    self.directory = (directory ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("GardenRanges", isDirectory: true)).resolvingSymlinksInPath()
    initialLimit = limit
  }

  func status() throws -> GardenCacheStatus {
    let db = try initialize()
    return try db.transaction { try status(db) }
  }

  func updates() throws -> AsyncThrowingStream<GardenCacheStatus, Error> {
    let current = try status()
    if watch == nil {
      watch = try GardenCacheWatch(url: directory.appendingPathComponent("index.sqlite-wal")) { [weak self] in
        Task { await self?.diskChanged() }
      }
    }
    lastPublished = current
    let id = UUID()
    return AsyncThrowingStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
      observers[id] = continuation
      continuation.yield(current)
      continuation.onTermination = { _ in Task { await self.removeObserver(id) } }
    }
  }

  private func removeObserver(_ id: UUID) {
    observers.removeValue(forKey: id)
    if observers.isEmpty { watch = nil; lastPublished = nil }
  }

  private func diskChanged() {
    do { publish(try status()) }
    catch {
      for observer in observers.values { observer.finish(throwing: error) }
      observers.removeAll()
      watch = nil
    }
  }

  private func publish(_ status: GardenCacheStatus) {
    guard status != lastPublished else { return }
    lastPublished = status
    for observer in observers.values { observer.yield(status) }
  }

  func setLimit(_ limit: Int64, persist: Bool = true) throws -> GardenCacheStatus {
    try GardenCachePolicy.validate(limit)
    let db = try initialize()
    let updated = try db.transaction {
      try trim(db, to: limit)
      if persist { try GardenCachePolicy.save(limit) }
      try db.execute("UPDATE budget SET bytes=? WHERE id=1", values: [Double(limit)])
      return try status(db)
    }
    publish(updated)
    return updated
  }

  func clear() async throws -> GardenCacheStatus {
    await GardenReadBuffer.shared.clear()
    let db = try initialize()
    let updated = try db.transaction {
      try trim(db, to: 0)
      return try status(db)
    }
    publish(updated)
    return updated
  }

  func read(_ key: String, expected: Int) throws -> Data? {
    let db = try initialize()
    return try db.transaction {
      guard !(try db.rows("SELECT key,size FROM blocks WHERE key=?", key: key)).isEmpty else { return nil }
      let url = directory.appendingPathComponent(key)
      guard FileManager.default.fileExists(atPath: url.path) else {
        try db.execute("DELETE FROM blocks WHERE key=?", key: key)
        return nil
      }
      let data = try Data(contentsOf: url)
      guard data.count == expected else {
        throw NSError(domain: "GardenCache", code: 2,
          userInfo: [NSLocalizedDescriptionKey: "A cached file block has an invalid size."])
      }
      try db.execute("UPDATE blocks SET used=?2 WHERE key=?1", key: key, values: [Date().timeIntervalSince1970])
      return data
    }
  }

  func store(_ data: Data, key: String) throws {
    let db = try initialize()
    try db.transaction {
      let limit = try db.rows("SELECT '',bytes FROM budget WHERE id=1").first!.1
      let reserved = Int64((data.count + 4095) / 4096 * 4096)
      guard limit > 0, reserved <= limit else { return }
      try remove(db, key: key)
      try trim(db, to: limit - reserved)
      let url = directory.appendingPathComponent(key)
      try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true,
        attributes: [.posixPermissions: 0o700])
      try data.write(to: url, options: [.atomic])
      do {
        let values = try url.resourceValues(forKeys: [.fileAllocatedSizeKey])
        guard let allocated = values.fileAllocatedSize, allocated <= limit else {
          throw NSError(domain: "GardenCache", code: 6,
            userInfo: [NSLocalizedDescriptionKey: "Cache block allocation exceeds the budget."])
        }
        try trim(db, to: limit - Int64(allocated))
        try db.execute("INSERT INTO blocks(key,size,used) VALUES(?,?,?)", key: key,
          values: [Double(allocated), Date().timeIntervalSince1970])
      } catch {
        try? FileManager.default.removeItem(at: url)
        throw error
      }
    }
    if !observers.isEmpty { publish(try status()) }
  }

  private func status(_ db: GardenCacheDatabase) throws -> GardenCacheStatus {
    let limit = try db.rows("SELECT '',bytes FROM budget WHERE id=1").first!.1
    let used = try db.rows("SELECT '',used FROM totals WHERE id=1").first!.1
    let blocks = try db.rows("SELECT '',blocks FROM totals WHERE id=1").first!.1
    return GardenCacheStatus(limit: limit, used: used, blocks: Int(blocks))
  }

  private func trim(_ db: GardenCacheDatabase, to limit: Int64) throws {
    var used = try db.rows("SELECT '',used FROM totals WHERE id=1").first!.1
    if used <= limit { return }
    while used > limit {
      let oldest = try db.rows("SELECT key,size FROM blocks ORDER BY used LIMIT 128")
      guard !oldest.isEmpty else { throw GardenAPIError.invalidResponse }
      for (key, size) in oldest {
        try remove(db, key: key)
        used -= size
        if used <= limit { break }
      }
    }
  }

  private func remove(_ db: GardenCacheDatabase, key: String) throws {
    let url = directory.appendingPathComponent(key)
    if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
    try db.execute("DELETE FROM blocks WHERE key=?", key: key)
  }

  private func initialize() throws -> GardenCacheDatabase {
    if let database { return database }
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    let db = try GardenCacheDatabase(url: directory.appendingPathComponent("index.sqlite"))
    try db.transaction {
      let limit = try initialLimit ?? GardenCachePolicy.read()
      if initialLimit == nil {
        try db.execute("INSERT INTO budget(id,bytes) VALUES(1,?) ON CONFLICT(id) DO UPDATE SET bytes=excluded.bytes",
          values: [Double(limit)])
      } else {
        try db.execute("INSERT OR IGNORE INTO budget(id,bytes) VALUES(1,?)", values: [Double(limit)])
      }
      // Recover disposable blocks, including caches created before the shared index.
      let ages = Dictionary(uniqueKeysWithValues: try db.rows("SELECT key,used FROM blocks"))
      try db.execute("DELETE FROM blocks")
      let namespaces = try FileManager.default.contentsOfDirectory(at: directory,
        includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey])
      for folder in namespaces {
        let name = folder.lastPathComponent
        let attributes = try folder.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard name.count == 64, attributes.isDirectory == true, attributes.isSymbolicLink != true else { continue }
        let files = try FileManager.default.contentsOfDirectory(at: folder,
          includingPropertiesForKeys: [.isRegularFileKey, .fileAllocatedSizeKey, .contentModificationDateKey])
        for url in files {
          let numbers = url.lastPathComponent.split(separator: "-")
          guard numbers.count == 3, numbers.allSatisfy({ Int($0) != nil }) else { continue }
          let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileAllocatedSizeKey, .contentModificationDateKey])
          guard values.isRegularFile == true, let size = values.fileAllocatedSize else { continue }
          let relative = "\(name)/\(url.lastPathComponent)"
          try db.execute("INSERT INTO blocks(key,size,used) VALUES(?,?,?)", key: relative,
            values: [Double(size), ages[relative].map(Double.init) ?? (values.contentModificationDate ?? .distantPast).timeIntervalSince1970])
        }
      }
      try trim(db, to: try status(db).limit)
    }
    database = db
    return db
  }
}
