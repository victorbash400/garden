import Foundation

final class RemoteCompletion<Value: Sendable>: @unchecked Sendable {
  private let lock = NSLock()
  private var result: Result<Value, Error>?
  private var waiters: [CheckedContinuation<Value, Error>] = []

  func wait() async throws -> Value {
    try await withCheckedThrowingContinuation { continuation in
      lock.lock()
      if let result {
        lock.unlock()
        continuation.resume(with: result)
      } else {
        waiters.append(continuation)
        lock.unlock()
      }
    }
  }

  func resolve(_ value: Result<Value, Error>) {
    lock.lock()
    guard result == nil else { lock.unlock(); return }
    result = value
    let current = waiters
    waiters.removeAll()
    lock.unlock()
    for continuation in current { continuation.resume(with: value) }
  }
}
