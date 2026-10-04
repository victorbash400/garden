import Foundation

struct RemoteMutation: Codable, Equatable {
  enum Operation: String, Codable { case createFolder, rename, unlink, rmdir, setAttributes }
  let operationId: UUID
  let operation: Operation
  let path: String
  let destination: String?
  let noReplace: Bool
  let createdAt: String?

  init(operation: Operation, path: String, destination: String? = nil, noReplace: Bool = false, createdAt: Date? = nil) throws {
    guard path.utf8.count <= 1024, destination.map({ $0.utf8.count <= 1024 }) ?? true else {
      throw POSIXError(.ENAMETOOLONG)
    }
    operationId = UUID()
    self.operation = operation
    self.path = path
    self.destination = destination
    self.noReplace = noReplace
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    self.createdAt = createdAt.map(formatter.string(from:))
  }

  var arguments: [String: Any] {
    var value: [String: Any] = ["__className__": "FilesystemRequest", "operationId": operationId.uuidString.lowercased(),
      "operation": operation.rawValue, "path": path, "noReplace": noReplace]
    if let destination { value["destination"] = destination }
    if let createdAt { value["createdAt"] = createdAt }
    return value
  }
}
