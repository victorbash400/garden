import Darwin
import Foundation

private func engine(_ context: UnsafeMutableRawPointer?) throws -> RemoteEngine {
  guard let context else { throw POSIXError(.EINVAL) }
  return Unmanaged<RemoteEngine>.fromOpaque(context).takeUnretainedValue()
}

private func wait<T>(_ operation: @escaping () async throws -> T) throws -> T {
  let semaphore = DispatchSemaphore(value: 0)
  var result: Result<T, Error>!
  Task.detached {
    defer { semaphore.signal() }
    do { result = .success(try await operation()) }
    catch { result = .failure(error) }
  }
  semaphore.wait()
  return try result.get()
}

private func status(_ operation: () throws -> Int32) -> Int32 {
  do { return try operation() }
  catch let error as POSIXError { return -error.code.rawValue }
  catch GardenAPIError.unauthorized { RemoteLog.error(GardenAPIError.unauthorized); return -EACCES }
  catch { RemoteLog.error(error); return -EIO }
}

@_cdecl("garden_remote_attributes")
func remoteAttributes(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ handle: UInt64, _ attributes: UnsafeMutablePointer<stat>?) -> Int32 {
  status {
    let remoteEngine = try engine(context)
    guard let attributes else { throw POSIXError(.EINVAL) }
    let name = path.map { String(cString: $0) } ?? "/"
    let node = try wait { try await remoteEngine.lookup(name, handle: handle) }
    attributes.pointee = stat()
    attributes.pointee.st_ino = UInt64((node?.id ?? 0) + 2)
    attributes.pointee.st_mode = mode_t(node?.folder ?? true ? S_IFDIR | 0o555 : S_IFREG | 0o444)
    attributes.pointee.st_nlink = 1
    attributes.pointee.st_uid = getuid()
    attributes.pointee.st_gid = getgid()
    attributes.pointee.st_size = off_t(node?.size ?? 0)
    attributes.pointee.st_blocks = 0
    attributes.pointee.st_blksize = 1024 * 1024
    attributes.pointee.st_mtimespec.tv_sec = Int(node?.modifiedDate.timeIntervalSince1970 ?? 0)
    attributes.pointee.st_ctimespec = attributes.pointee.st_mtimespec
    attributes.pointee.st_birthtimespec = attributes.pointee.st_mtimespec
    return 0
  }
}

@_cdecl("garden_remote_open")
func remoteOpen(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ directory: Int32, _ handle: UnsafeMutablePointer<UInt64>?) -> Int32 {
  status {
    let remoteEngine = try engine(context)
    guard let path, let handle else { throw POSIXError(.EINVAL) }
    let name = String(cString: path)
    handle.pointee = try wait { try await remoteEngine.open(name, directory: directory != 0) }
    return 0
  }
}

@_cdecl("garden_remote_close")
func remoteClose(_ context: UnsafeMutableRawPointer?, _ handle: UInt64) -> Int32 {
  status {
    let remoteEngine = try engine(context)
    try wait { await remoteEngine.close(handle) }
    return 0
  }
}

@_cdecl("garden_remote_read")
func remoteRead(_ context: UnsafeMutableRawPointer?, _ handle: UInt64, _ buffer: UnsafeMutableRawPointer?, _ offset: Int64, _ length: Int64) -> Int32 {
  status {
    let remoteEngine = try engine(context)
    guard let buffer, offset >= 0, length >= 0, length <= 16 * 1024 * 1024 else { throw POSIXError(.EINVAL) }
    let data = try wait { try await remoteEngine.read(handle, offset: Int(offset), length: Int(length)) }
    data.copyBytes(to: buffer.assumingMemoryBound(to: UInt8.self), count: data.count)
    return Int32(data.count)
  }
}

@_cdecl("garden_remote_list")
func remoteList(_ context: UnsafeMutableRawPointer?, _ handle: UInt64, _ offset: Int64, _ directory: UnsafeMutableRawPointer?, _ callback: garden_entry_callback?) -> Int32 {
  status {
    let remoteEngine = try engine(context)
    guard let callback, offset >= 0 else { throw POSIXError(.EINVAL) }
    let nodes = try wait { try await remoteEngine.list(handle) }
    guard offset <= nodes.count + 2 else { throw POSIXError(.EINVAL) }
    for position in Int(offset)..<(nodes.count + 2) {
      let node = position < 2 ? nil : nodes[position - 2]
      let name = position == 0 ? "." : position == 1 ? ".." : node!.name
      let full = name.withCString { callback(directory, $0, UInt64((node?.id ?? 0) + 2), node?.folder ?? true ? 1 : 0,
        Int64(node?.size ?? 0), Int64(node?.modifiedDate.timeIntervalSince1970 ?? 0), Int64(position + 1)) }
      if full != 0 { break }
    }
    return 0
  }
}
