import AppKit
import Foundation

final class RemoteMount: @unchecked Sendable {
  let engine: RemoteEngine
  private let path: String
  private let stopLock = NSLock()
  private let invalidations = DispatchQueue(label: "garden.remote.invalidation", qos: .utility)
  private var stopRequested = false
  private let handle: UnsafeMutableRawPointer
  private let ready = RemoteCompletion<Void>()
  private let finished = RemoteCompletion<Int32>()
  private var stopped = RemoteCompletion<Void>()
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
      await engine.setInvalidation({ [weak mount] paths in mount?.invalidate(paths) },
        settled: { [weak mount] in await mount?.flushInvalidations() })
      return mount
    } catch {
      do {
        try await mount.requestStop().wait()
        _ = try await mount.finished.wait()
      } catch { RemoteLog.error(error) }
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
    let (requested, completion) = stopLock.withLock { () -> (Bool, RemoteCompletion<Void>) in
      if !stopRequested { stopped = RemoteCompletion<Void>() }
      return (stopRequested, stopped)
    }
    if !requested {
      garden_remote_stop(handle)
      completion.resolve(.success(()))
    }
    try await completion.wait()
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
    _ = requestStop()
  }

  func unmount() async throws {
    try await engine.flushAll()
    await flushInvalidations()
    try await requestStop().wait()
    try await run()
  }

  private func requestStop() -> RemoteCompletion<Void> {
    let attempt = stopLock.withLock { () -> RemoteCompletion<Void>? in
      guard !stopRequested else { return nil }
      stopRequested = true
      stopped = RemoteCompletion<Void>()
      return stopped
    }
    guard let attempt else { return stopLock.withLock { stopped } }
    Task {
      do {
        try await RemoteUnmountCommand(path: path).run { result in
          // A timeout keeps the attempt reserved until the process actually exits.
          switch result {
          case .success: garden_remote_stop(self.handle)
          case .failure: self.stopLock.withLock { self.stopRequested = false }
          }
        }
        attempt.resolve(.success(()))
      } catch {
        attempt.resolve(.failure(error))
        RemoteLog.error(error)
      }
    }
    return attempt
  }

  private func invalidate(_ paths: [String]) {
    // Invalidation must run outside the filesystem callback that changed the path.
    invalidations.async {
      self.stopLock.withLock {
        guard !self.stopRequested else { return }
        for path in paths {
          let result = path.withCString { garden_remote_invalidate(self.handle, $0) }
          if result != 0 && result != -ENOENT { RemoteLog.error(POSIXError(POSIXErrorCode(rawValue: -result) ?? .EIO)) }
          // macFUSE 5.4 keeps a separate cached EOF after acknowledging invalidation. Reapply the already
          // committed size so FSKit updates it. The callback rejects any change to the authoritative size.
          var attributes = stat()
          let found = path.withCString { garden_remote_attributes(Unmanaged.passUnretained(self.engine).toOpaque(), $0, 0, &attributes) }
          if found == -ENOENT { continue }
          if found != 0 { RemoteLog.error(POSIXError(POSIXErrorCode(rawValue: -found) ?? .EIO)); continue }
          let refreshed = attributes.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            ? truncate(self.path + path, attributes.st_size) : chflags(self.path + path, 0)
          if refreshed != 0 && errno != ENOENT { RemoteLog.error(POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)) }
        }
      }
    }
  }

  private func flushInvalidations() async {
    await withCheckedContinuation { continuation in invalidations.async { continuation.resume() } }
  }
  deinit {
    for observer in observers { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
    garden_remote_destroy(handle)
  }
}
