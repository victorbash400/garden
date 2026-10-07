import Foundation

struct GardenWebMIndex {
  private(set) var offsets: [Int]

  mutating func discoverClusters(in data: Data, offset: Int, fileSize: Int) {
    guard offset >= 0, offset <= fileSize, data.count <= fileSize - offset else { return }
    let first = lowerBound(offset)
    let end = lowerBound(offset + data.count)
    guard first < end else { return }
    let bytes = Array(data)
    var discovered: [Int] = []
    for start in offsets[first..<end] {
      var cursor = start - offset
      guard let cluster = Self.element(bytes, cursor: &cursor), cluster.id == 0x1f43b675,
        !cluster.unknownSize, cluster.end > cursor, cluster.end <= fileSize - offset else { continue }
      let next = offset + cluster.end
      let position = lowerBound(next)
      if next < fileSize, position == offsets.count || offsets[position] != next { discovered.append(next) }
    }
    guard !discovered.isEmpty else { return }
    let additions = Array(Set(discovered)).sorted()
    guard offsets.count + additions.count <= 16384 else { return }
    for next in additions { offsets.insert(next, at: lowerBound(next)) }
  }

  private func lowerBound(_ offset: Int) -> Int {
    var low = 0, high = offsets.count
    while low < high {
      let middle = (low + high) / 2
      if offsets[middle] < offset { low = middle + 1 } else { high = middle }
    }
    return low
  }

  func nextPages(after offset: Int, count: Int, excluding: Set<Int> = [], distance: Int = 64 * 1024 * 1024) -> [Int] {
    guard offset >= 0, count > 0, distance > 0 else { return [] }
    var low = 0, high = offsets.count
    while low < high {
      let middle = (low + high) / 2
      if offsets[middle] <= offset { low = middle + 1 } else { high = middle }
    }
    let end = offset + min(distance, Int.max - offset)
    var pages: [Int] = []
    for position in offsets.dropFirst(low) {
      if position >= end { break }
      let page = position / GardenReadWindow.pageSize
      if excluding.contains(page) || pages.last == page { continue }
      pages.append(page)
      if pages.count == count { break }
    }
    return pages
  }

  static func parse(_ data: Data, fileSize: Int) -> GardenWebMIndex? {
    let bytes = Array(data)
    var cursor = 0
    guard let header = element(bytes, cursor: &cursor), header.id == 0x1a45dfa3,
      header.end <= bytes.count else { return nil }
    cursor = header.end
    guard let segment = element(bytes, cursor: &cursor), segment.id == 0x18538067 else { return nil }
    let segmentStart = cursor
    while cursor < bytes.count {
      guard let top = element(bytes, cursor: &cursor) else { return nil }
      if top.id == 0x1f43b675 { return nil }
      guard top.end <= bytes.count else { return nil }
      if top.id != 0x1c53bb6b { cursor = top.end; continue }
      var offsets: [Int] = []
      while cursor < top.end {
        guard let point = element(bytes, cursor: &cursor), point.end <= top.end else { return nil }
        if point.id == 0xbb {
          while cursor < point.end {
            guard let child = element(bytes, cursor: &cursor), child.end <= point.end else { return nil }
            if child.id == 0xb7 {
              while cursor < child.end {
                guard let position = element(bytes, cursor: &cursor), position.end <= child.end else { return nil }
                if position.id == 0xf1 {
                  let length = position.end - cursor
                  guard length > 0, length <= 8 else { return nil }
                  var value: UInt64 = 0
                  for byte in bytes[cursor..<position.end] { value = (value << 8) | UInt64(byte) }
                  guard value < UInt64(fileSize), value <= UInt64(Int.max - segmentStart) else { return nil }
                  let offset = segmentStart + Int(value)
                  guard offset < fileSize else { return nil }
                  offsets.append(offset)
                  guard offsets.count <= 16384 else { return nil }
                }
                cursor = position.end
              }
            }
            cursor = child.end
          }
        }
        cursor = point.end
      }
      return offsets.isEmpty ? nil : GardenWebMIndex(offsets: Array(Set(offsets)).sorted())
    }
    return nil
  }

  private static func element(_ bytes: [UInt8], cursor: inout Int) -> (id: UInt64, end: Int, unknownSize: Bool)? {
    guard let id = integer(bytes, cursor: &cursor, keepMarker: true) else { return nil }
    let sizeStart = cursor
    guard let size = integer(bytes, cursor: &cursor, keepMarker: false), size <= UInt64(Int.max - cursor) else { return nil }
    let unknown = size == (UInt64(1) << (7 * (cursor - sizeStart))) - 1
    return (id, cursor + Int(size), unknown)
  }

  private static func integer(_ bytes: [UInt8], cursor: inout Int, keepMarker: Bool) -> UInt64? {
    guard cursor < bytes.count else { return nil }
    var marker: UInt8 = 0x80
    var length = 1
    while marker > 0, bytes[cursor] & marker == 0 { marker >>= 1; length += 1 }
    guard marker > 0, cursor + length <= bytes.count, !keepMarker || length <= 4 else { return nil }
    var value = UInt64(keepMarker ? bytes[cursor] : bytes[cursor] & (marker - 1))
    for byte in bytes[(cursor + 1)..<(cursor + length)] { value = (value << 8) | UInt64(byte) }
    cursor += length
    return value
  }
}
