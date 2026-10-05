import Darwin
import Foundation

final class PermissionProtocol: URLProtocol {
  private static let lock = NSLock()
  private static var value: String? = "Viewer"
  static func role(_ role: String?) { lock.withLock { value = role } }
  override class func canInit(with request: URLRequest) -> Bool { request.url?.host == "garden-permission.test" }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    guard let url = request.url, url.path == "/driveMembers/accessRole" else {
      client?.urlProtocol(self, didFailWithError: POSIXError(.EINVAL)); return
    }
    let bytes: Data
    do {
      bytes = try Self.lock.withLock {
        try JSONSerialization.data(withJSONObject: Self.value as Any? ?? NSNull(), options: [.fragmentsAllowed])
      }
    } catch { client?.urlProtocol(self, didFailWithError: error); return }
    guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"]) else {
      client?.urlProtocol(self, didFailWithError: POSIXError(.EINVAL)); return
    }
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: bytes)
    client?.urlProtocolDidFinishLoading(self)
  }
  override func stopLoading() { }
}

@main struct PermissionTests {
  static func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw NSError(domain: "GardenPermissionTest", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }
  static func main() async throws {
    URLProtocol.registerClass(PermissionProtocol.self)
    let account = UUID().uuidString.lowercased()
    let domain = "account-\(account)-drive-1"
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-permissions-\(UUID())")
    try FinderCredentialStore.save(FinderCredential(serverURL: "https://garden-permission.test/", accountID: account,
      driveID: 1, tokenID: domain, token: "fixture", refreshToken: "fixture"), domainID: domain)
    defer { try? FinderCredentialStore.remove(domain); try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: domain, state: root, cache: root.appendingPathComponent("cache"), limit: 0)
    let node = try GardenNode(["id": 1, "parentId": 0, "name": "Empty.txt", "kind": "file", "size": 0,
      "version": 0, "updatedAt": "2026-10-05T10:00:00.000Z", "deleted": false])
    try await engine.metadata.reset(nodes: [node], revision: 0)
    try require(try await !engine.checkWithdrawal(), "Viewer still has read access")
    let visible = try await engine.lookup("/Empty.txt")
    try require(visible?.attributes?.permissions == 0o444, "Viewer permissions must be read-only")
    do { try await engine.requireWrite(); throw POSIXError(.EIO) }
    catch let error as POSIXError { try require(error.code == .EROFS, "Viewer writes must fail with EROFS") }
    let mountPath = "/Volumes/GardenPermissionTest-\(account)"
    let mounted = try await RemoteMount.start(engine: engine, path: mountPath, name: "Garden Permission Test")
    let loop = Task { try await mounted.run() }
    do {
      let path = mountPath + "/Empty.txt"
      var info = stat()
      try require(stat(path, &info) == 0 && info.st_size == 0 && info.st_blocks == 0, "Mounted read-only file must have zero payload blocks")
      let fd = open(path, O_WRONLY)
      if fd >= 0 { close(fd); throw POSIXError(.EIO) }
      try require(errno == EROFS || errno == EACCES, "Write open must fail at the mount")
      try require(mkdir(mountPath + "/Denied", 0o755) == -1 && (errno == EROFS || errno == EACCES), "Viewer mkdir must fail")
      try require(unlink(path) == -1 && (errno == EROFS || errno == EACCES), "Viewer unlink must fail")
      PermissionProtocol.role(nil)
      try require(try await engine.checkWithdrawal(), "Removal must be recognized explicitly")
      do { _ = try await engine.lookup("/Empty.txt"); throw POSIXError(.EIO) }
      catch let error as POSIXError { try require(error.code == .EACCES, "Removal blocks cached metadata") }
      try await mounted.unmount(preserveWrites: true)
      try await loop.value
      await engine.stop()
      print("Mounted permissions: Viewer read access, zero payload blocks, write-open/mkdir/unlink denial and revoked cached access passed")
    } catch {
      mounted.stop()
      _ = try? await loop.value
      await engine.stop()
      throw error
    }
  }
}
