import Foundation
import SQLite3

enum RemoteWriteValue {
  case number(Int), text(String), bytes(Data)
}

final class RemoteWriteDatabase {
  private var db: OpaquePointer?
  private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

  init(url: URL, maximumBytes: Int) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    guard sqlite3_open_v2(url.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil) == SQLITE_OK else {
      let error = failure()
      sqlite3_close(db)
      db = nil
      throw error
    }
    do {
      let pageSize = try statement("PRAGMA page_size") { pointer in
        guard try step(pointer) else { throw POSIXError(.EIO) }
        return Int(sqlite3_column_int(pointer, 0))
      }
      guard pageSize > 0, maximumBytes >= pageSize else { throw POSIXError(.EINVAL) }
      try execute("PRAGMA max_page_count=\(maximumBytes / pageSize)")
      try execute("PRAGMA journal_mode=WAL")
      try execute("PRAGMA synchronous=FULL")
      try execute("PRAGMA fullfsync=ON")
      try execute("PRAGMA journal_size_limit=0")
      try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    } catch { sqlite3_close(db); db = nil; throw error }
  }

  deinit { sqlite3_close(db) }

  func statement<T>(_ sql: String, _ values: [RemoteWriteValue] = [], read: (OpaquePointer) throws -> T) throws -> T {
    var pointer: OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &pointer, nil) == SQLITE_OK, let pointer else { throw failure() }
    defer { sqlite3_finalize(pointer) }
    for (index, value) in values.enumerated() {
      let position = Int32(index + 1)
      let result: Int32
      switch value {
      case .number(let number): result = sqlite3_bind_int64(pointer, position, Int64(number))
      case .text(let text): result = sqlite3_bind_text(pointer, position, text, -1, transient)
      case .bytes(let bytes):
        result = bytes.withUnsafeBytes { sqlite3_bind_blob(pointer, position, $0.baseAddress, Int32($0.count), transient) }
      }
      guard result == SQLITE_OK else { throw failure() }
    }
    return try read(pointer)
  }

  func execute(_ sql: String, _ values: [RemoteWriteValue] = []) throws {
    try statement(sql, values) { pointer in
      let status = sqlite3_step(pointer)
      guard status == SQLITE_DONE || status == SQLITE_ROW else { throw failure() }
    }
  }

  func transaction<T>(_ operation: () throws -> T) throws -> T {
    try execute("BEGIN IMMEDIATE")
    do {
      let value = try operation()
      try execute("COMMIT")
      return value
    } catch { try? execute("ROLLBACK"); throw error }
  }

  func step(_ pointer: OpaquePointer) throws -> Bool {
    let status = sqlite3_step(pointer)
    if status == SQLITE_DONE { return false }
    guard status == SQLITE_ROW else { throw failure() }
    return true
  }

  private func failure() -> Error {
    if sqlite3_errcode(db) == SQLITE_FULL { return POSIXError(.ENOSPC) }
    return NSError(domain: "GardenWriteJournal", code: Int(sqlite3_errcode(db)),
      userInfo: [NSLocalizedDescriptionKey: String(cString: sqlite3_errmsg(db))])
  }
}
