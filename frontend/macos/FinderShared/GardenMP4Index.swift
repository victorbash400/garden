import Foundation

struct GardenMP4Index {
  private(set) var offsets: [Int]

  static func parse(_ data: Data, fileSize: Int) -> GardenMP4Index? {
    let bytes = Array(data)
    guard fileSize > 16, let first = atom(bytes, at: 0, fileSize: fileSize), first.type == "ftyp" else { return nil }
    var cursor = first.end
    while cursor < bytes.count {
      guard let item = atom(bytes, at: cursor, fileSize: fileSize) else { return nil }
      if item.type == "moof" { return GardenMP4Index(offsets: [cursor]) }
      if item.type == "mdat" { return nil }
      cursor = item.end
    }
    return nil
  }

  mutating func discoverFooter(_ data: Data, offset: Int, fileSize: Int) {
    guard offset >= 0, offset <= fileSize, data.count == fileSize - offset,
      data.count >= 16 else { return }
    let bytes = Array(data)
    guard let footer = Self.atom(bytes, at: bytes.count - 16, fileSize: bytes.count), footer.type == "mfro",
      footer.end == bytes.count, let size = Self.integer(bytes, at: bytes.count - 4, length: 4),
      size >= 24, size <= UInt64(bytes.count) else { return }
    let start = bytes.count - Int(size)
    guard let root = Self.atom(bytes, at: start, fileSize: bytes.count), root.type == "mfra",
      root.end == bytes.count else { return }
    var cursor = root.payload
    var found: [Int] = []
    while cursor < root.end {
      guard let item = Self.atom(bytes, at: cursor, fileSize: root.end), item.end <= root.end else { return }
      if item.type == "tfra" {
        guard let positions = Self.fragmentOffsets(bytes, payload: item.payload, end: item.end, fileSize: fileSize) else { return }
        found.append(contentsOf: positions)
        guard found.count <= 32768 else { return }
      }
      cursor = item.end
    }
    if !found.isEmpty { offsets = Array(Set(offsets + found)).sorted() }
  }

  func nextPages(after offset: Int, count: Int, excluding: Set<Int>) -> [Int] {
    guard offset >= 0, count > 0 else { return [] }
    var low = 0, high = offsets.count
    while low < high {
      let middle = (low + high) / 2
      if offsets[middle] <= offset { low = middle + 1 } else { high = middle }
    }
    let end = offset + min(64 * 1024 * 1024, Int.max - offset)
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

  private static func fragmentOffsets(_ bytes: [UInt8], payload: Int, end: Int, fileSize: Int) -> [Int]? {
    guard end - payload >= 16, bytes[payload] <= 1,
      let lengths = integer(bytes, at: payload + 8, length: 4),
      let entries = integer(bytes, at: payload + 12, length: 4), entries <= 16384 else { return nil }
    let width = bytes[payload] == 1 ? 8 : 4
    let variables = Int(lengths & 3) + Int((lengths >> 2) & 3) + Int((lengths >> 4) & 3) + 3
    let stride = width * 2 + variables
    guard Int(entries) <= (end - payload - 16) / stride else { return nil }
    var offsets: [Int] = []
    var cursor = payload + 16
    for _ in 0..<Int(entries) {
      guard let value = integer(bytes, at: cursor + width, length: width),
        value < UInt64(fileSize) else { return nil }
      offsets.append(Int(value))
      cursor += stride
    }
    return offsets
  }

  private static func atom(_ bytes: [UInt8], at start: Int, fileSize: Int) -> (type: String, payload: Int, end: Int)? {
    guard start >= 0, start <= fileSize, start <= bytes.count - 8,
      let short = integer(bytes, at: start, length: 4) else { return nil }
    var size = short
    var header = 8
    if size == 1 {
      guard let long = integer(bytes, at: start + 8, length: 8) else { return nil }
      size = long
      header = 16
    } else if size == 0 { size = UInt64(fileSize - start) }
    guard size >= UInt64(header), start <= fileSize, size <= UInt64(fileSize - start) else { return nil }
    let type = String(bytes: bytes[(start + 4)..<(start + 8)], encoding: .ascii) ?? ""
    return (type, start + header, start + Int(size))
  }

  private static func integer(_ bytes: [UInt8], at start: Int, length: Int) -> UInt64? {
    guard start >= 0, length > 0, length <= 8, start <= bytes.count - length else { return nil }
    var value: UInt64 = 0
    for byte in bytes[start..<(start + length)] { value = value << 8 | UInt64(byte) }
    return value
  }
}
