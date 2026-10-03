import Foundation
import SQLite3

final class GardenCacheDatabase {
  private var database: OpaquePointer?
  private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

  init(url: URL) throws {
    guard sqlite3_open_v2(url.path, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK else {
      throw failure()
    }
    sqlite3_busy_timeout(database, 5000)
    try execute("PRAGMA journal_mode=WAL")
    try execute("CREATE TABLE IF NOT EXISTS blocks (key TEXT PRIMARY KEY, size INTEGER NOT NULL, used REAL NOT NULL)")
    try execute("CREATE INDEX IF NOT EXISTS block_age ON blocks(used)")
    try execute("CREATE TABLE IF NOT EXISTS budget (id INTEGER PRIMARY KEY CHECK(id=1), bytes INTEGER NOT NULL)")
  }

  deinit { sqlite3_close(database) }

  func execute(_ sql: String, key: String? = nil, values: [Double] = []) throws {
    let statement = try prepare(sql, key: key, values: values)
    defer { sqlite3_finalize(statement) }
    let status = sqlite3_step(statement)
    guard status == SQLITE_DONE || status == SQLITE_ROW else { throw failure() }
  }

  func rows(_ sql: String, key: String? = nil) throws -> [(String, Int64)] {
    let statement = try prepare(sql, key: key)
    defer { sqlite3_finalize(statement) }
    var result: [(String, Int64)] = []
    while true {
      let status = sqlite3_step(statement)
      if status == SQLITE_DONE { return result }
      guard status == SQLITE_ROW else { throw failure() }
      let name = sqlite3_column_text(statement, 0).map { String(cString: $0) } ?? ""
      result.append((name, sqlite3_column_int64(statement, 1)))
    }
  }

  func transaction<T>(_ operation: () throws -> T) throws -> T {
    try execute("BEGIN IMMEDIATE")
    do {
      let result = try operation()
      try execute("COMMIT")
      return result
    } catch {
      try? execute("ROLLBACK")
      throw error
    }
  }

  private func prepare(_ sql: String, key: String?, values: [Double] = []) throws -> OpaquePointer {
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK, let statement else { throw failure() }
    var index: Int32 = 1
    if let key {
      guard sqlite3_bind_text(statement, index, key, -1, transient) == SQLITE_OK else {
        sqlite3_finalize(statement)
        throw failure()
      }
      index += 1
    }
    for value in values {
      guard sqlite3_bind_double(statement, index, value) == SQLITE_OK else {
        sqlite3_finalize(statement)
        throw failure()
      }
      index += 1
    }
    return statement
  }

  private func failure() -> NSError {
    NSError(domain: "GardenCache", code: Int(sqlite3_errcode(database)),
      userInfo: [NSLocalizedDescriptionKey: "Cache index error: \(String(cString: sqlite3_errmsg(database)))"])
  }
}
