import Foundation

struct GardenActivityEntry: Codable, Sendable {
  let id: String
  let account: String
  let drive: Int
  let node: Int
  let name: String
  let action: String
  let source: String
  let error: String?
  var time: Double
  var bytes: Int
  var milliseconds: Double
  var count: Int
}

actor GardenActivity {
  static let shared = GardenActivity()
  private var entries: [GardenActivityEntry] = []
  private var observers: [UUID: (String, AsyncThrowingStream<Data, Error>.Continuation)] = [:]
  private var publication: Task<Void, Never>?

  func record(domain: String, name: String, action: String, source: String = "Remote disk", node: Int = 0, bytes: Int = 0, milliseconds: Double = 0, error: String? = nil) {
    guard domain.hasPrefix("account-"), let separator = domain.range(of: "-drive-", options: .backwards),
      let drive = Int(domain[separator.upperBound...]) else { return }
    let account = String(domain[domain.index(domain.startIndex, offsetBy: 8)..<separator.lowerBound])
    let now = Date().timeIntervalSince1970 * 1000
    if error == nil, action == "Read", let index = entries.lastIndex(where: {
      $0.account == account && $0.drive == drive && $0.node == node && $0.name == name && $0.action == action && $0.source == source && $0.error == nil && now - $0.time < 2000
    }) {
      entries[index].time = now
      entries[index].bytes += bytes
      entries[index].milliseconds += milliseconds
      entries[index].count += 1
    } else {
      entries.append(GardenActivityEntry(id: UUID().uuidString, account: account, drive: drive, node: node, name: name,
        action: action, source: source, error: error, time: now, bytes: bytes, milliseconds: milliseconds, count: 1))
      if entries.count > 300 { entries.removeFirst(entries.count - 300) }
    }
    guard publication == nil else { return }
    publication = Task {
      do { try await Task.sleep(for: .milliseconds(200)) }
      catch { return }
      publish()
    }
  }

  func updates(account: String) -> AsyncThrowingStream<Data, Error> {
    let id = UUID()
    return AsyncThrowingStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
      observers[id] = (account, continuation)
      do { continuation.yield(try snapshot(account)) }
      catch { continuation.finish(throwing: error) }
      continuation.onTermination = { _ in Task { await self.remove(id) } }
    }
  }

  func clear(account: String) {
    publication?.cancel()
    publication = nil
    entries.removeAll { $0.account == account }
    publish()
  }

  private func remove(_ id: UUID) { observers.removeValue(forKey: id) }
  private func snapshot(_ account: String) throws -> Data {
    try JSONEncoder().encode(entries.filter { $0.account == account }.sorted { $0.time > $1.time })
  }
  private func publish() {
    publication = nil
    for (account, observer) in observers.values {
      do { observer.yield(try snapshot(account)) }
      catch { observer.finish(throwing: error) }
    }
  }
}

@objc protocol GardenActivityObserverProtocol {
  func activityFailed(_ message: String)
  func activityChanged(_ data: Data)
}
