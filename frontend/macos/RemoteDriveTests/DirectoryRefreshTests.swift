import Foundation
import Darwin

final class DirectoryPermissionProtocol: URLProtocol {
  override class func canInit(with request: URLRequest) -> Bool { request.url?.host == "garden-directory.test" }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    guard let url = request.url, url.path == "/driveMembers/accessRole",
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1",
        headerFields: ["Content-Type": "application/json"]) else {
      client?.urlProtocol(self, didFailWithError: POSIXError(.EINVAL)); return
    }
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: Data("\"Owner\"".utf8))
    client?.urlProtocolDidFinishLoading(self)
  }
  override func stopLoading() { }
}

@main struct DirectoryRefreshTests {
  static func node(_ id: Int, parent: Int = 0, name: String, folder: Bool = false,
    deleted: Bool = false) throws -> GardenNode {
    try GardenNode(["id": id, "parentId": parent, "name": name, "kind": folder ? "folder" : "file",
      "size": folder ? 0 : 16, "version": 1, "updatedAt": "2026-10-07T18:00:00.000Z", "deleted": deleted])
  }

  static func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw NSError(domain: "DirectoryRefreshTests", code: 1,
      userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func names(_ directory: UnsafeMutablePointer<DIR>) throws -> [String] {
    var names: [String] = []
    errno = 0
    while let entry = readdir(directory) {
      let name = withUnsafePointer(to: entry.pointee.d_name) {
        $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXNAMLEN) + 1) { String(cString: $0) }
      }
      if name != ".", name != ".." { names.append(name) }
    }
    guard errno == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
    return names.sorted()
  }

  static func main() async {
    do { try await run() }
    catch { print("Directory refresh failed: \(error.localizedDescription)"); exit(1) }
  }

  static func run() async throws {
    URLProtocol.registerClass(DirectoryPermissionProtocol.self)
    let account = UUID().uuidString.lowercased()
    let domain = "account-\(account)-drive-1"
    try FinderCredentialStore.save(FinderCredential(serverURL: "https://garden-directory.test/", accountID: account,
      driveID: 1, tokenID: domain, token: "fixture", refreshToken: "fixture"), domainID: domain)
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent("garden-directory-\(UUID())")
    defer { try? FinderCredentialStore.remove(domain); try? FileManager.default.removeItem(at: directory) }
    let engine = try RemoteEngine(domainID: domain, state: directory,
      cache: directory.appendingPathComponent("cache"), limit: 1024 * 1024)
    try await engine.reconnect()
    try await engine.metadata.reset(nodes: [node(1, name: "Audio", folder: true),
      node(2, parent: 1, name: "Source.wav")], revision: 1)
    let root = try await engine.open("/", directory: true)
    let folder = try await engine.open("/Audio", directory: true)
    try require(try await engine.list(folder).map(\.name) == ["Source.wav"], "Initial listing must contain the source")
    try await engine.receive(GardenChange(revision: 2, operation: "create",
      node: node(3, parent: 1, name: "Export.m4a"), previousParentID: nil))
    try require(try await engine.list(folder, offset: 2).map(\.name) == ["Source.wav"],
      "A continued enumeration must keep its original cookies")
    try require(try await engine.list(folder).map(\.name) == ["Export.m4a", "Source.wav"],
      "Rewinding an existing handle must reveal a newly saved artifact")
    try await engine.receive(GardenChange(revision: 3, operation: "delete",
      node: node(2, parent: 1, name: "Source.wav", deleted: true), previousParentID: 1))
    try require(try await engine.list(folder).map(\.name) == ["Export.m4a"],
      "A rewound listing must remove deleted entries")
    try await engine.receive(GardenChange(revision: 4, operation: "create",
      node: node(4, name: "Render.mp4"), previousParentID: nil))
    try require(try await engine.list(root).map(\.name) == ["Audio", "Render.mp4"],
      "Root handles must also refresh without being closed")
    let mountPath = "/Volumes/GardenDirectoryTest-\(account)"
    let mounted = try await RemoteMount.start(engine: engine, path: mountPath, name: "Garden Directory Test")
    let running = Task { try await mounted.run() }
    do {
      guard let stream = opendir(mountPath + "/Audio") else { throw POSIXError(.EIO) }
      defer { closedir(stream) }
      try require(try names(stream) == ["Export.m4a"], "Mounted directory must expose its initial contents")
      try await engine.receive(GardenChange(revision: 5, operation: "create",
        node: node(5, parent: 1, name: "Second.m4a"), previousParentID: nil))
      rewinddir(stream)
      try require(try names(stream) == ["Export.m4a", "Second.m4a"],
        "Mounted rewind must expose a saved file through the same directory stream")
    } catch {
      try await mounted.unmount()
      try await running.value
      throw error
    }
    try await mounted.unmount()
    try await running.value
    try await engine.close(folder)
    do { _ = try await engine.list(folder); throw POSIXError(.EIO) }
    catch let error as POSIXError { try require(error.code == .EBADF, "Closed handles must fail explicitly") }
    print("Directory refresh: mounted rewind, saved artifacts, deletion, root rewind, stable continuation cookies and closed handles passed")
  }
}
