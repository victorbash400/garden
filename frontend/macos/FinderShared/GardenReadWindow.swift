import Foundation

struct GardenReadWindow {
  static let pageSize = 64 * 1024
  static let maximumSize = 1024 * 1024
  private struct Stream { var end: Int; var nearbyReads: Int }
  private var streams: [Stream] = []

  mutating func observe(offset: Int, length: Int) -> Int {
    let match = streams.indices.min { abs(streams[$0].end - offset) < abs(streams[$1].end - offset) }
    var nearbyReads = 0
    if let match, abs(streams[match].end - offset) <= Self.pageSize / 4 {
      let stream = streams.remove(at: match)
      nearbyReads = min(stream.nearbyReads + (offset + length > stream.end ? 1 : 0), 3)
    }
    streams.append(Stream(end: offset + length, nearbyReads: nearbyReads))
    if streams.count > 8 { streams.removeFirst() }
    if length > Self.pageSize || nearbyReads >= 3 { return Self.maximumSize }
    return nearbyReads > 0 ? 256 * 1024 : Self.pageSize
  }
}
