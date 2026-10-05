import Foundation

@MainActor final class GardenRelaunchReceipt {
  private static let notification = Notification.Name("garden.relaunch.received")
  private var observer: NSObjectProtocol?
  private var received: Bool?
  private var continuation: CheckedContinuation<Void, Error>?

  init(name: String) {
    observer = DistributedNotificationCenter.default().addObserver(
      forName: Self.notification, object: name, queue: .main
    ) { [weak self] notification in
      let accepted = notification.userInfo?["accepted"] as? Bool == true
      Task { @MainActor in self?.finish(accepted) }
    }
  }

  func wait() async throws {
    defer { close() }
    try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      if let received { finish(received); return }
      DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
        guard let self, self.continuation != nil else { return }
        self.finish(false)
      }
    }
  }

  private func finish(_ accepted: Bool) {
    received = accepted
    guard let continuation else { return }
    self.continuation = nil
    if accepted { continuation.resume() }
    else {
      continuation.resume(throwing: NSError(domain: "GardenRelaunch", code: 2,
        userInfo: [NSLocalizedDescriptionKey: "The new window could not restore the account sessions."]))
    }
  }

  func close() {
    if let observer { DistributedNotificationCenter.default().removeObserver(observer) }
    observer = nil
  }

  static func acknowledge(arguments: [String], accepted: Bool) {
    guard let index = arguments.firstIndex(of: GardenSessionHandoff.argument),
          index + 1 < arguments.count else { return }
    DistributedNotificationCenter.default().postNotificationName(
      notification, object: arguments[index + 1], userInfo: ["accepted": accepted], deliverImmediately: true)
  }
}
