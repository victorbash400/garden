import Foundation
import SQLite3

struct RemoteWriteState: Codable {
  let operationID: UUID
  let base: GardenNode
  var size: Int
  var baseLimit: Int
  var generation: Int
}

struct RemoteWriteExtent {
  let offset: Int
  let bytes: Data
}

final class RemoteWriteJournal {
  private let db: RemoteWriteDatabase
  private let limit: Int
  static let blockSize = 256 * 1024
  static let extentLimit = 4096
  static let fileLimit = 1 << 40

  init(url: URL, namespace: String, limit: Int) throws {
    guard limit >= 0, limit <= Self.fileLimit else { throw POSIXError(.EINVAL) }
    self.limit = limit
    db = try RemoteWriteDatabase(url: url, maximumBytes: limit + 16 * 1024 * 1024)
    try db.execute("CREATE TABLE IF NOT EXISTS identity(id INTEGER PRIMARY KEY CHECK(id=1),namespace TEXT NOT NULL)")
    try db.execute("INSERT OR IGNORE INTO identity VALUES(1,?)", [.text(namespace)])
    let matching = try db.statement("SELECT namespace FROM identity WHERE id=1") { statement in
      try db.step(statement) && sqlite3_column_text(statement, 0).map { String(cString: $0) } == namespace
    }
    guard matching else { throw POSIXError(.EACCES) }
    try db.execute("CREATE TABLE IF NOT EXISTS edits(node INTEGER PRIMARY KEY,payload BLOB NOT NULL)")
    try db.execute("CREATE TABLE IF NOT EXISTS extents(node INTEGER NOT NULL,start INTEGER NOT NULL,bytes BLOB NOT NULL CHECK(length(bytes)>0 AND length(bytes)<=262144),PRIMARY KEY(node,start))")
    try db.execute("CREATE TABLE IF NOT EXISTS totals(id INTEGER PRIMARY KEY CHECK(id=1),bytes INTEGER NOT NULL,extents INTEGER NOT NULL)")
    try db.execute("INSERT OR IGNORE INTO totals SELECT 1,COALESCE(SUM(length(bytes)),0),COUNT(*) FROM extents")
    try db.execute("CREATE TRIGGER IF NOT EXISTS extent_insert AFTER INSERT ON extents BEGIN UPDATE totals SET bytes=bytes+length(NEW.bytes),extents=extents+1 WHERE id=1; END")
    try db.execute("CREATE TRIGGER IF NOT EXISTS extent_delete AFTER DELETE ON extents BEGIN UPDATE totals SET bytes=bytes-length(OLD.bytes),extents=extents-1 WHERE id=1; END")
  }

  var used: Int {
    get throws {
      try db.statement("SELECT bytes FROM totals WHERE id=1") { statement in
        guard try db.step(statement) else { throw POSIXError(.EIO) }
        return Int(sqlite3_column_int64(statement, 0))
      }
    }
  }

  func state(_ node: Int) throws -> RemoteWriteState? {
    try db.statement("SELECT payload FROM edits WHERE node=?", [.number(node)]) { statement in
      guard try db.step(statement) else { return nil }
      let bytes = Data(bytes: sqlite3_column_blob(statement, 0), count: Int(sqlite3_column_bytes(statement, 0)))
      return try JSONDecoder().decode(RemoteWriteState.self, from: bytes)
    }
  }

  func pending() throws -> [RemoteWriteState] {
    try db.statement("SELECT payload FROM edits ORDER BY node") { statement in
      var result: [RemoteWriteState] = []
      while try db.step(statement) {
        let bytes = Data(bytes: sqlite3_column_blob(statement, 0), count: Int(sqlite3_column_bytes(statement, 0)))
        result.append(try JSONDecoder().decode(RemoteWriteState.self, from: bytes))
      }
      return result
    }
  }

  func extents(_ node: Int, offset: Int, length: Int) throws -> [RemoteWriteExtent] {
    guard offset >= 0, length >= 0, offset <= Self.fileLimit, length <= Self.fileLimit - offset else { throw POSIXError(.EINVAL) }
    if length == 0 { return [] }
    return try db.statement("SELECT start,bytes FROM extents WHERE node=? AND start<? AND start+length(bytes)>? ORDER BY start",
      [.number(node), .number(offset + length), .number(offset)]) { statement in
      var result: [RemoteWriteExtent] = []
      while try db.step(statement) {
        let bytes = Data(bytes: sqlite3_column_blob(statement, 1), count: Int(sqlite3_column_bytes(statement, 1)))
        result.append(RemoteWriteExtent(offset: Int(sqlite3_column_int64(statement, 0)), bytes: bytes))
      }
      return result
    }
  }

