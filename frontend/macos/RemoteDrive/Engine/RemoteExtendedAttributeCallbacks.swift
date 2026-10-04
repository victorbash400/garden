import Foundation

private func copyAttribute(_ data: Data, buffer: UnsafeMutableRawPointer?, length: Int64) throws -> Int32 {
  guard length >= 0 else { throw POSIXError(.EINVAL) }
  if length == 0 { return Int32(data.count) }
  guard let buffer, length >= data.count else { throw POSIXError(.ERANGE) }
  data.copyBytes(to: buffer.assumingMemoryBound(to: UInt8.self), count: data.count)
  return Int32(data.count)
}

@_cdecl("garden_remote_get_attribute")
func remoteGetAttribute(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ key: UnsafePointer<CChar>?,
  _ buffer: UnsafeMutableRawPointer?, _ length: Int64, _ position: UInt32) -> Int32 {
  status {
    let remote = try engine(context)
    guard let path, let key else { throw POSIXError(.EINVAL) }
    let name = String(cString: path), attribute = String(cString: key)
    guard position == 0 || attribute == "com.apple.ResourceFork" else { throw POSIXError(.EINVAL) }
    let value = try wait { try await remote.extendedAttributes(name).value(attribute) }
    return try copyAttribute(Data(value.dropFirst(min(value.count, Int(position)))), buffer: buffer, length: length)
  }
}

@_cdecl("garden_remote_set_attribute")
func remoteSetAttribute(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ key: UnsafePointer<CChar>?,
  _ buffer: UnsafeRawPointer?, _ length: Int64, _ options: Int32) -> Int32 {
  status {
    let remote = try engine(context)
    guard let path, let key, length >= 0 else { throw POSIXError(.EINVAL) }
    guard length <= GardenFileAttributes.maximumBytes else { throw POSIXError(.E2BIG) }
    guard length == 0 || buffer != nil else { throw POSIXError(.EINVAL) }
    let value = length == 0 ? Data() : Data(bytes: buffer!, count: Int(length))
    let name = String(cString: path), attribute = String(cString: key)
    try wait { try await remote.setExtendedAttribute(name, key: attribute, bytes: value, options: Int(options)) }
    return 0
  }
}

@_cdecl("garden_remote_list_attributes")
func remoteListAttributes(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ buffer: UnsafeMutableRawPointer?, _ length: Int64) -> Int32 {
  status {
    let remote = try engine(context)
    guard let path else { throw POSIXError(.EINVAL) }
    let name = String(cString: path)
    let values = try wait { try await remote.extendedAttributes(name).extended ?? [:] }
    let data = Data(values.keys.sorted().flatMap { Array($0.utf8) + [0] })
    return try copyAttribute(data, buffer: buffer, length: length)
  }
}

@_cdecl("garden_remote_remove_attribute")
func remoteRemoveAttribute(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ key: UnsafePointer<CChar>?) -> Int32 {
  status {
    let remote = try engine(context)
    guard let path, let key else { throw POSIXError(.EINVAL) }
    let name = String(cString: path), attribute = String(cString: key)
    try wait { try await remote.setExtendedAttribute(name, key: attribute, bytes: nil, options: 0) }
    return 0
  }
}
