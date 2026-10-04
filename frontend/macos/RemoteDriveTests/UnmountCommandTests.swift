import Foundation
import Darwin

@main struct UnmountCommandTests {
  static func main() async throws {
    if CommandLine.arguments.dropFirst().first == "late-exit" {
      signal(SIGTERM, SIG_IGN)
      usleep(500_000)
      return
    }
    let success = RemoteCompletion<Void>()
    try await RemoteUnmountCommand(path: "test", executable: URL(fileURLWithPath: "/usr/bin/true"), arguments: []).run {
      success.resolve($0)
    }
    try await success.wait()

    let failure = RemoteCompletion<Void>()
    do {
      try await RemoteUnmountCommand(path: "test", executable: URL(fileURLWithPath: "/usr/bin/false"), arguments: []).run {
        failure.resolve($0)
      }
      throw POSIXError(.EIO)
    } catch let error as NSError where error.domain == "GardenRemoteUnmount" && error.code == 1 {}
    do { try await failure.wait(); throw POSIXError(.EIO) }
    catch let error as NSError where error.domain == "GardenRemoteUnmount" && error.code == 1 {}

    let terminated = RemoteCompletion<Void>()
    let started = ContinuousClock.now
    do {
      try await RemoteUnmountCommand(path: "test", executable: URL(fileURLWithPath: "/bin/sleep"), arguments: ["10"]).run(timeout: 0.1) {
        terminated.resolve($0)
      }
      throw POSIXError(.EIO)
    } catch let error as NSError where error.domain == "GardenRemoteUnmount" && error.code == Int(ETIMEDOUT) {}
    guard started.duration(to: .now) < .seconds(2) else { throw POSIXError(.ETIMEDOUT) }
    do { try await terminated.wait(); throw POSIXError(.EIO) }
    catch let error as NSError where error.domain == "GardenRemoteUnmount" {}

    let lateExit = RemoteCompletion<Void>()
    do {
      try await RemoteUnmountCommand(path: "test",
        executable: URL(fileURLWithPath: CommandLine.arguments[0]), arguments: ["late-exit"]).run(timeout: 0.2) {
        lateExit.resolve($0)
      }
      throw POSIXError(.EIO)
    } catch let error as NSError where error.domain == "GardenRemoteUnmount" && error.code == Int(ETIMEDOUT) {}
    try await lateExit.wait()

    let missing = RemoteCompletion<Void>()
    do {
      try await RemoteUnmountCommand(path: "test", executable: URL(fileURLWithPath: "/does-not-exist"), arguments: []).run {
        missing.resolve($0)
      }
      throw POSIXError(.EIO)
    } catch let error as NSError where error.domain == NSCocoaErrorDomain {}
    do { try await missing.wait(); throw POSIXError(.EIO) }
    catch let error as NSError where error.domain == NSCocoaErrorDomain {}
    print("Unmount command: success, explicit failure, bounded timeout, termination event, late exit and launch failure passed")
  }
}
