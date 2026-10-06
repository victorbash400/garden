import Foundation

actor GardenReadPermits {
  static let capacity = 12
  static let shared = GardenReadPermits()
  private var available = capacity
  private var waiting: [(UUID, Bool, CheckedContinuation<Void, Error>)] = []
  private var demanded: Set<UUID> = []

  func acquire(id: UUID = UUID(), speculative: Bool = false) async throws {
    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        if Task.isCancelled { continuation.resume(throwing: CancellationError()) }
        else if available > 0 { available -= 1; continuation.resume(returning: ()) }
        else { waiting.append((id, speculative && !demanded.contains(id), continuation)) }
      }
    } onCancel: { Task { await self.cancel(id) } }
  }

  func promote(_ id: UUID) {
    demanded.insert(id)
    if let index = waiting.firstIndex(where: { $0.0 == id }) { waiting[index].1 = false }
  }

  func forget(_ id: UUID) { demanded.remove(id) }

  func release() {
    if waiting.isEmpty { available += 1 }
    else {
      let index = waiting.firstIndex(where: { !$0.1 }) ?? 0
      waiting.remove(at: index).2.resume()
    }
  }

  private func cancel(_ id: UUID) {
    guard let index = waiting.firstIndex(where: { $0.0 == id }) else { return }
    waiting.remove(at: index).2.resume(throwing: CancellationError())
  }
}
