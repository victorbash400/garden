import Foundation

extension RemoteEngine {
  func attributeNode(_ name: String, handle: UInt64 = 0) throws -> GardenNode {
    try lookup(name, handle: handle) ?? metadata.volumeNode()
  }

  func setAttributes(_ name: String?, handle: UInt64, created: Date?, modified: Date?, attributes: GardenFileAttributes?) async throws {
    try requireWrite()
    guard name != nil || handle != 0 else { throw POSIXError(.EINVAL) }
    try attributes?.validate()
    var node = try attributeNode(name ?? "/", handle: handle)
    let original = node.attributes ?? GardenFileAttributes()
    let sameCreated = created == nil || GardenFileAttributes.string(created!) == GardenFileAttributes.string(node.createdDate ?? node.modifiedDate)
    let sameModified = modified == nil || GardenFileAttributes.string(modified!) == GardenFileAttributes.string(node.modifiedDate)
    let sameAccess = attributes?.accessedAt == nil || attributes?.accessedAt == (original.accessedAt ?? GardenFileAttributes.string(node.modifiedDate))
    let samePermissions = attributes?.permissions == nil || attributes?.permissions == (original.permissions ?? (node.folder ? 0o755 : 0o644))
    let sameFlags = attributes?.flags == nil || attributes?.flags == (original.flags ?? 0)
    if sameCreated && sameModified && sameAccess && samePermissions && sameFlags { return }
    let currentPath = "/" + (try path(node.id == 0 ? nil : node.id))
    if node.id == 0 {
      if let created { node.createdDate = created }
      if let modified { node.modifiedDate = modified; node.modified = GardenFileAttributes.string(modified) }
      if let attributes {
        var stored = node.attributes ?? GardenFileAttributes()
        stored.accessedAt = attributes.accessedAt ?? stored.accessedAt
        stored.permissions = attributes.permissions ?? stored.permissions
        stored.flags = attributes.flags ?? stored.flags
        node.attributes = stored
      }
      try metadata.saveVolumeNode(node)
      return
    }
    var cloudModified = modified
    if let modified {
      if let pending = publications[node.id] { try await pending.value }
      if try writes.state(node.id)?.sealed == true { try await publish(node.id) }
      if try writes.state(node.id) != nil {
        try writes.setModified(node.id, date: modified)
        schedulePublication(node.id)
        cloudModified = nil
      }
    }
    if created != nil || cloudModified != nil || attributes != nil {
      try await mutate(RemoteMutation(operation: .setAttributes, path: currentPath, createdAt: created,
        modifiedAt: cloudModified, attributes: attributes))
    }
  }

  func extendedAttributes(_ name: String) throws -> GardenFileAttributes {
    try attributeNode(name).attributes ?? GardenFileAttributes()
  }

  func setExtendedAttribute(_ name: String, key: String, bytes: Data?, options: Int) async throws {
    try requireWrite()
    let node = try attributeNode(name)
    let original = node.attributes ?? GardenFileAttributes()
    let updated = try original.setting(key, bytes: bytes, options: options)
    if updated == original { return }
    if node.id == 0 {
      var root = node
      root.attributes = updated
      try metadata.saveVolumeNode(root)
      return
    }
    try await mutate(RemoteMutation(operation: bytes == nil ? .removeExtendedAttribute : .setExtendedAttribute,
      path: "/" + (try path(node.id)), attributeName: key, attributeValue: bytes?.base64EncodedString(), attributeFlags: options))
  }
}
