import Foundation

@main struct MP4IndexTests {
  static func require(_ condition: Bool, _ message: String) throws {
    guard condition else { throw NSError(domain: "MP4IndexTests", code: 1,
      userInfo: [NSLocalizedDescriptionKey: message]) }
  }
  static func integer(_ value: UInt64, width: Int = 4) -> Data {
    Data((0..<width).reversed().map { UInt8(truncatingIfNeeded: value >> ($0 * 8)) })
  }
  static func atom(_ type: String, _ payload: Data = Data()) -> Data {
    integer(UInt64(payload.count + 8)) + Data(type.utf8) + payload
  }
  static func footer(_ positions: [UInt64], version: UInt8) -> Data {
    let width = version == 1 ? 8 : 4
    var table = Data([version, 0, 0, 0]) + integer(1) + integer(0) + integer(UInt64(positions.count))
    for position in positions { table += integer(0, width: width) + integer(position, width: width) + Data([1, 1, 1]) }
    let index = atom("tfra", table)
    return atom("mfra", index + atom("mfro", integer(0) + integer(UInt64(index.count + 24))))
  }
  static func main() throws {
    let prefix = atom("ftyp", Data("isom".utf8)) + atom("moov") + atom("moof") + atom("mdat")
    guard let initial = GardenMP4Index.parse(prefix, fileSize: 6_000_000_000) else { throw POSIXError(.EINVAL) }
    for version: UInt8 in [0, 1] {
      var index = initial
      let positions: [UInt64] = version == 0 ? [1_000_000, 2_000_000] : [1_000_000, 5_000_000_000]
      let bytes = footer(positions, version: version)
      index.discoverFooter(bytes, offset: 6_000_000_000 - bytes.count, fileSize: 6_000_000_000)
      try require(index.offsets == ([20] + positions.map(Int.init)).sorted(), "32-bit and 64-bit fragment locations must preserve exact file offsets")
      try require(index.nextPages(after: 0, count: 1, excluding: [0]) == [15], "Read-ahead must honor exclusions and page limits")
      if version == 1 { try require(index.nextPages(after: 2_000_000, count: 12, excluding: []).isEmpty, "Distant seeks must stay outside the 64 MiB window") }
      var truncated = initial
      truncated.discoverFooter(bytes.dropLast(), offset: 6_000_000_000 - bytes.count, fileSize: 6_000_000_000)
      try require(truncated.offsets == initial.offsets, "A truncated footer must not publish partial positions")
    }
    var invalid = initial
    let bad = footer([6_000_000_000], version: 1)
    invalid.discoverFooter(bad, offset: 6_000_000_000 - bad.count, fileSize: 6_000_000_000)
    try require(invalid.offsets == initial.offsets, "Out-of-file positions must be rejected")
    let overflow = integer(1) + Data("ftyp".utf8) + integer(UInt64.max, width: 8)
    try require(GardenMP4Index.parse(overflow, fileSize: Int.max) == nil, "Oversized extended atoms must not overflow")
    try require(GardenMP4Index.parse(atom("ftyp") + atom("mdat"), fileSize: 64) == nil, "Unfragmented files must not invent a fragment index")
    for path in CommandLine.arguments.dropFirst() {
      let url = URL(fileURLWithPath: path)
      let file = try FileHandle(forReadingFrom: url)
      defer { try? file.close() }
      let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize!
      guard let head = try file.read(upToCount: 65536), var index = GardenMP4Index.parse(head, fileSize: size) else { throw POSIXError(.EINVAL) }
      let start = (size - 1) / 65536 * 65536
      try file.seek(toOffset: UInt64(start))
      guard let tail = try file.read(upToCount: size - start) else { throw POSIXError(.EIO) }
      index.discoverFooter(tail, offset: start, fileSize: size)
      try require(index.offsets.count > 1, "Real footer must provide fragment locations")
      for offset in index.offsets {
        try file.seek(toOffset: UInt64(offset + 4))
        try require(file.read(upToCount: 4) == Data("moof".utf8), "Every recorded position must identify a real movie fragment")
      }
      print(index.offsets.count, "fragment offsets verified using two metadata pages")
    }
    print("32/64-bit indexes, bounded seeks, truncated footers and invalid offsets passed")
  }
}
