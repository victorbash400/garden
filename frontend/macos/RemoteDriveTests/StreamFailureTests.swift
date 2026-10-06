import Foundation

@main struct StreamFailureTests {
  static func main() async throws {
    let stream = RemoteSubscription(api: GardenAPI(domainID: "stream-failure-test"), revision: { 0 }) { _ in }
    await stream.recordFailure(POSIXError(.ENOTCONN))
    guard await stream.issue != nil, await stream.accessDenied == false else { throw POSIXError(.EIO) }
    await stream.recordFailure(GardenAPIError.invalidResponse)
    guard await stream.issue != nil, await stream.accessDenied == false else { throw POSIXError(.EIO) }
    await stream.recordFailure(GardenAPIError.unauthorized)
    guard await stream.accessDenied else { throw POSIXError(.EIO) }
    await stream.recordFailure(GardenAPIError.http(403, "Access denied"))
    guard await stream.accessDenied else { throw POSIXError(.EIO) }
    await stream.recordFailure(GardenAPIError.http(503, "Stream closed"))
    guard await stream.issue != nil, await stream.accessDenied == false else { throw POSIXError(.EIO) }
    await stream.stop()
    print("Stream failures remain visible; only explicit authentication/access rejection withdraws read access")
  }
}
