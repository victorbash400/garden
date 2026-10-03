import FileProvider
import FlutterMacOS
import Foundation

final class GardenCacheReply: @unchecked Sendable {
  private let lock = NSLock()
  private var continuation: CheckedContinuation<[String: Any], Error>?

  init(_ continuation: CheckedContinuation<[String: Any], Error>) { self.continuation = continuation }

  func finish(_ value: [String: Any]? = nil, error: Error? = nil) {
    lock.lock()
    let current = continuation
    continuation = nil
    lock.unlock()
    guard let current else { return }
    if let error { current.resume(throwing: error) }
    else if let value { current.resume(returning: value) }
    else { current.resume(throwing: GardenAPIError.invalidResponse) }
  }
}

enum GardenCacheBridge {
  static func install(on messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "garden/cache", binaryMessenger: messenger).setMethodCallHandler { call, result in
      Task { @MainActor in
        do {
          switch call.method {
          case "initialize":
            let legacy = (call.arguments as? Int).map { Int64($0) * 1024 * 1024 * 1024 } ?? GardenCachePolicy.defaultLimit
            let limit = try GardenCachePolicy.read(defaultLimit: legacy)
            try GardenCachePolicy.save(limit)
            result(Int(limit / (1024 * 1024 * 1024)))
          case "status", "setLimit", "clear":
            let limit = (call.arguments as? Int).map { Int64($0) * 1024 * 1024 * 1024 }
            if call.method == "setLimit" {
              guard let limit else { throw FinderBridgeError.invalidArguments }
              try GardenCachePolicy.validate(limit)
            }
            result(try await request(call.method, limit: limit))
          default: result(FlutterMethodNotImplemented)
          }
        } catch {
          result(FlutterError(code: "cache_error", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  private static func request(_ method: String, limit: Int64?) async throws -> [String: Any] {
    let domains = try await NSFileProviderManager.domains()
    guard let domain = domains.first(where: { $0.userEnabled && !$0.isDisconnected }),
          let manager = NSFileProviderManager(for: domain) else {
      if let limit { try GardenCachePolicy.save(limit) }
      return ["limitBytes": try GardenCachePolicy.read(), "available": false]
    }
    let url: URL = try await withCheckedThrowingContinuation { continuation in
      manager.getUserVisibleURL(for: .rootContainer) { url, error in
        if let error { continuation.resume(throwing: error) }
        else if let url { continuation.resume(returning: url) }
        else { continuation.resume(throwing: FinderBridgeError.domainMissing) }
      }
    }
    let scoped = url.startAccessingSecurityScopedResource()
    defer { if scoped { url.stopAccessingSecurityScopedResource() } }
    let service: NSFileProviderService = try await withCheckedThrowingContinuation { continuation in
      FileManager.default.getFileProviderServicesForItem(at: url) { services, error in
        if let error { continuation.resume(throwing: error) }
        else if let service = services?[GardenCacheServiceName.value] { continuation.resume(returning: service) }
        else {
          continuation.resume(throwing: NSError(domain: "GardenCache", code: 3,
            userInfo: [NSLocalizedDescriptionKey: "Finder cache service is unavailable. Relaunch Garden with the updated extension."]))
        }
      }
    }
    let connection: NSXPCConnection = try await withCheckedThrowingContinuation { continuation in
      service.getFileProviderConnection { connection, error in
        if let error { continuation.resume(throwing: error) }
        else if let connection { continuation.resume(returning: connection) }
        else { continuation.resume(throwing: GardenAPIError.invalidResponse) }
      }
    }
    defer { connection.invalidate() }
    return try await withCheckedThrowingContinuation { continuation in
      let reply = GardenCacheReply(continuation)
      connection.remoteObjectInterface = NSXPCInterface(with: GardenCacheServiceProtocol.self)
      connection.invalidationHandler = { reply.finish(error: CocoaError(.xpcConnectionInvalid)) }
      connection.interruptionHandler = { reply.finish(error: CocoaError(.xpcConnectionInterrupted)) }
      connection.resume()
      guard let proxy = connection.remoteObjectProxyWithErrorHandler({ reply.finish(error: $0) }) as? GardenCacheServiceProtocol else {
        reply.finish(error: GardenAPIError.invalidResponse)
        return
      }
      let completion: (NSDictionary?, String?) -> Void = { value, message in
        if let message {
          reply.finish(error: NSError(domain: "GardenCache", code: 4,
            userInfo: [NSLocalizedDescriptionKey: message]))
        } else if var value = value as? [String: Any] {
          value["available"] = true
          reply.finish(value)
        } else { reply.finish(error: GardenAPIError.invalidResponse) }
      }
      switch method {
      case "setLimit": proxy.setCacheLimit(limit!, reply: completion)
      case "clear": proxy.clearCache(reply: completion)
      default: proxy.cacheStatus(reply: completion)
      }
      DispatchQueue.global().asyncAfter(deadline: .now() + 15) {
        reply.finish(error: NSError(domain: "GardenCache", code: 5,
          userInfo: [NSLocalizedDescriptionKey: "Finder cache service did not respond."]))
      }
    }
  }
}
