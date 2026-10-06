import Foundation

actor GardenReadBuffer {
  static let shared = GardenReadBuffer()
  private let capacity: Int
  private var entries: [String: (Data, UInt64)] = [:]
  private var clock: UInt64 = 0
  private(set) var used = 0

  init(capacity: Int = 64 * 1024 * 1024) { self.capacity = capacity }

  func read(_ key: String) -> Data? {
    guard let entry = entries[key] else { return nil }
    clock &+= 1
    entries[key] = (entry.0, clock)
    return entry.0
  }

  func read(_ keys: [String]) -> [Data]? {
    var result: [Data] = []
    result.reserveCapacity(keys.count)
    for key in keys {
      guard let entry = entries[key] else { return nil }
      clock &+= 1
      entries[key] = (entry.0, clock)
      result.append(entry.0)
    }
    return result
  }

  func store(_ data: Data, key: String) {
    guard data.count <= capacity else { return }
    if let previous = entries.removeValue(forKey: key) { used -= previous.0.count }
    while used + data.count > capacity {
      guard let oldest = entries.min(by: { $0.value.1 < $1.value.1 }) else { return }
      used -= oldest.value.0.count
      entries.removeValue(forKey: oldest.key)
    }
    clock &+= 1
    entries[key] = (data, clock)
    used += data.count
  }

  func clear() { entries.removeAll(); used = 0 }
}
