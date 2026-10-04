import Foundation
import SQLite3

final class RemoteMutationJournal {
  private var db: OpaquePointer?
  private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
  static let capacity = 128

  init(url: URL, namespace: String) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    guard sqlite3_open_v2(url.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK else {
      let error = failure()
      sqlite3_close(db)
      db = nil
      throw error
    }
    do {
      try execute("PRAGMA journal_mode=WAL")
      try execute("PRAGMA synchronous=FULL")
      try execute("PRAGMA fullfsync=ON")
      try execute("CREATE TABLE IF NOT EXISTS identity(id INTEGER PRIMARY KEY CHECK(id=1),namespace TEXT NOT NULL)")
      try execute("CREATE TABLE IF NOT EXISTS pending(sequence INTEGER PRIMARY KEY AUTOINCREMENT,id TEXT NOT NULL UNIQUE,payload BLOB NOT NULL CHECK(length(payload)<=16384))")
      let bind = try prepare("INSERT OR IGNORE INTO identity(id,namespace) VALUES(1,?)")
      sqlite3_bind_text(bind, 1, namespace, -1, transient)
      let result = sqlite3_step(bind)
      sqlite3_finalize(bind)
      guard result == SQLITE_DONE else { throw failure() }
      let identity = try prepare("SELECT namespace FROM identity WHERE id=1")
      defer { sqlite3_finalize(identity) }
      guard sqlite3_step(identity) == SQLITE_ROW,
        sqlite3_column_text(identity, 0).map({ String(cString: $0) }) == namespace else {
        throw POSIXError(.EACCES)
      }
      try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    } catch { sqlite3_close(db); db = nil; throw error }
  }

  deinit { sqlite3_close(db) }

  func append(_ mutation: RemoteMutation) throws {
    let payload = try JSONEncoder().encode(mutation)
    guard payload.count <= 16384 else { throw POSIXError(.ENAMETOOLONG) }
    try execute("BEGIN IMMEDIATE")
    do {
      let count = try prepare("SELECT count(*) FROM pending")
      let result = sqlite3_step(count)
      let size = sqlite3_column_int(count, 0)
      sqlite3_finalize(count)
      guard result == SQLITE_ROW else { throw failure() }
      guard size < Self.capacity else { throw POSIXError(.ENOSPC) }
      let insert = try prepare("INSERT INTO pending(id,payload) VALUES(?,?)")
      defer { sqlite3_finalize(insert) }
      sqlite3_bind_text(insert, 1, mutation.operationId.uuidString, -1, transient)
      _ = payload.withUnsafeBytes { sqlite3_bind_blob(insert, 2, $0.baseAddress, Int32($0.count), transient) }
      guard sqlite3_step(insert) == SQLITE_DONE else { throw failure() }
      try execute("COMMIT")
    } catch { try? execute("ROLLBACK"); throw error }
  }

  func first() throws -> RemoteMutation? {
    let statement = try prepare("SELECT payload FROM pending ORDER BY sequence LIMIT 1")
    defer { sqlite3_finalize(statement) }
    let result = sqlite3_step(statement)
    if result == SQLITE_DONE { return nil }
    guard result == SQLITE_ROW else { throw failure() }
    let payload = Data(bytes: sqlite3_column_blob(statement, 0), count: Int(sqlite3_column_bytes(statement, 0)))
    return try JSONDecoder().decode(RemoteMutation.self, from: payload)
  }

  func acknowledge(_ id: UUID) throws {
    let statement = try prepare("DELETE FROM pending WHERE id=? AND sequence=(SELECT min(sequence) FROM pending)")
    defer { sqlite3_finalize(statement) }
    sqlite3_bind_text(statement, 1, id.uuidString, -1, transient)
    guard sqlite3_step(statement) == SQLITE_DONE else { throw failure() }
    guard sqlite3_changes(db) == 1 else { throw POSIXError(.EINVAL) }
  }

  private func execute(_ sql: String) throws {
    guard sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK else { throw failure() }
  }

  private func prepare(_ sql: String) throws -> OpaquePointer {
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK, let statement else { throw failure() }
    return statement
  }

  private func failure() -> NSError {
    NSError(domain: "GardenMutationJournal", code: Int(sqlite3_errcode(db)),
      userInfo: [NSLocalizedDescriptionKey: String(cString: sqlite3_errmsg(db))])
  }
}
