import Foundation

actor GardenStreamingIndex {
  let api: GardenAPI
  private var directories: [Int: [GardenStreamingItem]] = [:]
  init(api: GardenAPI) { self.api = api }

  func children(_ parent: Int) async throws -> [GardenStreamingItem] {
    if let items = directories[parent] { return items }
    var nodes: [GardenNode] = []
    var after = 0
    while true {
      let page = try await api.list(parentID: parent, after: after)
      nodes.append(contentsOf: page)
      if page.count < 256 { break }
      guard let next = page.last?.id, next > after else { throw GardenAPIError.invalidResponse }
      after = next
    }
    let items = nodes.map { GardenStreamingItem(node: $0) }
    directories[parent] = items
    return items
  }
}
