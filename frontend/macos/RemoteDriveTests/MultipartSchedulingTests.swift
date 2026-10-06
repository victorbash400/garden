import CryptoKit
import Darwin
import Foundation

private final class UploadProtocol: URLProtocol {
  static let lock = NSLock()
  static var pending: [Int: UploadProtocol] = [:]
  static var waiting: [Int: CheckedContinuation<Void, Never>] = [:]
  static var uploaded: Set<Int> = []
  static var peak = 0
  static var finishes = 0
  static var duplicate = false

  override class func canInit(with request: URLRequest) -> Bool { request.url?.host == "garden-upload.test" }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    let method = request.url!.lastPathComponent
    if let part = Int(method) {
      Self.lock.withLock {
        Self.pending[part] = self
        Self.peak = max(Self.peak, Self.pending.count)
        Self.waiting.removeValue(forKey: part)?.resume()
      }
      return
    }
    switch method {
    case "beginMultipart": finish(["id": 10, "partSize": 4, "chunkCount": 6])
    case "uploadParts": finish((1...6).map { "https://garden-upload.test/object/\($0)" })
    case "uploadedParts":
      let numbers = Self.lock.withLock { Self.uploaded.sorted() }
      let selected = Self.duplicate && numbers.count == 6 ? [1, 1, 3, 4, 5, 6] : numbers
      finish(selected.map { part in
        ["number": part, "size": 4,
         "checksum": Insecure.MD5.hash(data: Data(((part - 1) * 4..<(part * 4)).map(UInt8.init)))
          .map { String(format: "%02x", $0) }.joined()] as [String: Any]
      })
    case "finish":
      Self.lock.withLock { Self.finishes += 1 }
      finish(["id": 1, "parentId": 0, "name": "fixture.bin", "kind": "file", "size": 24,
        "version": 10, "updatedAt": "2026-10-06T00:00:00.000Z", "deleted": false])
    default: client?.urlProtocol(self, didFailWithError: GardenAPIError.invalidResponse)
    }
  }
  static func started(_ part: Int) async {
    await withCheckedContinuation { continuation in
      lock.withLock {
        if pending[part] != nil { continuation.resume() }
        else { waiting[part] = continuation }
      }
    }
  }
  static func release(_ part: Int) throws {
    let request = lock.withLock { () -> UploadProtocol? in
      guard let request = pending.removeValue(forKey: part) else { return nil }
      uploaded.insert(part)
      return request
    }
    guard let request else { throw POSIXError(.EIO) }
    request.finish(NSNull())
  }
  private func finish(_ value: Any) {
    do {
      let bytes = try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed])
      let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: bytes)
      client?.urlProtocolDidFinishLoading(self)
    } catch { client?.urlProtocol(self, didFailWithError: error) }
  }
  override func stopLoading() { }
}

@main struct MultipartSchedulingTests {
  static func main() async throws {
    URLProtocol.registerClass(UploadProtocol.self)
    let account = UUID().uuidString.lowercased()
    let domain = "account-\(account)-drive-1"
    let file = FileManager.default.temporaryDirectory.appendingPathComponent("garden-upload-\(UUID())")
    try Data((0..<24).map(UInt8.init)).write(to: file)
    try FinderCredentialStore.save(FinderCredential(serverURL: "https://garden-upload.test/", accountID: account,
      driveID: 1, tokenID: domain, token: "fixture", refreshToken: "fixture"), domainID: domain)
    defer { try? FinderCredentialStore.remove(domain); try? FileManager.default.removeItem(at: file) }
    let api = GardenAPI(domainID: domain)
    let operation = Task { try await api.uploadMultipart(id: 1, baseVersion: 0, fileURL: file, size: 24) }
    await UploadProtocol.started(3)
    try UploadProtocol.release(1)
    await UploadProtocol.started(4)
    guard UploadProtocol.lock.withLock({ UploadProtocol.pending[2] != nil && UploadProtocol.pending[3] != nil }) else {
      throw POSIXError(.EIO)
    }
    for part in 2...6 {
      await UploadProtocol.started(part)
      try UploadProtocol.release(part)
    }
    guard try await operation.value.size == 24,
      UploadProtocol.lock.withLock({ UploadProtocol.peak == 3 && UploadProtocol.finishes == 1 }) else { throw POSIXError(.EIO) }
    UploadProtocol.lock.withLock { UploadProtocol.uploaded.removeAll(); UploadProtocol.duplicate = true }
    let invalid = Task { try await api.uploadMultipart(id: 1, baseVersion: 0, fileURL: file, size: 24) }
    for part in 1...6 {
      await UploadProtocol.started(part)
      try UploadProtocol.release(part)
    }
    do { _ = try await invalid.value; throw POSIXError(.EIO) }
    catch GardenAPIError.invalidResponse { }
    guard UploadProtocol.lock.withLock({ UploadProtocol.finishes == 1 }) else { throw POSIXError(.EIO) }
    print("Native multipart: completed slots refill with slow parts pending; three-part limit and duplicate checksum rejection passed")
  }
}
