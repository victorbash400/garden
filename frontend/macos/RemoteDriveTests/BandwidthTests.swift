import Foundation

@main struct BandwidthTests {
  static func main() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-bandwidth-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("settings.json")
    let budget = GardenBandwidth(file: file)
    guard try await budget.reserve(bytes: 1_000_000, upload: true) == 0 else { throw POSIXError(.EIO) }
    try await budget.set(GardenBandwidthLimits(upload: 1_000_000, download: 2_000_000))
    let delays = try await withThrowingTaskGroup(of: Double.self) { group in
      for _ in 0..<3 { group.addTask { try await budget.reserve(bytes: 1_000_000, upload: true) } }
      var values: [Double] = []
      for try await value in group { values.append(value) }
      return values.sorted()
    }
    guard delays.count == 3, delays[0] > 0.9, delays[1] > 1.9, delays[2] > 2.9,
      try await budget.reserve(bytes: 1_000_000, upload: false) < 0.6 else { throw POSIXError(.EIO) }
    let restored = GardenBandwidth(file: file)
    guard try await restored.status() == GardenBandwidthLimits(upload: 1_000_000, download: 2_000_000) else {
      throw POSIXError(.EIO)
    }
    do { try await budget.set(GardenBandwidthLimits(upload: -1)); throw POSIXError(.EIO) }
    catch let error as POSIXError where error.code == .EINVAL {}
    try await budget.set(GardenBandwidthLimits())
    guard try await budget.reserve(bytes: 1_000_000, upload: true) == 0 else { throw POSIXError(.EIO) }
    try await budget.set(GardenBandwidthLimits(upload: 1_000_000))
    let started = ContinuousClock.now
    try await budget.pace(bytes: 100_000, upload: true)
    guard started.duration(to: .now) >= .milliseconds(95) else { throw POSIXError(.EIO) }
    let task = Task { try await budget.pace(bytes: 10_000_000, upload: true) }
    task.cancel()
    do { try await task.value; throw POSIXError(.EIO) } catch is CancellationError {}
    print("Bandwidth: aggregate reservations, independent directions, persistence, invalid limits, pacing, unlimited and cancellation passed")
  }
}
