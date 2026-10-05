import CryptoKit
import Foundation

struct RemoteWritePublisher {
  let api: GardenAPI
  let ranges: GardenRangeCache
  let journal: RemoteWriteJournal

  func publish(_ state: RemoteWriteState) async throws -> GardenNode {
    guard state.sealed else { throw POSIXError(.EBUSY) }
    let upload = try await api.object(api.call("content", "beginEdit", [
      "nodeId": state.base.id, "baseVersion": state.base.version, "size": state.size,
      "operationId": state.operationID.uuidString,
      "modifiedAt": GardenFileAttributes.string(state.modified),
    ]))
    guard let id = upload["id"] as? Int, let committed = upload["committed"] as? Bool,
      let nodeID = upload["nodeId"] as? Int, upload["size"] as? Int == state.size else {
      throw GardenAPIError.invalidResponse
    }
    if committed { return try GardenNode(await api.object(api.call("files", "get", ["nodeId": nodeID]))) }
    if state.size <= RemoteWriteJournal.blockSize {
      if state.size > 0 {
        let bytes = try await RemoteWriteReader.read(state, journal: journal, ranges: ranges, offset: 0, length: state.size)
        try await GardenBandwidth.shared.pace(bytes: Int64(bytes.count), upload: true)
        _ = try await api.call("content", "writeChunk", ["versionId": id, "index": 0,
          "data": "decode('\(bytes.base64EncodedString())', 'base64')"])
      }
    } else {
      guard let partSize = upload["partSize"] as? Int, let count = upload["chunkCount"] as? Int,
        partSize >= 5 * 1024 * 1024, partSize <= 128 * 1024 * 1024,
        count == (state.size + partSize - 1) / partSize else { throw GardenAPIError.invalidResponse }
      try await multipart(state, id: id, partSize: partSize, count: count)
    }
    return try GardenNode(await api.object(api.call("content", "finish", ["versionId": id])))
  }

  private func multipart(_ state: RemoteWriteState, id: Int, partSize: Int, count: Int) async throws {
    guard let records = try await api.call("content", "uploadedParts", ["versionId": id]) as? [[String: Any]] else {
      throw GardenAPIError.invalidResponse
    }
    var uploaded: [Int: (Int, String)] = [:]
    for record in records {
      guard let number = record["number"] as? Int, let size = record["size"] as? Int,
        let checksum = record["checksum"] as? String, uploaded[number] == nil else { throw GardenAPIError.invalidResponse }
      uploaded[number] = (size, checksum)
    }
    var objectBase = false
    if state.base.version != 0 && state.base.size > 5 * 1024 * 1024 {
      objectBase = try await api.download(id: state.base.id, version: state.base.version).url != nil
    }
    func copyable(_ number: Int) throws -> Bool {
      let offset = (number - 1) * partSize
      let length = min(partSize, state.size - offset)
      guard objectBase, offset + length <= state.baseLimit else { return false }
      return try !journal.hasChanges(state.base.id, offset: offset, length: length)
    }
    var number = 1
    while number <= count {
      try Task.checkCancellation()
      if try copyable(number) {
        var batch = 1
        while batch < 3 && number + batch <= count {
          guard try copyable(number + batch) else { break }
          batch += 1
        }
        _ = try await api.call("content", "copyParts", ["versionId": id, "first": number, "count": batch])
        number += batch
        continue
      }
      let offset = (number - 1) * partSize
      let length = min(partSize, state.size - offset)
      var bytes = Data(capacity: length)
      while bytes.count < length {
        let block = try await RemoteWriteReader.read(state, journal: journal, ranges: ranges,
          offset: offset + bytes.count, length: min(1024 * 1024, length - bytes.count))
        guard !block.isEmpty else { throw POSIXError(.EIO) }
        bytes.append(block)
      }
      let checksum = Insecure.MD5.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
      if uploaded[number]?.0 != length || uploaded[number]?.1 != checksum {
        guard let urls = try await api.call("content", "uploadParts", ["versionId": id, "first": number, "count": 1]) as? [String],
          urls.count == 1, let url = URL(string: urls[0]), url.scheme == "https" else { throw GardenAPIError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.timeoutInterval = 120
        try await GardenObjectRequests.upload(request, data: bytes)
      }
      number += 1
    }
  }
}