  func write(_ node: GardenNode, offset: Int, bytes: Data) throws {
    guard !node.folder, !node.deleted, offset >= 0, bytes.count <= 16 * 1024 * 1024,
      offset <= Self.fileLimit, bytes.count <= Self.fileLimit - offset else { throw POSIXError(.EINVAL) }
    if bytes.isEmpty { return }
    try db.transaction {
      var draft = try state(node.id) ?? RemoteWriteState(operationID: UUID(), base: node,
        size: node.size, baseLimit: node.size, generation: 0)
      let end = offset + bytes.count
      for extent in try extents(node.id, offset: offset, length: bytes.count) {
        try db.execute("DELETE FROM extents WHERE node=? AND start=?", [.number(node.id), .number(extent.offset)])
        if extent.offset < offset {
          try insert(node.id, offset: extent.offset, bytes: Data(extent.bytes.prefix(offset - extent.offset)))
        }
        let oldEnd = extent.offset + extent.bytes.count
        if oldEnd > end {
          try insert(node.id, offset: end, bytes: Data(extent.bytes.suffix(oldEnd - end)))
        }
      }
      var position = 0
      while position < bytes.count {
        let end = min(bytes.count, position + Self.blockSize)
        try insert(node.id, offset: offset + position, bytes: Data(bytes[position..<end]))
        position = end
      }
      try capacity()
      draft.size = max(draft.size, end)
      draft.generation += 1
      try save(draft)
    }
  }

  func truncate(_ node: GardenNode, size: Int) throws {
    guard !node.folder, !node.deleted, size >= 0, size <= Self.fileLimit else { throw POSIXError(.EINVAL) }
    try db.transaction {
      var draft = try state(node.id) ?? RemoteWriteState(operationID: UUID(), base: node,
        size: node.size, baseLimit: node.size, generation: 0)
      if size < draft.size {
        for extent in try extents(node.id, offset: size, length: draft.size - size) {
          try db.execute("DELETE FROM extents WHERE node=? AND start=?", [.number(node.id), .number(extent.offset)])
          if extent.offset < size {
            try insert(node.id, offset: extent.offset, bytes: Data(extent.bytes.prefix(size - extent.offset)))
          }
        }
      }
      draft.size = size
      draft.baseLimit = min(draft.baseLimit, size)
      draft.generation += 1
      try save(draft)
    }
  }

  func acknowledge(_ state: RemoteWriteState) throws {
    try db.transaction {
      guard let current = try self.state(state.base.id), current.operationID == state.operationID,
        current.generation == state.generation else { throw POSIXError(.EBUSY) }
      try db.execute("DELETE FROM extents WHERE node=?", [.number(state.base.id)])
      try db.execute("DELETE FROM edits WHERE node=?", [.number(state.base.id)])
    }
  }

  private func save(_ state: RemoteWriteState) throws {
    if try self.state(state.base.id) == nil {
      let count = try db.statement("SELECT count(*) FROM edits") { statement in
        guard try db.step(statement) else { throw POSIXError(.EIO) }
        return sqlite3_column_int(statement, 0)
      }
      guard count < 128 else { throw POSIXError(.ENOSPC) }
    }
    try db.execute("INSERT OR REPLACE INTO edits(node,payload) VALUES(?,?)",
      [.number(state.base.id), .bytes(try JSONEncoder().encode(state))])
  }

  private func insert(_ node: Int, offset: Int, bytes: Data) throws {
    try db.execute("INSERT INTO extents(node,start,bytes) VALUES(?,?,?)", [.number(node), .number(offset), .bytes(bytes)])
  }

  private func capacity() throws {
    try db.statement("SELECT bytes,extents FROM totals WHERE id=1") { statement in
      guard try db.step(statement) else { throw POSIXError(.EIO) }
      guard sqlite3_column_int64(statement, 0) <= limit,
        sqlite3_column_int(statement, 1) <= Self.extentLimit else { throw POSIXError(.ENOSPC) }
    }
  }
}
