import Darwin
import Foundation

final class RefreshProtocol: URLProtocol {
  static let lock = NSLock()
  static var pending: RefreshProtocol?
  static var started: CheckedContinuation<Void, Never>?
  static var hold = false
  static var role: String? = "Viewer"

  override class func canInit(with request: URLRequest) -> Bool { request.url?.host == "garden-refresh.test" }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    let delayed = Self.lock.withLock { () -> Bool in
      if Self.hold {
        Self.pending = self
        Self.started?.resume()
        Self.started = nil
        return true
      }
      return false
    }
    if !delayed { finish() }
  }
  func finish() {
    let value = Self.lock.withLock { Self.role }
    do {
      let bytes = try JSONSerialization.data(withJSONObject: value as Any? ?? NSNull(), options: [.fragmentsAllowed])
      let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: bytes)
      client?.urlProtocolDidFinishLoading(self)
    } catch { client?.urlProtocol(self, didFailWithError: error) }
  }
  override func stopLoading() { }
}

@main struct PermissionRefreshTests {
  static func main() async throws {
    URLProtocol.registerClass(RefreshProtocol.self)
    let account = UUID().uuidString.lowercased()
    let domain = "account-\(account)-drive-1"
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-refresh-\(UUID())")
    try FinderCredentialStore.save(FinderCredential(serverURL: "https://garden-refresh.test/", accountID: account,
      driveID: 1, tokenID: domain, token: "fixture", refreshToken: "fixture"), domainID: domain)
    defer { try? FinderCredentialStore.remove(domain); try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: domain, state: root, cache: root.appendingPathComponent("cache"), limit: 0)
    guard try await !engine.checkWithdrawal() else { throw POSIXError(.EIO) }
    var refresh: Task<Bool, Error>!
    await withCheckedContinuation { continuation in
      RefreshProtocol.lock.withLock { RefreshProtocol.hold = true; RefreshProtocol.started = continuation }
      refresh = Task { try await engine.checkWithdrawal() }
    }
    try await engine.requireRead()
    do { try await engine.requireWrite(); throw POSIXError(.EIO) }
    catch let error as POSIXError { guard error.code == .EROFS else { throw error } }
    RefreshProtocol.lock.withLock { RefreshProtocol.pending }!.finish()
    guard try await !refresh.value else { throw POSIXError(.EIO) }
    RefreshProtocol.lock.withLock { RefreshProtocol.hold = false; RefreshProtocol.role = nil }
    guard try await engine.checkWithdrawal() else { throw POSIXError(.EIO) }
    do { try await engine.requireRead(); throw POSIXError(.EIO) }
    catch let error as POSIXError { guard error.code == .EACCES else { throw error } }
    await engine.stop()
    print("Permission refresh: reads retain verified access during a pending check; Viewer writes and confirmed removal remain denied")
  }
}
