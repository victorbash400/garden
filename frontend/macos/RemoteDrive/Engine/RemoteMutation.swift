import Foundation

struct RemoteMutation: Codable, Equatable {
  enum Operation: String, Codable { case createFile, createFolder, rename, unlink, rmdir, setAttributes, setExtendedAttribute, removeExtendedAttribute }
  let operationId: UUID
  let operation: Operation
  let path: String
  let destination: String?
  let noReplace: Bool
  let createdAt: String?
  let modifiedAt: String?
  let attributes: GardenFileAttributes?
  let attributeName: String?
  let attributeValue: String?
  let attributeFlags: Int?

  init(operation: Operation, path: String, destination: String? = nil, noReplace: Bool = false, createdAt: Date? = nil,
    modifiedAt: Date? = nil, attributes: GardenFileAttributes? = nil, attributeName: String? = nil,
    attributeValue: String? = nil, attributeFlags: Int = 0) throws {
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
    self.modifiedAt = modifiedAt.map(formatter.string(from:))
    self.attributes = attributes
    self.attributeName = attributeName
    self.attributeValue = attributeValue
    self.attributeFlags = attributeFlags
  }

  var arguments: [String: Any] {
    var value: [String: Any] = ["__className__": "FilesystemRequest", "operationId": operationId.uuidString.lowercased(),
      "operation": operation.rawValue, "path": path, "noReplace": noReplace]
    if let destination { value["destination"] = destination }
    if let createdAt { value["createdAt"] = createdAt }
    if let modifiedAt { value["modifiedAt"] = modifiedAt }
    if let attributes { value["attributes"] = attributes.arguments }
    if let attributeName { value["attributeName"] = attributeName }
    if let attributeValue { value["attributeValue"] = attributeValue }
    value["attributeFlags"] = attributeFlags ?? 0
    return value
  }
}
