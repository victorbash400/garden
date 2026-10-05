import FlutterMacOS
import Foundation

final class GardenActivityBridge: NSObject, FlutterStreamHandler, GardenActivityObserverProtocol {
  private var sink: FlutterEventSink?
  private var connection: NSXPCConnection?
  private var generation = UUID()

  static func install(on messenger: FlutterBinaryMessenger) {
    let bridge = GardenActivityBridge()
    FlutterEventChannel(name: "garden/activity/updates", binaryMessenger: messenger).setStreamHandler(bridge)
    FlutterMethodChannel(name: "garden/activity", binaryMessenger: messenger).setMethodCallHandler { call, result in
      guard call.method == "clear", let account = call.arguments as? String else { result(FlutterMethodNotImplemented); return }
      guard let service = bridge.connection?.remoteObjectProxyWithErrorHandler({ error in
        DispatchQueue.main.async { result(FlutterError(code: "activity", message: error.localizedDescription, details: nil)) }
      }) as? GardenRemoteControlProtocol else {
        result(FlutterError(code: "activity", message: "Activity is disconnected.", details: nil)); return
      }
      service.clearActivity(account) { DispatchQueue.main.async { result(nil) } }
    }
  }
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    guard let account = arguments as? String else { return FlutterError(code: "activity", message: "Missing account.", details: nil) }
    sink = events
    let session = UUID(); generation = session
    Task { @MainActor in
      do {
        let connected = try await GardenCacheBridge.connect()
        guard self.generation == session else { connected.invalidate(); return }
        self.connection = connected
        connected.exportedInterface = NSXPCInterface(with: GardenActivityObserverProtocol.self)
        connected.exportedObject = self
        connected.remoteObjectInterface = NSXPCInterface(with: GardenRemoteControlProtocol.self)
        connected.invalidationHandler = { self.fail("Activity connection closed.", session) }
        connected.interruptionHandler = { self.fail("Activity connection interrupted.", session) }
        connected.resume()
        guard let service = connected.remoteObjectProxyWithErrorHandler({ self.fail($0.localizedDescription, session) }) as? GardenRemoteControlProtocol else { throw GardenAPIError.invalidResponse }
        service.subscribeActivity(account) { if let error = $0 { self.fail(error, session) } }
      } catch { self.fail(error.localizedDescription, session) }
    }
    return nil
  }
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    generation = UUID(); sink = nil; connection?.invalidate(); connection = nil; return nil
  }
  func activityFailed(_ message: String) { fail(message, generation) }
  func activityChanged(_ data: Data) {
    let session = generation
    DispatchQueue.main.async {
      guard self.generation == session else { return }
      self.sink?(FlutterStandardTypedData(bytes: data))
    }
  }
  private func fail(_ message: String, _ session: UUID) {
    DispatchQueue.main.async {
      guard self.generation == session else { return }
      self.sink?(FlutterError(code: "activity", message: message, details: nil))
    }
  }
}
