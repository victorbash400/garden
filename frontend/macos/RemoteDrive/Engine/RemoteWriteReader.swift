import Foundation

enum RemoteWriteReader {
  static func read(_ state: RemoteWriteState, journal: RemoteWriteJournal, ranges: GardenRangeCache,
    offset: Int, length: Int) async throws -> Data {
    guard offset >= 0, length >= 0, length <= 16 * 1024 * 1024 else { throw POSIXError(.EINVAL) }
    if offset >= state.size || length == 0 { return Data() }
    let end = offset + min(length, state.size - offset)
    let extents = try journal.extents(state.base.id, offset: offset, length: end - offset)
    var result = Data(repeating: 0, count: end - offset)
    var cursor = offset
    for extent in extents {
      let start = max(offset, extent.offset)
      let stop = min(end, extent.offset + extent.bytes.count)
      if cursor < start && cursor < state.baseLimit {
        let count = min(start, state.baseLimit) - cursor
        let bytes = try await ranges.read(node: state.base, offset: cursor, length: count, persist: false)
        guard bytes.count == count else { throw POSIXError(.EIO) }
        result.replaceSubrange((cursor - offset)..<(cursor - offset + count), with: bytes)
      }
      result.replaceSubrange((start - offset)..<(stop - offset),
        with: extent.bytes[(start - extent.offset)..<(stop - extent.offset)])
      cursor = stop
    }
    if cursor < end && cursor < state.baseLimit {
      let count = min(end, state.baseLimit) - cursor
      let bytes = try await ranges.read(node: state.base, offset: cursor, length: count, persist: false)
      guard bytes.count == count else { throw POSIXError(.EIO) }
      result.replaceSubrange((cursor - offset)..<(cursor - offset + count), with: bytes)
    }
    return result
  }
}
