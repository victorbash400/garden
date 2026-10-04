import FileProvider
import Foundation
import UniformTypeIdentifiers

struct GardenNode: Codable, Sendable {
  let id: Int
  let parentID: Int
  let name: String
  let folder: Bool
  var size: Int
  let version: Int
  var modified: String
  var modifiedDate: Date
  let deleted: Bool
  var createdDate: Date?
  var attributes: GardenFileAttributes?

  init(_ value: [String: Any]) throws {
    guard let id = value["id"] as? Int,
          let parentID = value["parentId"] as? Int,
          let name = value["name"] as? String,
          let kind = value["kind"] as? String,
          let size = value["size"] as? Int,
          let version = value["version"] as? Int,
          let modified = value["updatedAt"] as? String,
          let deleted = value["deleted"] as? Bool,
          kind == "folder" || kind == "file" else {
      throw GardenAPIError.invalidResponse
    }
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let dateWithFraction = formatter.date(from: modified)
    formatter.formatOptions = [.withInternetDateTime]
    guard let modifiedDate = dateWithFraction ?? formatter.date(from: modified) else {
      throw GardenAPIError.invalidResponse
    }
    self.id = id
    self.parentID = parentID
    self.name = name
    self.folder = kind == "folder"
    self.size = size
    self.version = version
    self.modified = modified
    self.modifiedDate = modifiedDate
    self.deleted = deleted
    if let value = value["createdAt"], !(value is NSNull) {
      guard let created = value as? String else { throw GardenAPIError.invalidResponse }
      formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
      guard let date = formatter.date(from: created) else { throw GardenAPIError.invalidResponse }
      createdDate = date
    } else {
      createdDate = nil
    }
    if let value = value["attributes"], !(value is NSNull) {
      attributes = try JSONDecoder().decode(GardenFileAttributes.self, from: JSONSerialization.data(withJSONObject: value))
      try attributes?.validate()
    } else { attributes = nil }
  }
}

final class GardenItem: NSObject, NSFileProviderItem {
  let itemIdentifier: NSFileProviderItemIdentifier
  let parentItemIdentifier: NSFileProviderItemIdentifier
  let filename: String
  let contentType: UTType
  let documentSize: NSNumber?
  let itemVersion: NSFileProviderItemVersion
  let contentModificationDate: Date?
  let capabilities: NSFileProviderItemCapabilities

  init(node: GardenNode) {
    itemIdentifier = NSFileProviderItemIdentifier(String(node.id))
    parentItemIdentifier = node.parentID == 0
      ? .rootContainer : NSFileProviderItemIdentifier(String(node.parentID))
    filename = node.name
    contentType = node.folder ? .folder : (UTType(filenameExtension: (node.name as NSString).pathExtension) ?? .data)
    documentSize = node.folder ? nil : NSNumber(value: node.size)
    itemVersion = NSFileProviderItemVersion(
      contentVersion: Data(String(node.version).utf8),
      metadataVersion: Data(node.modified.utf8)
    )
    contentModificationDate = node.modifiedDate
    capabilities = node.folder
      ? [
          .allowsReading, .allowsAddingSubItems, .allowsRenaming,
          .allowsReparenting, .allowsTrashing, .allowsDeleting,
        ]
      : [
          .allowsReading, .allowsWriting, .allowsRenaming,
          .allowsReparenting, .allowsTrashing, .allowsDeleting,
        ]
    super.init()
  }

  init(driveName: String) {
    itemIdentifier = .rootContainer
    parentItemIdentifier = .rootContainer
    filename = driveName
    contentType = .folder
    documentSize = nil
    itemVersion = NSFileProviderItemVersion(
      contentVersion: Data("root".utf8),
      metadataVersion: Data("root".utf8)
    )
    contentModificationDate = nil
    capabilities = [.allowsReading, .allowsAddingSubItems]
    super.init()
  }
}
