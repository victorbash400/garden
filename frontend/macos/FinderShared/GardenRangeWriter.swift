import Foundation

struct GardenRangeWriter {
  static func write(start: Int, end: Int, to url: URL, progress: Progress,
    fetch: @escaping @Sendable (Int, Int) async throws -> Data) async throws {
    guard start >= 0, end >= start else { throw GardenAPIError.invalidResponse }
    guard FileManager.default.createFile(atPath: url.path, contents: nil) else {
      throw CocoaError(.fileWriteUnknown)
    }
    let handle = try FileHandle(forWritingTo: url)
    defer { try? handle.close() }
    var complete = false
    defer { if !complete { try? FileManager.default.removeItem(at: url) } }
    try handle.truncate(atOffset: UInt64(end))
    progress.totalUnitCount = Int64(max(end - start, 1))
    var offset = start
    while offset < end {
      try Task.checkCancellation()
      let batchEnd = min(end, offset + 3 * GardenRangeCache.blockSize)
      try await withThrowingTaskGroup(of: (Int, Data).self) { group in
        while offset < batchEnd {
          let position = offset
          let count = min(GardenRangeCache.blockSize, batchEnd - position)
          group.addTask {
            let bytes = try await fetch(position, count)
            guard bytes.count == count else { throw GardenAPIError.invalidResponse }
            return (position, bytes)
          }
          offset += count
        }
        for try await (position, bytes) in group {
          try Task.checkCancellation()
          try handle.seek(toOffset: UInt64(position))
          try handle.write(contentsOf: bytes)
          progress.completedUnitCount += Int64(bytes.count)
        }
      }
    }
    complete = true
  }
}
