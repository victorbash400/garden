import Darwin
import Foundation

@_cdecl("garden_remote_create")
func remoteCreate(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ permissions: UInt32,
  _ folder: Int32, _ handle: UnsafeMutablePointer<UInt64>?) -> Int32 {
  status {
    let remote = try engine(context)
    guard let path, permissions <= 0o777, folder == 0 || folder == 1,
      folder == 1 || handle != nil else { throw POSIXError(.EINVAL) }
    let name = String(cString: path)
    try wait {
      try await remote.mutate(RemoteMutation(operation: folder == 1 ? .createFolder : .createFile,
        path: name, attributes: GardenFileAttributes(permissions: Int(permissions))))
      if let handle { handle.pointee = try await remote.open(name, directory: false) }
    }
    return 0
  }
}

@_cdecl("garden_remote_write")
func remoteWrite(_ context: UnsafeMutableRawPointer?, _ handle: UInt64, _ buffer: UnsafeRawPointer?, _ offset: Int64, _ length: Int64, _ append: Int32) -> Int32 {
  status {
    let remote = try engine(context)
    guard let buffer, offset >= 0, length >= 0, length <= 16 * 1024 * 1024 else { throw POSIXError(.EINVAL) }
    let bytes = Data(bytes: buffer, count: Int(length))
    try wait { try await remote.write(handle, offset: Int(offset), bytes: bytes, append: append != 0) }
    return Int32(length)
  }
}

@_cdecl("garden_remote_truncate")
func remoteTruncate(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ handle: UInt64, _ size: Int64) -> Int32 {
  status {
    let remote = try engine(context)
    guard size >= 0 else { throw POSIXError(.EINVAL) }
    let name = path.map { String(cString: $0) } ?? "/"
    try wait { try await remote.truncate(name, handle: handle, size: Int(size)) }
    return 0
  }
}

@_cdecl("garden_remote_flush")
func remoteFlush(_ context: UnsafeMutableRawPointer?, _ handle: UInt64) -> Int32 {
  status {
    let remote = try engine(context)
    try wait { try await remote.flush(handle) }
    return 0
  }
}
