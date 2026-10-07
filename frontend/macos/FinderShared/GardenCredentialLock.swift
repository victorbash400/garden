import Foundation
import CryptoKit
import Darwin

final class GardenCredentialLock {
  private let descriptor: Int32

  private init(descriptor: Int32) { self.descriptor = descriptor }

  deinit { close(descriptor) }

  static func acquire(domainID: String) async throws -> GardenCredentialLock {
    let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("GardenRemote/credential-locks", isDirectory: true)
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true,
      attributes: [.posixPermissions: 0o700])
    let name = SHA256.hash(data: Data(domainID.utf8)).map { String(format: "%02x", $0) }.joined()
    let path = root.appendingPathComponent(name).path
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global(qos: .utility).async {
        let descriptor = open(path, O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW, 0o600)
        guard descriptor >= 0 else {
          continuation.resume(throwing: POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO))
          return
        }
        guard flock(descriptor, LOCK_EX) == 0 else {
          let error = POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
          close(descriptor)
          continuation.resume(throwing: error)
          return
        }
        continuation.resume(returning: GardenCredentialLock(descriptor: descriptor))
      }
    }
  }

  func release() { _ = flock(descriptor, LOCK_UN) }
}
