import Foundation

final class RefreshProtocol: URLProtocol {
  static let mutex = NSLock()
  static var refreshes = 0
  static var expiredRequests = 0
  static var waitingRefresh: RefreshProtocol?

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    Self.mutex.lock()
    let refresh = request.url!.lastPathComponent == "refreshAccessToken"
    if refresh { Self.refreshes += 1 }
    let count = Self.refreshes
    let authorized = request.value(forHTTPHeaderField: "Authorization") == "Bearer renewed-token"
    if !refresh && !authorized { Self.expiredRequests += 1 }
    if refresh && count == 1 && Self.expiredRequests < 24 {
      Self.waitingRefresh = self
      Self.mutex.unlock()
      return
    }
    let waiting = Self.expiredRequests >= 24 ? Self.waitingRefresh : nil
    if waiting != nil { Self.waitingRefresh = nil }
    Self.mutex.unlock()
    waiting?.respond(status: 200, refresh: true)
    let status = refresh ? (count == 1 ? 200 : 401) : (authorized ? 200 : 401)
    respond(status: status, refresh: refresh)
  }

  private func respond(status: Int, refresh: Bool) {
    let body = refresh ? Data("{\"token\":\"renewed-token\",\"refreshToken\":\"renewed-refresh\"}".utf8) : Data("7".utf8)
    let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
    client!.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client!.urlProtocol(self, didLoad: body)
    client!.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

@main struct CredentialRefreshTests {
  static func main() async throws {
    if CommandLine.arguments.count == 4 {
      for _ in 0..<20 {
        let lock = try await GardenCredentialLock.acquire(domainID: CommandLine.arguments[2])
        defer { lock.release() }
        let url = URL(fileURLWithPath: CommandLine.arguments[3])
        let value = Int(try String(contentsOf: url, encoding: .utf8))!
        try String(value + 1).write(to: url, atomically: true, encoding: .utf8)
      }
      return
    }
    let domain = "garden-refresh-test-\(UUID())"
    let credential = FinderCredential(serverURL: "https://unused.invalid", accountID: UUID().uuidString,
      driveID: 1, tokenID: UUID().uuidString, token: "expired-token", refreshToken: "original-refresh")
    try FinderCredentialStore.save(credential, domainID: domain)
    defer { try? FinderCredentialStore.remove(domain) }
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [RefreshProtocol.self]
    let session = URLSession(configuration: configuration)
    defer { session.invalidateAndCancel() }
    let readers = (0..<24).map { _ in GardenAPI(domainID: domain, session: session) }
    for reader in readers { _ = try await reader.streamCredential() }
    try await withThrowingTaskGroup(of: Void.self) { group in
      for reader in readers {
        group.addTask {
          guard try await reader.revision() == 7 else { throw POSIXError(.EIO) }
        }
      }
      try await group.waitForAll()
    }
    guard RefreshProtocol.refreshes == 1,
      try FinderCredentialStore.read(domain).refreshToken == "renewed-refresh" else { throw POSIXError(.EIO) }

    try FinderCredentialStore.save(credential, domainID: domain)
    let rejected = GardenAPI(domainID: domain, session: session)
    do {
      _ = try await rejected.revision()
      throw POSIXError(.EIO)
    } catch GardenAPIError.unauthorized {}
    guard RefreshProtocol.refreshes == 2,
      try FinderCredentialStore.read(domain).refreshToken == credential.refreshToken else { throw POSIXError(.EIO) }

    let counter = FileManager.default.temporaryDirectory.appendingPathComponent("garden-refresh-lock-\(UUID())")
    try "0".write(to: counter, atomically: true, encoding: .utf8)
    defer { try? FileManager.default.removeItem(at: counter) }
    let workers = try (0..<4).map { _ -> Process in
      let process = Process()
      process.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
      process.arguments = ["--lock-worker", domain, counter.path]
      try process.run()
      return process
    }
    for worker in workers {
      await Task.detached { worker.waitUntilExit() }.value
      guard worker.terminationStatus == 0 else { throw POSIXError(.EIO) }
    }
    guard try String(contentsOf: counter, encoding: .utf8) == "80" else { throw POSIXError(.EIO) }
    print("Credential refresh: 24 independent readers used one rotation; rejected refresh stayed visible and preserved credentials; four processes serialized 80 critical sections without polling")
  }
}
