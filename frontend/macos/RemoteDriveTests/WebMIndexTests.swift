import Foundation

@main struct WebMIndexTests {
  static func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw NSError(domain: "WebMIndexTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
  }
  static func main() throws {
    // Two CuePoints with CueTrackPositions/CueClusterPosition, relative to the Segment payload.
    let bytes: [UInt8] = [
      0x1a,0x45,0xdf,0xa3,0x80, 0x18,0x53,0x80,0x67,0xff,
      0x1c,0x53,0xbb,0x6b,0x94,
      0xbb,0x88,0xb7,0x86,0xf1,0x84,0x00,0x10,0x00,0x00,
      0xbb,0x88,0xb7,0x86,0xf1,0x84,0x00,0x20,0x00,0x00
    ]
    guard let index = GardenWebMIndex.parse(Data(bytes), fileSize: 4 * 1024 * 1024) else {
      throw NSError(domain: "WebMIndexTests", code: 2)
    }
    try require(index.offsets == [1048586,2097162], "Cue offsets must be relative to Segment payload")
    try require(index.nextPages(after: 0, count: 1) == [16], "The read-ahead window must stay bounded")
    try require(index.nextPages(after: 0, count: 1, excluding: [16]) == [32], "Completed pages must not block refilling")
    try require(index.nextPages(after: 0, count: 12, distance: 1024 * 1024).isEmpty, "Read-ahead must not pass its distance limit")
    try require(index.nextPages(after: 1048586, count: 12) == [32], "A seek must move the window forward")
    try require(index.nextPages(after: 2097162, count: 12).isEmpty, "No fetches beyond the index")
    try require(GardenWebMIndex.parse(Data(bytes.dropLast()), fileSize: 4 * 1024 * 1024) == nil, "Truncated cues must not be guessed")
    try require(GardenWebMIndex.parse(Data(bytes), fileSize: 100) == nil, "Out-of-file positions must be rejected")
    for length in 0..<bytes.count {
      _ = GardenWebMIndex.parse(Data(bytes.prefix(length)), fileSize: 4 * 1024 * 1024)
    }
    var chain = GardenWebMIndex(offsets: [0])
    chain.discoverClusters(in: Data([0x1f, 0x43, 0xb6, 0x75, 0x81, 0]), offset: 0, fileSize: 12)
    try require(chain.offsets == [0, 6], "Cluster size must locate the following header without reading payload")
    chain.discoverClusters(in: Data([0x1f, 0x43, 0xb6, 0x75, 0x81, 0]), offset: 6, fileSize: 12)
    try require(chain.offsets == [0, 6], "Cluster discovery must not add a position at EOF")
    chain.discoverClusters(in: Data([0x1f, 0x43, 0xb6, 0x75, 0xff]), offset: 6, fileSize: 12)
    try require(chain.offsets == [0, 6], "Invalid or unknown cluster sizes must not invent positions")
    var sparse = GardenWebMIndex(offsets: [0, 64 * 1024, 128 * 1024])
    sparse.discoverClusters(in: Data([0x1f, 0x43, 0xb6, 0x75, 0x81, 0]), offset: 64 * 1024,
      fileSize: 256 * 1024)
    try require(sparse.offsets == [0, 65536, 65542, 131072], "Indexed range lookup must include a header at the page start")
    for _ in 0..<100 {
      sparse.discoverClusters(in: Data([0x1f, 0x43, 0xb6, 0x75, 0x81, 0]), offset: 64 * 1024,
        fileSize: 256 * 1024)
    }
    try require(sparse.offsets == [0, 65536, 65542, 131072], "Repeated cached headers must not duplicate offsets")
    sparse.discoverClusters(in: Data([0x1f, 0x43, 0xb6, 0x75, 0x81, 0]), offset: 100,
      fileSize: 256 * 1024)
    try require(sparse.offsets == [0, 65536, 65542, 131072], "Bytes outside indexed headers must not invent clusters")
    let nearLimit = Array(stride(from: 0, to: 16383 * 8, by: 8))
    var limited = GardenWebMIndex(offsets: nearLimit)
    var pair = Data(repeating: 0, count: 16)
    pair.replaceSubrange(0..<6, with: [0x1f, 0x43, 0xb6, 0x75, 0x81, 0])
    pair.replaceSubrange(8..<14, with: [0x1f, 0x43, 0xb6, 0x75, 0x81, 0])
    limited.discoverClusters(in: pair, offset: 0, fileSize: 16384 * 8)
    try require(limited.offsets == nearLimit, "An oversized discovery must preserve the entire existing index")
    pair[4] = 0x89
    limited.discoverClusters(in: pair, offset: 0, fileSize: 16384 * 8)
    try require(limited.offsets.count == 16384 && limited.offsets.contains(14),
      "Duplicate discoveries must count once when filling the index limit")
    let complete = limited.offsets
    limited.discoverClusters(in: pair, offset: 0, fileSize: 16384 * 8)
    try require(limited.offsets == complete, "Repeated discoveries at capacity must remain unchanged")
    for argument in CommandLine.arguments.dropFirst() {
      let file = URL(fileURLWithPath: argument)
      let handle = try FileHandle(forReadingFrom: file)
      defer { try? handle.close() }
      let size = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize!
      guard let header = try handle.read(upToCount: 65536), let index = GardenWebMIndex.parse(header, fileSize: size) else {
        throw NSError(domain: "WebMIndexTests", code: 3)
      }
      for offset in index.offsets {
        try handle.seek(toOffset: UInt64(offset))
        try require(try handle.read(upToCount: 4) == Data([0x1f,0x43,0xb6,0x75]), "A cue must point to an actual Cluster")
      }
      print(file.lastPathComponent, index.offsets.count, "verified cluster offsets from a 64 KiB header")
    }
    print("Bounded seek windows, truncated indexes, invalid positions and actual cluster locations passed")
  }
}
