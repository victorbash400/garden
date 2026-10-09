import AppKit
import Foundation
import ServiceManagement

enum GardenRemoteBridge {
  @MainActor static func unregisterService() async throws {
    try await SMAppService.agent(plistName: GardenRemoteService.plist).unregister()
  }

  @MainActor static func prepareUpdate() async throws {
    let service = SMAppService.agent(plistName: GardenRemoteService.plist)
    guard service.status == .enabled else { return }
    _ = try await request("prepareUpdate", GardenRemoteRequest(accountID: ""))
    try await service.unregister()
    try registerService()
  }

  @MainActor static func registerService() throws {
    let service = SMAppService.agent(plistName: GardenRemoteService.plist)
    if service.status == .notRegistered || service.status == .notFound { try service.register() }
    if service.status == .requiresApproval {
      throw NSError(domain: "GardenRemote", code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Enable Garden background activity in Login Items & Extensions to mount drives."])
    }
    guard service.status == .enabled else {
      throw NSError(domain: "GardenRemote", code: 4,
        userInfo: [NSLocalizedDescriptionKey: "Garden's background mount service is not registered."])
    }
  }

  static func connection() -> NSXPCConnection {
    let connection = NSXPCConnection(machServiceName: GardenRemoteService.name)
    connection.setCodeSigningRequirement(GardenRemoteService.serverRequirement)
    connection.remoteObjectInterface = NSXPCInterface(with: GardenRemoteControlProtocol.self)
    return connection
  }

  static func request(_ method: String, _ request: GardenRemoteRequest) async throws -> Any {
    let connection = connection()
    let payload = try JSONEncoder().encode(request)
    let completion = RemoteCompletion<Data>()
    connection.invalidationHandler = { completion.resolve(.failure(CocoaError(.xpcConnectionInvalid))) }
    connection.interruptionHandler = { completion.resolve(.failure(CocoaError(.xpcConnectionInterrupted))) }
    connection.resume()
    defer { connection.invalidate() }
    guard let service = connection.remoteObjectProxyWithErrorHandler({ error in
      completion.resolve(.failure(error))
    }) as? GardenRemoteControlProtocol else { throw GardenAPIError.invalidResponse }
    service.request(method, payload: payload) { data, message in
      if let message {
        let detail = data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Int] }
        completion.resolve(.failure(NSError(domain: "GardenRemote", code: detail?["code"] ?? 3,
          userInfo: [NSLocalizedDescriptionKey: message])))
      } else if let data { completion.resolve(.success(data)) }
      else { completion.resolve(.failure(GardenAPIError.invalidResponse)) }
    }
    let deadline = Task {
      do { try await Task.sleep(for: .seconds(45)) }
      catch { return }
      completion.resolve(.failure(URLError(.timedOut)))
      connection.invalidate()
    }
    defer { deadline.cancel() }
    let data = try await withTaskCancellationHandler { try await completion.wait() }
      onCancel: { completion.resolve(.failure(CancellationError())); connection.invalidate() }
    return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
  }

  static func open(_ request: GardenRemoteRequest) async throws -> String {
    guard let path = try await Self.request("location", request) as? String else { throw GardenAPIError.invalidResponse }
    return try await openPath(path, directory: request.nodeID == nil)
  }

  static func openPath(_ path: String, directory: Bool = false, application: URL? = nil) async throws -> String {
    guard path.hasPrefix("/Volumes/Garden-") else { throw GardenAPIError.invalidResponse }
    let completion = RemoteCompletion<String>()
    let deadline = Task {
      do { try await Task.sleep(for: .seconds(60)) }
      catch { return }
      completion.resolve(.failure(URLError(.timedOut)))
    }
    defer { deadline.cancel() }
    DispatchQueue.main.async {
      let url = URL(fileURLWithPath: path, isDirectory: directory)
      let finished: (NSRunningApplication?, Error?) -> Void = { application, error in
        if let error { completion.resolve(.failure(error)) }
        else if let identifier = application?.bundleIdentifier { completion.resolve(.success(identifier)) }
        else { completion.resolve(.failure(POSIXError(.EIO))) }
      }
      if let application {
        NSWorkspace.shared.open([url], withApplicationAt: application,
          configuration: NSWorkspace.OpenConfiguration(), completionHandler: finished)
      } else {
        NSWorkspace.shared.open(url, configuration: NSWorkspace.OpenConfiguration(), completionHandler: finished)
      }
    }
    return try await withTaskCancellationHandler { try await completion.wait() }
      onCancel: { completion.resolve(.failure(CancellationError())) }
  }
}
