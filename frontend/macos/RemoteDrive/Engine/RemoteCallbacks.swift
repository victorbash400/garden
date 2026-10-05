import Darwin
import Foundation

func engine(_ context: UnsafeMutableRawPointer?) throws -> RemoteEngine {
  guard let context else { throw POSIXError(.EINVAL) }
  return Unmanaged<RemoteEngine>.fromOpaque(context).takeUnretainedValue()
}

func wait<T>(_ operation: @escaping () async throws -> T) throws -> T {
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

func status(_ operation: () throws -> Int32) -> Int32 {
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
    let node: GardenNode? = try wait { try await remoteEngine.attributeNode(name, handle: handle) }
    attributes.pointee = try fileStat(node)
    return 0
  }
}

func fileStat(_ node: GardenNode?) throws -> stat {
  var attributes = stat()
  attributes.st_ino = UInt64((node?.id ?? 0) + 2)
  attributes.st_mode = mode_t((node?.folder ?? true ? S_IFDIR : S_IFREG) |
    mode_t(node?.attributes?.permissions ?? (node?.folder ?? true ? 0o755 : 0o644)))
  attributes.st_flags = UInt32(node?.attributes?.flags ?? 0)
  attributes.st_nlink = 1
  attributes.st_uid = getuid()
  attributes.st_gid = getgid()
  attributes.st_size = off_t(node?.size ?? 0)
  attributes.st_blocks = 0
  attributes.st_blksize = 1024 * 1024
  attributes.st_mtimespec = fileTimespec(node?.modifiedDate ?? Date(timeIntervalSince1970: 0))
  attributes.st_ctimespec = attributes.st_mtimespec
  let accessed = try node?.attributes?.accessedAt.map(GardenFileAttributes.date) ?? node?.modifiedDate ?? Date(timeIntervalSince1970: 0)
  attributes.st_atimespec = fileTimespec(accessed)
  let birth = node?.createdDate ?? node?.modifiedDate ?? Date(timeIntervalSince1970: 0)
  attributes.st_birthtimespec = fileTimespec(birth)
  return attributes
}

private func fileTimespec(_ date: Date) -> timespec {
  let seconds = date.timeIntervalSince1970.rounded(.down)
  return timespec(tv_sec: Int(seconds),
    tv_nsec: min(999_999_999, max(0, Int((date.timeIntervalSince1970 - seconds) * 1_000_000_000))))
}

@_cdecl("garden_remote_set_birthtime")
func remoteSetBirthtime(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ handle: UInt64, _ seconds: Int64, _ nanos: Int64) -> Int32 {
  status {
    let remoteEngine = try engine(context)
    guard nanos >= 0, nanos < 1_000_000_000 else { throw POSIXError(.EINVAL) }
    let date = Date(timeIntervalSince1970: Double(seconds) + Double(nanos) / 1_000_000_000)
    let name = path.map { String(cString: $0) }
    try wait { try await remoteEngine.setBirthtime(name, handle: handle, date: date) }
    return 0
  }
}

@_cdecl("garden_remote_mutate")
func remoteMutate(_ context: UnsafeMutableRawPointer?, _ operation: Int32, _ path: UnsafePointer<CChar>?,
  _ destination: UnsafePointer<CChar>?, _ noReplace: Int32) -> Int32 {
  status {
    let remoteEngine = try engine(context)
    guard let path else { throw POSIXError(.EINVAL) }
    let kind: RemoteMutation.Operation
    switch operation {
    case 0: kind = .createFolder
    case 1: kind = .rename
    case 2: kind = .unlink
    case 3: kind = .rmdir
    default: throw POSIXError(.EINVAL)
    }
    let mutation = try RemoteMutation(operation: kind, path: String(cString: path),
      destination: destination.map { String(cString: $0) }, noReplace: noReplace != 0)
    try wait { try await remoteEngine.mutate(mutation) }
    return 0
  }
}

@_cdecl("garden_remote_open")
func remoteOpen(_ context: UnsafeMutableRawPointer?, _ path: UnsafePointer<CChar>?, _ directory: Int32, _ writing: Int32, _ handle: UnsafeMutablePointer<UInt64>?) -> Int32 {
  status {
    let remoteEngine = try engine(context)
    guard let path, let handle else { throw POSIXError(.EINVAL) }
    let name = String(cString: path)
    handle.pointee = try wait {
      if writing != 0 { try await remoteEngine.requireWrite() }
      return try await remoteEngine.open(name, directory: directory != 0)
    }
    return 0
  }
}

@_cdecl("garden_remote_close")
func remoteClose(_ context: UnsafeMutableRawPointer?, _ handle: UInt64) -> Int32 {
  status {
    let remoteEngine = try engine(context)
    try wait { try await remoteEngine.close(handle) }
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
      let full: Int32
      if let node {
        var attributes = try fileStat(node)
        full = name.withCString { name in
          withUnsafePointer(to: &attributes) { callback(directory, name, $0, Int64(position + 1)) }
        }
      } else {
        full = name.withCString { callback(directory, $0, nil, Int64(position + 1)) }
      }
      if full != 0 { break }
    }
    return 0
  }
}
