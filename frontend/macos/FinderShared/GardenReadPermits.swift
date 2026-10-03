import Foundation

actor GardenReadPermits {
  static let shared = GardenReadPermits()
  private var available = 3
  private var waiting: [(UUID, CheckedContinuation<Void, Error>)] = []

  func acquire() async throws {
    let id = UUID()
    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        if Task.isCancelled { continuation.resume(throwing: CancellationError()) }
        else if available > 0 { available -= 1; continuation.resume(returning: ()) }
        else { waiting.append((id, continuation)) }
      }
    } onCancel: { Task { await self.cancel(id) } }
  }

  func release() {
    if waiting.isEmpty { available += 1 }
    else { waiting.removeFirst().1.resume() }
  }

  private func cancel(_ id: UUID) {
    guard let index = waiting.firstIndex(where: { $0.0 == id }) else { return }
    waiting.remove(at: index).1.resume(throwing: CancellationError())
  }
}
