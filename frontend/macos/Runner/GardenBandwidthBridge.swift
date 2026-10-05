import FlutterMacOS
import Foundation

// The helper owns the budget, so app imports and mounted reads share the same limits.
enum GardenBandwidthBridge {
  static func install(on messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "garden/bandwidth", binaryMessenger: messenger).setMethodCallHandler { call, result in
      Task { @MainActor in
        do { result(try await request(call.method, arguments: call.arguments as? [String: Any] ?? [:])) }
        catch { result(FlutterError(code: "bandwidth_error", message: error.localizedDescription, details: nil)) }
      }
    }
  }

  private static func request(_ method: String, arguments: [String: Any]) async throws -> [String: Any] {
    let connection = try await GardenCacheBridge.connect()
    defer { connection.invalidate() }
    return try await withCheckedThrowingContinuation { continuation in
      let reply = GardenCacheReply(continuation)
      connection.remoteObjectInterface = NSXPCInterface(with: GardenRemoteControlProtocol.self)
      connection.invalidationHandler = { reply.finish(error: CocoaError(.xpcConnectionInvalid)) }
      connection.interruptionHandler = { reply.finish(error: CocoaError(.xpcConnectionInterrupted)) }
      connection.resume()
      guard let proxy = connection.remoteObjectProxyWithErrorHandler({ reply.finish(error: $0) }) as? GardenRemoteControlProtocol else {
        reply.finish(error: GardenAPIError.invalidResponse); return
      }
      func finish(_ value: [String: Any], _ message: String?) {
        if let message { reply.finish(error: NSError(domain: "GardenBandwidth", code: 1,
          userInfo: [NSLocalizedDescriptionKey: message])) }
        else { reply.finish(value) }
      }
      switch method {
      case "status": proxy.bandwidthStatus { value, error in
        guard let value = value as? [String: Any] else { finish([:], error ?? "Bandwidth settings are unavailable."); return }
        finish(value, error)
      }
      case "set":
        guard let upload = arguments["upload"] as? Int64, let download = arguments["download"] as? Int64 else {
          reply.finish(error: POSIXError(.EINVAL)); return
        }
        proxy.setBandwidth(upload, download: download) { finish([:], $0) }
      case "reserve":
        guard let bytes = arguments["bytes"] as? Int64, let upload = arguments["upload"] as? Bool else {
          reply.finish(error: POSIXError(.EINVAL)); return
        }
        proxy.reserveBandwidth(bytes, upload: upload) { seconds, error in finish(["seconds": seconds], error) }
      default: reply.finish(error: POSIXError(.ENOSYS))
      }
      DispatchQueue.global().asyncAfter(deadline: .now() + 15) { reply.finish(error: URLError(.timedOut)) }
    }
  }
}
