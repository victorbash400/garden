import Foundation

final class RemoteUnmountCommand: @unchecked Sendable {
  private let process = Process()
  private let lock = NSLock()
  private let completion = RemoteCompletion<Void>()
  private var exited = false
  private var deadline: DispatchWorkItem?
  private let path: String

  init(path: String, executable: URL = URL(fileURLWithPath: "/sbin/umount"), arguments: [String]? = nil) {
    self.path = path
    process.executableURL = executable
    process.arguments = arguments ?? [path]
  }

  func run(timeout: TimeInterval = 30, didExit: @escaping @Sendable (Result<Void, Error>) -> Void) async throws {
    process.terminationHandler = { [self] process in
      lock.withLock { exited = true; deadline?.cancel(); deadline = nil }
      let result: Result<Void, Error> = process.terminationReason == .exit && process.terminationStatus == 0
        ? .success(()) : .failure(error(Int(process.terminationStatus), "Garden could not disconnect this drive. Close its files and Finder windows in other apps, then try again. Pending changes are preserved."))
      didExit(result)
      completion.resolve(result)
      process.terminationHandler = nil
    }
    do { try process.run() }
    catch {
      process.terminationHandler = nil
      didExit(.failure(error))
      throw error
    }
    let deadline = DispatchWorkItem { [self] in
      let timedOut = lock.withLock { () -> Bool in
        guard !exited else { return false }
        completion.resolve(.failure(error(Int(ETIMEDOUT), "macOS timed out unmounting \(path). Pending writes remain preserved.")))
        return true
      }
      if timedOut && process.isRunning { process.terminate() }
    }
    let scheduled = lock.withLock { () -> Bool in
      guard !exited else { return false }
      self.deadline = deadline
      return true
    }
    if scheduled { DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + timeout, execute: deadline) }
    try await completion.wait()
  }

  private func error(_ code: Int, _ message: String) -> NSError {
    NSError(domain: "GardenRemoteUnmount", code: code, userInfo: [NSLocalizedDescriptionKey: message])
  }
}
