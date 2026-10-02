import Foundation

enum GardenAPIError: LocalizedError {
  case invalidResponse
  case unauthorized
  case http(Int, String)
  case cleanup(String)

  var errorDescription: String? {
    switch self {
    case .invalidResponse: "Garden returned an invalid response."
    case .unauthorized: "Sign in to Garden to reconnect this drive."
    case .http(let status, let message): "Garden request failed (\(status)): \(message)"
    case .cleanup(let message): message
    }
  }
}

struct GardenChange {
  let revision: Int
  let operation: String
  let node: GardenNode?
  let previousParentID: Int?
}

actor GardenAPI {
  private let domainID: String
  private var refreshTask: Task<FinderCredential, Error>?
  private var cachedCredential: FinderCredential?

  init(domainID: String) {
    self.domainID = domainID
  }

  func list(parentID: Int, after nodeID: Int) async throws -> [GardenNode] {
    guard let records = try await call("files", "listPage", [
      "gardenId": try credential().driveID,
      "parentId": parentID,
      "afterNodeId": nodeID,
    ]) as? [[String: Any]] else {
      throw GardenAPIError.invalidResponse
    }
    return try records.map(GardenNode.init)
  }

  func revision() async throws -> Int {
    guard let value = try await call("files", "revision", [
      "gardenId": try credential().driveID,
    ]) as? Int else {
      throw GardenAPIError.invalidResponse
    }
    return value
  }

  func get(_ id: Int) async throws -> GardenNode {
    try GardenNode(object(await call("files", "get", ["nodeId": id])))
  }

  func changes(after revision: Int) async throws -> [GardenChange] {
    guard let records = try await call("files", "changes", [
      "gardenId": try credential().driveID,
      "afterRevision": revision,
    ]) as? [[String: Any]] else {
      throw GardenAPIError.invalidResponse
    }
    return try records.map { record in
      guard let revision = record["revision"] as? Int,
            let operation = record["operation"] as? String else {
        throw GardenAPIError.invalidResponse
      }
      let node = try (record["node"] as? [String: Any]).map(GardenNode.init)
      return GardenChange(
        revision: revision, operation: operation, node: node,
        previousParentID: record["previousParentId"] as? Int
      )
    }
  }

  func snapshot(after nodeID: Int) async throws -> [GardenNode] {
    guard let records = try await call("files", "snapshot", [
      "gardenId": try credential().driveID,
      "afterNodeId": nodeID,
    ]) as? [[String: Any]] else {
      throw GardenAPIError.invalidResponse
    }
    return try records.map(GardenNode.init)
  }

  func create(parentID: Int, name: String, folder: Bool) async throws -> GardenNode {
    try GardenNode(object(await call("files", "create", [
      "gardenId": try credential().driveID,
      "parentId": parentID,
      "name": name,
      "kind": folder ? "folder" : "file",
    ])))
  }

  func move(id: Int, parentID: Int, name: String) async throws -> GardenNode {
    try GardenNode(object(await call("files", "move", [
      "nodeId": id,
      "parentId": parentID,
      "name": name,
    ])))
  }

  func delete(_ id: Int) async throws {
    _ = try await call("files", "delete", ["nodeId": id])
  }

  func read(id: Int, version: Int, offset: Int, length: Int) async throws -> Data {
    guard let encoded = try await call("content", "read", [
      "nodeId": id,
      "versionId": version,
      "offset": offset,
      "length": length,
    ]) as? String,
    encoded.hasPrefix("decode('"), encoded.hasSuffix("', 'base64')") else {
      throw GardenAPIError.invalidResponse
    }
    let start = encoded.index(encoded.startIndex, offsetBy: 8)
    let end = encoded.index(encoded.endIndex, offsetBy: -12)
    guard let bytes = Data(base64Encoded: String(encoded[start..<end])) else {
      throw GardenAPIError.invalidResponse
    }
    return bytes
  }

  func upload(id: Int, baseVersion: Int, fileURL: URL) async throws -> GardenNode {
    let values = try fileURL.resourceValues(forKeys: [.fileSizeKey])
    guard let size = values.fileSize else { throw GardenAPIError.invalidResponse }
    let version = try object(await call("content", "begin", [
      "nodeId": id,
      "baseVersion": baseVersion,
      "size": size,
    ]))
    guard let versionID = version["id"] as? Int else {
      throw GardenAPIError.invalidResponse
    }
    let chunkSize = 256 * 1024
    let handle = try FileHandle(forReadingFrom: fileURL)
    defer { try? handle.close() }
    for index in 0..<((size + chunkSize - 1) / chunkSize) {
      let expected = min(chunkSize, size - index * chunkSize)
      var data = Data()
      while data.count < expected {
        guard let part = try handle.read(upToCount: expected - data.count), !part.isEmpty else {
          throw GardenAPIError.invalidResponse
        }
        data.append(part)
      }
      let encoded = data.base64EncodedString()
      _ = try await call("content", "writeChunk", [
        "versionId": versionID,
        "index": index,
        "data": "decode('\(encoded)', 'base64')",
      ])
    }
    return try GardenNode(object(await call("content", "finish", [
      "versionId": versionID,
    ])))
  }

  private func credential() throws -> FinderCredential {
    if let cachedCredential { return cachedCredential }
    let value = try FinderCredentialStore.read(domainID)
    cachedCredential = value
    return value
  }

  private func object(_ value: Any) throws -> [String: Any] {
    guard let object = value as? [String: Any] else {
      throw GardenAPIError.invalidResponse
    }
    return object
  }

  private func call(_ endpoint: String, _ method: String, _ arguments: [String: Any]) async throws -> Any {
    let current = try credential()
    do {
      return try await send(endpoint, method, arguments, token: current.token)
    } catch GardenAPIError.unauthorized {
      let refreshed = try await refresh(staleToken: current.token)
      return try await send(endpoint, method, arguments, token: refreshed.token)
    }
  }

  private func refresh(staleToken: String) async throws -> FinderCredential {
    let latest = try FinderCredentialStore.read(domainID)
    if latest.token != staleToken {
      cachedCredential = latest
      return latest
    }
    if let refreshTask { return try await refreshTask.value }
    let task = Task<FinderCredential, Error> {
      let value = try await send(
        "jwtRefresh", "refreshAccessToken",
        ["refreshToken": latest.refreshToken], token: nil
      )
      guard let result = value as? [String: Any],
            let token = result["token"] as? String,
            let refreshToken = result["refreshToken"] as? String else {
        throw GardenAPIError.invalidResponse
      }
      var updated = latest
      updated.token = token
      updated.refreshToken = refreshToken
      try FinderCredentialStore.save(updated, domainID: domainID)
      return updated
    }
    refreshTask = task
    defer { refreshTask = nil }
    let updated = try await task.value
    cachedCredential = updated
    return updated
  }

  private func send(
    _ endpoint: String,
    _ method: String,
    _ arguments: [String: Any],
    token: String?
  ) async throws -> Any {
    let credential = try credential()
    guard let serverURL = URL(string: credential.serverURL),
          serverURL.scheme == "https" || serverURL.host == "localhost" else {
      throw GardenAPIError.invalidResponse
    }
    let url = serverURL.appendingPathComponent(endpoint).appendingPathComponent(method)
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 30
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
    request.httpBody = try JSONSerialization.data(withJSONObject: arguments)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let response = response as? HTTPURLResponse else {
      throw GardenAPIError.invalidResponse
    }
    if response.statusCode == 401 { throw GardenAPIError.unauthorized }
    guard response.statusCode == 200 else {
      let value = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
      let message = value?["message"] as? String
        ?? HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
      throw GardenAPIError.http(response.statusCode, message)
    }
    if data.isEmpty { return NSNull() }
    return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
  }
}
