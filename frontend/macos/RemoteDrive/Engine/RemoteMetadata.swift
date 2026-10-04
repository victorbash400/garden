import Foundation
import SQLite3

final class RemoteMetadata {
  private var db: OpaquePointer?
  private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

  init(url: URL, namespace: String) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    guard sqlite3_open_v2(url.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK else {
      let error = failure()
      sqlite3_close(db)
      db = nil
      throw error
    }
    do { try configure(namespace: namespace) }
    catch { sqlite3_close(db); db = nil; throw error }
  }

  private func configure(namespace: String) throws {
    try execute("PRAGMA journal_mode=WAL")
    try execute("CREATE TABLE IF NOT EXISTS nodes(id INTEGER PRIMARY KEY,parent INTEGER NOT NULL,name TEXT NOT NULL,payload BLOB NOT NULL)")
    try execute("CREATE INDEX IF NOT EXISTS children_by_name ON nodes(parent,name COLLATE NOCASE,id)")
    try execute("DROP INDEX IF EXISTS children")
    try execute("CREATE TABLE IF NOT EXISTS cursor(id INTEGER PRIMARY KEY CHECK(id=1),revision INTEGER NOT NULL)")
    try execute("CREATE TABLE IF NOT EXISTS identity(id INTEGER PRIMARY KEY CHECK(id=1),namespace TEXT NOT NULL)")
    let binding = try prepare("INSERT OR IGNORE INTO identity(id,namespace) VALUES(1,?)")
    sqlite3_bind_text(binding, 1, namespace, -1, transient)
    guard sqlite3_step(binding) == SQLITE_DONE else { sqlite3_finalize(binding); throw failure() }
    sqlite3_finalize(binding)
    let identity = try prepare("SELECT namespace FROM identity WHERE id=1")
    defer { sqlite3_finalize(identity) }
    guard sqlite3_step(identity) == SQLITE_ROW,
      sqlite3_column_text(identity, 0).map({ String(cString: $0) }) == namespace else {
      throw NSError(domain: "GardenRemoteMetadata", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "This metadata index belongs to another drive."])
    }
  }

  deinit { sqlite3_close(db) }

  var revision: Int? {
    get throws {
      let statement = try prepare("SELECT revision FROM cursor WHERE id=1")
      defer { sqlite3_finalize(statement) }
      let status = sqlite3_step(statement)
      if status == SQLITE_DONE { return nil }
      guard status == SQLITE_ROW else { throw failure() }
      return Int(sqlite3_column_int64(statement, 0))
    }
  }

  func reset(nodes: [GardenNode], revision: Int) throws {
    try transaction {
      try execute("DELETE FROM nodes")
      for node in nodes { try store(node) }
      try saveRevision(revision)
    }
  }

  func apply(_ change: GardenChange) throws {
    try transaction {
      let current = try revision ?? 0
      if change.revision <= current { return }
      guard change.revision == current + 1 else { throw GardenAPIError.invalidResponse }
      guard let node = change.node else { throw GardenAPIError.invalidResponse }
      try store(node)
      try saveRevision(change.revision)
    }
  }

  func node(_ id: Int) throws -> GardenNode? {
    try query("SELECT payload FROM nodes WHERE id=?", number: id).first
  }

  func children(_ parent: Int) throws -> [GardenNode] {
    try query("SELECT payload FROM nodes WHERE parent=? ORDER BY name COLLATE NOCASE,id", number: parent)
  }

  func lookup(_ path: String) throws -> GardenNode? {
    var node: GardenNode?
    var parent = 0
    for component in path.split(separator: "/") {
      guard component != ".", component != ".." else { throw POSIXError(.EINVAL) }
      let statement = try prepare("SELECT payload FROM nodes WHERE parent=? AND name=? COLLATE NOCASE")
      defer { sqlite3_finalize(statement) }
      sqlite3_bind_int64(statement, 1, Int64(parent))
      sqlite3_bind_text(statement, 2, String(component), -1, transient)
      let status = sqlite3_step(statement)
      if status == SQLITE_DONE { throw POSIXError(.ENOENT) }
      guard status == SQLITE_ROW else { throw failure() }
      if let node, !node.folder { throw POSIXError(.ENOTDIR) }
      node = try decode(statement)
      parent = node!.id
    }
    return node
  }

  private func store(_ node: GardenNode) throws {
    let statement = try prepare(node.deleted ? "DELETE FROM nodes WHERE id=?" :
      "INSERT OR REPLACE INTO nodes(id,parent,name,payload) VALUES(?,?,?,?)")
    defer { sqlite3_finalize(statement) }
    sqlite3_bind_int64(statement, 1, Int64(node.id))
    if !node.deleted {
      sqlite3_bind_int64(statement, 2, Int64(node.parentID))
      sqlite3_bind_text(statement, 3, node.name, -1, transient)
      let payload = try JSONEncoder().encode(node)
      _ = payload.withUnsafeBytes { sqlite3_bind_blob(statement, 4, $0.baseAddress, Int32($0.count), transient) }
    }
    guard sqlite3_step(statement) == SQLITE_DONE else { throw failure() }
  }

  private func saveRevision(_ revision: Int) throws {
    let statement = try prepare("INSERT OR REPLACE INTO cursor(id,revision) VALUES(1,?)")
    defer { sqlite3_finalize(statement) }
    sqlite3_bind_int64(statement, 1, Int64(revision))
    guard sqlite3_step(statement) == SQLITE_DONE else { throw failure() }
  }

  private func query(_ sql: String, number: Int) throws -> [GardenNode] {
    let statement = try prepare(sql)
    defer { sqlite3_finalize(statement) }
    sqlite3_bind_int64(statement, 1, Int64(number))
    var result: [GardenNode] = []
    while true {
      let status = sqlite3_step(statement)
      if status == SQLITE_DONE { return result }
      guard status == SQLITE_ROW else { throw failure() }
      result.append(try decode(statement))
    }
  }

  private func decode(_ statement: OpaquePointer) throws -> GardenNode {
    let data = Data(bytes: sqlite3_column_blob(statement, 0), count: Int(sqlite3_column_bytes(statement, 0)))
    return try JSONDecoder().decode(GardenNode.self, from: data)
  }

  private func transaction(_ operation: () throws -> Void) throws {
    try execute("BEGIN IMMEDIATE")
    do { try operation(); try execute("COMMIT") }
    catch { try? execute("ROLLBACK"); throw error }
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
    NSError(domain: "GardenRemoteMetadata", code: Int(sqlite3_errcode(db)),
      userInfo: [NSLocalizedDescriptionKey: String(cString: sqlite3_errmsg(db))])
  }
}
