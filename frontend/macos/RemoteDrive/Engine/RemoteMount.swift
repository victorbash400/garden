import AppKit
import Foundation

final class RemoteMount: @unchecked Sendable {
  let engine: RemoteEngine
  private let path: String
  private let stopLock = NSLock()
  private var stopRequested = false
  private let handle: UnsafeMutableRawPointer
  private let ready = RemoteCompletion<Void>()
  private let finished = RemoteCompletion<Int32>()
  private let stopped = RemoteCompletion<Void>()
  private let unmounted = RemoteCompletion<Void>()
  private var observers: [NSObjectProtocol] = []

  private init(engine: RemoteEngine, path: String, name: String) throws {
    self.engine = engine
    self.path = path
    guard let handle = path.withCString({ path in
      name.withCString { name in garden_remote_start(Unmanaged.passUnretained(engine).toOpaque(), path, name) }
    }) else { throw POSIXError(.EIO) }
    self.handle = handle
  }

  static func start(engine: RemoteEngine, path: String, name: String) async throws -> RemoteMount {
    let mount: RemoteMount = try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.global(qos: .userInitiated).async {
        do { continuation.resume(returning: try RemoteMount(engine: engine, path: path, name: name)) }
        catch { continuation.resume(throwing: error) }
      }
    }
    mount.begin(path: path)
    let deadline = Task {
      do { try await Task.sleep(for: .seconds(30)) }
      catch { return }
      mount.ready.resolve(.failure(URLError(.timedOut)))
      mount.stop()
    }
    defer { deadline.cancel() }
    do {
      try await withTaskCancellationHandler {
        try await mount.ready.wait()
      } onCancel: {
        mount.ready.resolve(.failure(CancellationError()))
        mount.stop()
      }
      return mount
    } catch {
      mount.stop()
      _ = try? await mount.finished.wait()
      _ = try? await mount.stopped.wait()
      throw error
    }
  }

  private func begin(path: String) {
    observers.append(NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didMountNotification, object: nil, queue: nil
    ) { [weak self] notice in
      guard let url = notice.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL, url.path == path else { return }
      self?.ready.resolve(.success(()))
    })
    observers.append(NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didUnmountNotification, object: nil, queue: nil
    ) { [weak self] notice in
      guard let url = notice.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL, url.path == path else { return }
      self?.unmounted.resolve(.success(()))
    })
    DispatchQueue.global(qos: .userInitiated).async {
      let result = garden_remote_run(self.handle)
      self.finished.resolve(.success(result))
      self.ready.resolve(.failure(POSIXError(.ENODEV)))
    }
  }

  func run() async throws {
    let result = try await finished.wait()
    let requested = stopLock.withLock { stopRequested }
    if !requested {
      garden_remote_stop(handle)
      stopped.resolve(.success(()))
    }
    try await stopped.wait()
    let deadline = Task {
      do { try await Task.sleep(for: .seconds(30)) }
      catch { return }
      self.unmounted.resolve(.failure(URLError(.timedOut)))
    }
    defer { deadline.cancel() }
    try await unmounted.wait()
    if result != 0 { throw POSIXError(.EIO) }
  }

  func stop() {
    let shouldStop = stopLock.withLock {
      guard !stopRequested else { return false }
      stopRequested = true
      return true
    }
    guard shouldStop else { return }
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/sbin/umount")
        process.arguments = [self.path]
        try process.run()
        process.waitUntilExit()
        guard process.terminationReason == .exit, process.terminationStatus == 0 else {
          throw NSError(domain: "GardenRemoteUnmount", code: Int(process.terminationStatus),
            userInfo: [NSLocalizedDescriptionKey: "macOS could not unmount \(self.path)."])
        }
        garden_remote_stop(self.handle)
        self.stopped.resolve(.success(()))
      } catch {
        self.stopped.resolve(.failure(error))
        self.finished.resolve(.failure(error))
      }
    }
  }
  deinit {
    for observer in observers { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
    garden_remote_destroy(handle)
  }
}
