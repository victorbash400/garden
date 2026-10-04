import Foundation

final class RemoteChanges: @unchecked Sendable {
  private let session: URLSession
  private let socket: URLSessionWebSocketTask
  private let cid = UUID().uuidString.lowercased()

  private init(url: URL) {
    session = URLSession(configuration: .ephemeral)
    socket = session.webSocketTask(with: url)
  }

  static func connect(api: GardenAPI, revision: Int,
    receive: @escaping @Sendable (GardenChange) async throws -> Void) async throws -> RemoteChanges {
    let credential = try await api.streamCredential()
    guard var components = URLComponents(string: credential.serverURL),
      components.scheme == "https" || (components.scheme == "http" && components.host == "localhost")
      else { throw GardenAPIError.invalidResponse }
    components.scheme = components.scheme == "https" ? "wss" : "ws"
    components.path = "/v1/websocket"
    guard let url = components.url else { throw GardenAPIError.invalidResponse }
    let connection = RemoteChanges(url: url)
    do {
      try await withTaskCancellationHandler {
        try await connection.start(credential: credential, revision: revision, receive: receive)
      } onCancel: { connection.close() }
      return connection
    } catch { connection.close(); throw error }
  }

  private func start(credential: FinderCredential, revision: Int,
    receive: @escaping @Sendable (GardenChange) async throws -> Void) async throws {
    socket.resume()
    try await Self.send(["type": "ping"], to: socket)
    guard try await Self.message(socket)["type"] as? String == "pong" else { throw GardenAPIError.invalidResponse }
    let args = try JSONSerialization.data(withJSONObject: ["gardenId": credential.driveID, "afterRevision": revision])
    try await Self.send(["type": "omsc", "data": ["en": "files", "m": "watch", "cid": cid,
      "args": String(decoding: args, as: UTF8.self), "is": [], "auth": "Bearer \(credential.token)"]], to: socket)
    try await consume(untilReady: true, receive: receive)
  }

  func run(receive: @escaping @Sendable (GardenChange) async throws -> Void) async throws {
    defer { close() }
    try await consume(untilReady: false, receive: receive)
  }

  func close() {
    socket.cancel(with: .goingAway, reason: nil)
    session.invalidateAndCancel()
  }

  private func consume(untilReady: Bool,
    receive: @escaping @Sendable (GardenChange) async throws -> Void) async throws {
    try await withTaskCancellationHandler {
      while true {
        try Task.checkCancellation()
        let value = try await Self.message(socket)
        guard let type = value["type"] as? String else { throw GardenAPIError.invalidResponse }
        if type == "ping" { try await Self.send(["type": "pong"], to: socket); continue }
        if type == "pong" { continue }
        guard let data = value["data"] as? [String: Any], data["cid"] as? String == cid else {
          throw GardenAPIError.invalidResponse
        }
        switch type {
        case "omsr":
          guard let status = data["res"] as? String else { throw GardenAPIError.invalidResponse }
          if status == "authenticationFailed" { throw GardenAPIError.unauthorized }
          guard status == "success" else { throw GardenAPIError.http(403, "Drive change stream refused: \(status)") }
        case "msm":
          guard let object = data["o"] as? [String: Any],
            let event = object["data"] as? [String: Any], let revision = event["revision"] as? Int,
            let operation = event["operation"] as? String else { throw GardenAPIError.invalidResponse }
          if operation == "ready" {
            if untilReady { return }
            throw GardenAPIError.invalidResponse
          }
          try await receive(GardenChange(revision: revision, operation: operation,
            node: try (event["node"] as? [String: Any]).map(GardenNode.init),
            previousParentID: event["previousParentId"] as? Int))
        case "msse": throw GardenAPIError.http(403, "Drive change stream failed.")
        case "cmsc": throw GardenAPIError.http(503, "Drive change stream closed.")
        default: throw GardenAPIError.invalidResponse
        }
      }
    } onCancel: { self.close() }
  }

  private static func message(_ socket: URLSessionWebSocketTask) async throws -> [String: Any] {
    let data: Data
    switch try await socket.receive() {
    case .data(let bytes): data = bytes
    case .string(let string): data = Data(string.utf8)
    @unknown default: throw GardenAPIError.invalidResponse
    }
    guard let value = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw GardenAPIError.invalidResponse
    }
    return value
  }

  private static func send(_ value: [String: Any], to socket: URLSessionWebSocketTask) async throws {
    let data = try JSONSerialization.data(withJSONObject: value)
    try await socket.send(.string(String(decoding: data, as: UTF8.self)))
  }
}
