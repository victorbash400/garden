import FlutterMacOS
import Foundation

final class GardenFinderEvents: NSObject, FlutterStreamHandler {
  private var connection: NSXPCConnection?
  private var sink: FlutterEventSink?
  private var generation = UUID()

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    do {
      guard let values = arguments as? [String: Any], let account = values["accountID"] as? String,
        let ids = values["driveIDs"] as? [Int] else { throw FinderBridgeError.invalidArguments }
      let payload = try JSONEncoder().encode(GardenRemoteRequest(accountID: account, driveIDs: ids))
      sink = events
      let session = UUID()
      generation = session
      let connection = GardenRemoteBridge.connection()
      self.connection = connection
      connection.exportedObject = GardenFinderObserver { [weak self] value in
        DispatchQueue.main.async {
          guard let self, self.generation == session else { return }
          self.sink?(value)
        }
      }
      connection.exportedInterface = NSXPCInterface(with: GardenRemoteObserverProtocol.self)
      connection.invalidationHandler = { [weak self] in self?.fail("Drive status connection closed.", session: session) }
      connection.interruptionHandler = { [weak self] in self?.fail("Drive status connection interrupted.", session: session) }
      connection.resume()
      guard let service = connection.remoteObjectProxyWithErrorHandler({ [weak self] in self?.fail($0.localizedDescription, session: session) })
        as? GardenRemoteControlProtocol else { throw GardenAPIError.invalidResponse }
      service.subscribeDrives(payload) { [weak self] message in if let message { self?.fail(message, session: session) } }
      return nil
    } catch { return FlutterError(code: "finder_stream_error", message: error.localizedDescription, details: nil) }
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    generation = UUID()
    sink = nil
    connection?.invalidationHandler = nil
    connection?.interruptionHandler = nil
    connection?.invalidate()
    connection = nil
    return nil
  }

  private func fail(_ message: String, session: UUID) {
    DispatchQueue.main.async { [weak self] in
      guard let self, generation == session else { return }
      sink?(FlutterError(code: "finder_stream_error", message: message, details: nil))
    }
  }
}

private final class GardenFinderObserver: NSObject, GardenRemoteObserverProtocol {
  private let receive: (Any) -> Void
  init(receive: @escaping (Any) -> Void) { self.receive = receive }
  func drivesChanged(_ value: NSDictionary) { receive(value) }
  func drivesFailed(_ message: String) {
    receive(FlutterError(code: "finder_stream_error", message: message, details: nil))
  }
  func cacheChanged(_ value: NSDictionary) { drivesFailed("Unexpected cache event on drive status connection.") }
  func cacheFailed(_ message: String) { drivesFailed(message) }
}
