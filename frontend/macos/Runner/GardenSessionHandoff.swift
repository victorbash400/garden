import Foundation
import Darwin

// A one-use, user-private memory object. Session tokens never enter a file or launch argument.
enum GardenSessionHandoff {
  static let argument = "--garden-relaunch"
  private static let maximumBytes = 1_048_576

  static func create(_ sessions: [String: Any]) throws -> String {
    let data = try JSONSerialization.data(withJSONObject: [
      "created": Date().timeIntervalSince1970, "sessions": sessions,
    ])
    guard data.count <= maximumBytes else { throw CocoaError(.fileWriteOutOfSpace) }
    let name = "/garden-" + UUID().uuidString.prefix(20)
    let fd = garden_memory_open(name, O_CREAT | O_EXCL | O_RDWR, S_IRUSR | S_IWUSR)
    guard fd >= 0 else { throw posixError() }
    defer { close(fd) }
    let size = data.count + MemoryLayout<UInt64>.size
    guard ftruncate(fd, off_t(size)) == 0 else { shm_unlink(name); throw posixError() }
    let memory = mmap(nil, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)
    guard memory != MAP_FAILED, let memory else { shm_unlink(name); throw posixError() }
    defer { munmap(memory, size) }
    memory.storeBytes(of: UInt64(data.count), as: UInt64.self)
    data.copyBytes(to: memory.advanced(by: 8).assumingMemoryBound(to: UInt8.self), count: data.count)
    return name
  }

  static func consume(arguments: [String]) throws -> [String: Any] {
    guard let index = arguments.firstIndex(of: argument) else { return [:] }
    guard index + 1 < arguments.count else { throw CocoaError(.fileReadCorruptFile) }
    return try consume(name: arguments[index + 1])
  }

  static func consume(name: String) throws -> [String: Any] {
    guard name.hasPrefix("/garden-"), name.count == 28,
          !name.dropFirst().contains("/") else { throw CocoaError(.fileReadCorruptFile) }
    let fd = garden_memory_open(name, O_RDONLY, 0)
    guard fd >= 0 else { throw posixError() }
    defer { close(fd); shm_unlink(name) }
    var info = stat()
    guard fstat(fd, &info) == 0, info.st_uid == getuid(),
          info.st_mode & 0o077 == 0, info.st_size >= 8,
          info.st_size <= maximumBytes + Int(getpagesize()) else { throw CocoaError(.fileReadCorruptFile) }
    let size = Int(info.st_size)
    let memory = mmap(nil, size, PROT_READ, MAP_SHARED, fd, 0)
    guard memory != MAP_FAILED, let memory else { throw posixError() }
    defer { munmap(memory, size) }
    let length = memory.load(as: UInt64.self)
    guard length > 0, length <= maximumBytes, length <= size - 8 else { throw CocoaError(.fileReadCorruptFile) }
    let data = Data(bytes: memory.advanced(by: 8), count: Int(length))
    guard let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any],
          let created = payload["created"] as? Double,
          (0...60).contains(Date().timeIntervalSince1970 - created),
          let sessions = payload["sessions"] as? [String: Any] else { throw CocoaError(.fileReadCorruptFile) }
    return sessions
  }

  static func remove(_ name: String) { shm_unlink(name) }

  private static func posixError() -> NSError {
    NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
  }
}
