import AppKit
import Foundation

final class RemoteMount: @unchecked Sendable {
  let engine: RemoteEngine
  private let handle: UnsafeMutableRawPointer
  private let ready = RemoteCompletion<Void>()
  private let finished = RemoteCompletion<Int32>()
  private var observer: NSObjectProtocol?

  private init(engine: RemoteEngine, path: String, name: String) throws {
    self.engine = engine
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
      throw error
    }
  }

  private func begin(path: String) {
    observer = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didMountNotification, object: nil, queue: nil
    ) { [weak self] notice in
      guard let url = notice.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL, url.path == path else { return }
      self?.ready.resolve(.success(()))
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let result = garden_remote_run(self.handle)
      self.finished.resolve(.success(result))
      self.ready.resolve(.failure(POSIXError(.ENODEV)))
    }
  }

  func run() async throws {
    let result = try await finished.wait()
    if result != 0 { throw POSIXError(.EIO) }
  }

  func stop() { garden_remote_stop(handle) }
  deinit {
    if let observer { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
    garden_remote_destroy(handle)
  }
}
