import Foundation
import CryptoKit

extension GardenAPI {
  func uploadMultipart(id: Int, baseVersion: Int, fileURL: URL, size: Int) async throws -> GardenNode {
    let version = try object(await call("content", "beginMultipart", [
      "nodeId": id, "baseVersion": baseVersion, "size": size,
    ]))
    guard let versionID = version["id"] as? Int, let partSize = version["partSize"] as? Int,
          let count = version["chunkCount"] as? Int else { throw GardenAPIError.invalidResponse }
    guard partSize > 0, count > 0, count == (size - 1) / partSize + 1 else {
      throw GardenAPIError.invalidResponse
    }
    guard let records = try await call("content", "uploadedParts", ["versionId": versionID]) as? [[String: Any]] else { throw GardenAPIError.invalidResponse }
    var completed: [Int: (Int, String)] = [:]
    var expected: [Int: (Int, String)] = [:]
    for record in records {
      guard let number = record["number"] as? Int, let size = record["size"] as? Int,
            let checksum = record["checksum"] as? String else { throw GardenAPIError.invalidResponse }
      completed[number] = (size, checksum)
    }
    let handle = try FileHandle(forReadingFrom: fileURL)
    defer { try? handle.close() }
    var urls: [String] = []
    var first = 0
    var part = 1
    try await withThrowingTaskGroup(of: Void.self) { group in
      var pending = 0
      while part <= count {
        try Task.checkCancellation()
        if pending == 3 {
          _ = try await group.next()
          pending -= 1
        }
        if part >= first + urls.count {
          first = part
          guard let signed = try await call("content", "uploadParts", [
            "versionId": versionID, "first": first, "count": min(32, count - first + 1),
          ]) as? [String], signed.count == min(32, count - first + 1) else {
            throw GardenAPIError.invalidResponse
          }
          urls = signed
        }
        let number = part
        let length = min(partSize, size - (number - 1) * partSize)
        guard let data = try handle.read(upToCount: length), data.count == length,
              let url = URL(string: urls[number - first]), url.scheme == "https" else {
          throw GardenAPIError.invalidResponse
        }
        let checksum = Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
        expected[number] = (length, checksum)
        part += 1
        if let existing = completed[number], existing.0 == length, existing.1 == checksum { continue }
        group.addTask {
          var request = URLRequest(url: url)
          request.httpMethod = "PUT"
          request.timeoutInterval = 120
          try await GardenObjectRequests.upload(request, data: data)
        }
        pending += 1
      }
      try await group.waitForAll()
    }
    guard let verified = try await call("content", "uploadedParts", ["versionId": versionID]) as? [[String: Any]], verified.count == count else { throw GardenAPIError.invalidResponse }
    for record in verified {
      guard let number = record["number"] as? Int, let size = record["size"] as? Int,
        let checksum = record["checksum"] as? String, let value = expected.removeValue(forKey: number),
        value.0 == size, value.1 == checksum else { throw GardenAPIError.invalidResponse }
    }
    return try GardenNode(object(await call("content", "finish", ["versionId": versionID])))
  }

}
