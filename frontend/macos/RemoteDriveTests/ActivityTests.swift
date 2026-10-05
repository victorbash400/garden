import Foundation

@main struct ActivityTests {
  static func main() async throws {
    let activity = GardenActivity()
    let account = "11111111-1111-1111-1111-111111111111"
    let domain = "account-\(account)-drive-2"
    await activity.record(domain: domain, name: "Video.mp4", action: "Read", source: "Cloud", bytes: 1024)
    await activity.record(domain: domain, name: "Video.mp4", action: "Read", source: "Cloud", bytes: 2048)
    await activity.record(domain: "account-other-drive-2", name: "Private", action: "Open")
    var iterator = await activity.updates(account: account).makeAsyncIterator()
    let first = try JSONDecoder().decode([GardenActivityEntry].self, from: try await iterator.next()!)
    precondition(first.count == 1 && first[0].count == 2 && first[0].bytes == 3072)
    for index in 0..<350 { await activity.record(domain: domain, name: "File\(index)", action: "Open") }
    var bounded = await activity.updates(account: account).makeAsyncIterator()
    let entries = try JSONDecoder().decode([GardenActivityEntry].self, from: try await bounded.next()!)
    precondition(entries.count == 300)
    await activity.clear(account: account)
    var cleared = await activity.updates(account: account).makeAsyncIterator()
    let empty = try JSONDecoder().decode([GardenActivityEntry].self, from: try await cleared.next()!)
    precondition(empty.isEmpty)
    print("Activity grouping, isolation, capacity and clear passed.")
  }
}
