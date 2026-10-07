import Foundation

@main struct RangeBundleTests {
  static func require(_ value: Bool) throws {
    if !value { throw POSIXError(.EINVAL) }
  }

  static func main() async throws {
    let source = Data([0, 255, 128])
    let encoded = "decode('\(source.base64EncodedString())', 'base64')"
    let empty = "decode('', 'base64')"
    try require(GardenAPI.rangeBytes([encoded, empty, encoded], lengths: [3, 0, 3]) == [source, Data(), source])
    for (value, lengths) in [
      ([encoded], [3, 0]),
      ([encoded, empty], [3]),
      ([encoded], [2]),
      (["decode('%%%', 'base64')"], [3]),
      (["decode(', 'base64')"], [0]),
      (["AAEC"], [3]),
      (["decode('AAEC', 'other')"], [3]),
    ] {
      do {
        _ = try GardenAPI.rangeBytes(value, lengths: lengths)
        throw POSIXError(.EINVAL)
      } catch GardenAPIError.invalidResponse { }
    }
    let api = GardenAPI(domainID: "invalid-bundle-test")
    for (size, offsets, lengths) in [
      (-1, [0], [1]), (10, [], []), (10, [0], []),
      (10, Array(repeating: 0, count: 17), Array(repeating: 1, count: 17)),
      (10, [-1], [1]), (10, [11], [1]), (10, [0], [0]), (10, [0], [65537]),
    ] {
      do {
        _ = try await api.readRanges(id: 1, version: 1, size: size, offsets: offsets, lengths: lengths)
        throw POSIXError(.EINVAL)
      } catch GardenAPIError.invalidResponse { }
    }
    print("PASS: binary range responses, order, empty EOF, malformed responses and invalid inputs without credentials")
  }
}
