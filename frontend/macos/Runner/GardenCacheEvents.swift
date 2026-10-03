import FlutterMacOS
import Foundation

final class GardenCacheEvents: NSObject, FlutterStreamHandler, GardenCacheObserverProtocol {
  private var sink: FlutterEventSink?
  private var connection: NSXPCConnection?
  private var generation = UUID()

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    let session = UUID()
    generation = session
    Task { @MainActor [self] in
      do {
        let connected = try await GardenCacheBridge.connect()
        guard generation == session else { connected?.invalidate(); return }
        guard let connected else {
          events(["limitBytes": try GardenCachePolicy.read(), "available": false])
          return
        }
        connection = connected
        connected.exportedInterface = NSXPCInterface(with: GardenCacheObserverProtocol.self)
        connected.exportedObject = self
        connected.remoteObjectInterface = NSXPCInterface(with: GardenCacheServiceProtocol.self)
        connected.invalidationHandler = { [weak self] in self?.fail("Cache usage connection closed.", session: session) }
        connected.interruptionHandler = { [weak self] in self?.fail("Cache usage connection interrupted.", session: session) }
        connected.resume()
        guard let service = connected.remoteObjectProxyWithErrorHandler({ [weak self] error in
          self?.fail(error.localizedDescription, session: session)
        }) as? GardenCacheServiceProtocol else { throw GardenAPIError.invalidResponse }
        service.subscribeCache { [weak self] message in
          if let message { self?.fail(message, session: session) }
        }
      } catch { fail(error.localizedDescription, session: session) }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    generation = UUID()
    sink = nil
    connection?.invalidate()
    connection = nil
    return nil
  }

  func cacheChanged(_ value: NSDictionary) {
    DispatchQueue.main.async { [weak self] in
      guard var value = value as? [String: Any] else { return }
      value["available"] = true
      self?.sink?(value)
    }
  }

  func cacheFailed(_ message: String) {
    DispatchQueue.main.async { [weak self] in
      self?.sink?(FlutterError(code: "cache_stream_error", message: message, details: nil))
    }
  }

  private func fail(_ message: String, session: UUID) {
    DispatchQueue.main.async { [weak self] in
      guard let self, generation == session else { return }
      sink?(FlutterError(code: "cache_stream_error", message: message, details: nil))
    }
  }
}
