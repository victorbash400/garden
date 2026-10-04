import Foundation

private func attributeDate(_ seconds: Int64, _ nanos: Int64) throws -> Date {
  guard seconds >= 0, seconds <= 253402300799, nanos >= 0, nanos < 1_000_000_000 else { throw POSIXError(.EINVAL) }
  return Date(timeIntervalSince1970: Double(seconds) + Double(nanos) / 1_000_000_000)
}

@_cdecl("garden_remote_set_attributes")
func remoteSetAttributes(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ handle: UInt64,
  _ value: UnsafePointer<garden_file_attributes>?) -> Int32 {
  status {
    let remote = try engine(context)
    guard let value else { throw POSIXError(.EINVAL) }
    let item = value.pointee
    let fields = Int32(item.fields)
    let created = fields & GARDEN_ATTRIBUTE_CREATED != 0 ? try attributeDate(item.created_seconds, item.created_nanos) : nil
    let modified = fields & GARDEN_ATTRIBUTE_MODIFIED != 0 ? try attributeDate(item.modified_seconds, item.modified_nanos) : nil
    let access = fields & GARDEN_ATTRIBUTE_ACCESSED != 0 ? try attributeDate(item.accessed_seconds, item.accessed_nanos) : nil
    let attributes = GardenFileAttributes(accessedAt: access.map(GardenFileAttributes.string),
      permissions: fields & GARDEN_ATTRIBUTE_PERMISSIONS != 0 ? Int(item.permissions) : nil,
      flags: fields & GARDEN_ATTRIBUTE_FLAGS != 0 ? Int(item.flags) : nil)
    let hasAttributes = fields & (GARDEN_ATTRIBUTE_ACCESSED | GARDEN_ATTRIBUTE_PERMISSIONS | GARDEN_ATTRIBUTE_FLAGS) != 0
    let name = path.map { String(cString: $0) }
    try wait { try await remote.setAttributes(name, handle: handle, created: created, modified: modified,
      attributes: hasAttributes ? attributes : nil) }
    return 0
  }
}
