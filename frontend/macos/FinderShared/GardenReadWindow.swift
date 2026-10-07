import Foundation

struct GardenReadWindow {
  static let pageSize = 16 * 1024
  static let maximumSize = 1024 * 1024
  private struct Stream {
    var start: Int
    var end: Int
    var nearbyReads: Int
    var fastReads: Int
    var observedAt: ContinuousClock.Instant
  }
  private var streams: [Stream] = []
  private(set) var payloadReadAheadBlocks = 1

  mutating func observe(offset: Int, length: Int, now: ContinuousClock.Instant = .now) -> Int {
    let match = streams.indices.min { abs(streams[$0].end - offset) < abs(streams[$1].end - offset) }
    var nearbyReads = 0
    var start = offset
    var fastReads = 0
    if let match, abs(streams[match].end - offset) <= Self.pageSize / 4 {
      let stream = streams.remove(at: match)
      nearbyReads = min(stream.nearbyReads + (offset + length > stream.end ? 1 : 0), 3)
      start = min(stream.start, offset)
      if offset + length > stream.end, stream.observedAt.duration(to: now) <= .milliseconds(10) {
        fastReads = min(stream.fastReads + 1, 3)
      }
    }
    streams.append(Stream(start: start, end: offset + length, nearbyReads: nearbyReads,
      fastReads: fastReads, observedAt: now))
    if streams.count > 8 { streams.removeFirst() }
    payloadReadAheadBlocks = length >= Self.maximumSize
      || (offset + length - start >= Self.maximumSize && fastReads >= 3) ? 3 : 1
    if length > 64 * 1024 || nearbyReads >= 3 { return Self.maximumSize }
    return nearbyReads > 0 ? 256 * 1024 : (length > Self.pageSize ? 32 * 1024 : Self.pageSize)
  }
}
