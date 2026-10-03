import FileProvider
import Foundation

final class GardenEnumerator: NSObject, NSFileProviderEnumerator {
  private let container: NSFileProviderItemIdentifier
  private let api: GardenAPI

  init(container: NSFileProviderItemIdentifier, api: GardenAPI) {
    self.container = container
    self.api = api
    super.init()
  }

  func invalidate() {}

  func enumerateItems(
    for observer: NSFileProviderEnumerationObserver,
    startingAt page: NSFileProviderPage
  ) {
    Task {
      do {
        if container == .trashContainer {
          observer.finishEnumerating(upTo: nil)
          return
        }
        if container == .workingSet {
          let cursor = Int(String(data: page.rawValue, encoding: .utf8) ?? "") ?? 0
          let nodes = try await api.snapshot(after: cursor)
          observer.didEnumerate(nodes.map(GardenItem.init))
          let next: NSFileProviderPage? = nodes.count == 256
            ? NSFileProviderPage(Data(String(nodes.last!.id).utf8)) : nil
          observer.finishEnumerating(upTo: next)
          return
        }
        let parentID = container == .rootContainer ? 0 : try nodeID(container)
        let cursor = Int(String(data: page.rawValue, encoding: .utf8) ?? "") ?? 0
        let nodes = try await api.list(parentID: parentID, after: cursor)
        observer.didEnumerate(nodes.map(GardenItem.init))
        let next: NSFileProviderPage? = nodes.count == 256
          ? NSFileProviderPage(Data(String(nodes.last!.id).utf8)) : nil
        observer.finishEnumerating(upTo: next)
      } catch {
        observer.finishEnumeratingWithError(GardenProviderError.wrap(error))
      }
    }
  }

  func enumerateChanges(
    for observer: NSFileProviderChangeObserver,
    from anchor: NSFileProviderSyncAnchor
  ) {
    Task {
      do {
        guard let revision = Int(String(data: anchor.rawValue, encoding: .utf8) ?? "") else {
          throw GardenAPIError.invalidResponse
        }
        if container == .trashContainer {
          observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
          return
        }
        let events = try await api.changes(after: revision)
        var updates: [NSFileProviderItem] = []
        var deletions: [NSFileProviderItemIdentifier] = []
        let parentID = container == .rootContainer ? 0 : Int(container.rawValue)
        for event in events {
          guard let node = event.node else { continue }
          let identifier = NSFileProviderItemIdentifier(String(node.id))
          if container == .workingSet {
            if node.deleted { deletions.append(identifier) }
            else { updates.append(GardenItem(node: node)) }
          } else if node.deleted && node.parentID == parentID {
            deletions.append(identifier)
          } else if event.previousParentID == parentID && node.parentID != parentID {
            deletions.append(identifier)
          } else if !node.deleted && node.parentID == parentID {
            updates.append(GardenItem(node: node))
          }
        }
        if !updates.isEmpty { observer.didUpdate(updates) }
        if !deletions.isEmpty { observer.didDeleteItems(withIdentifiers: deletions) }
        let latest = events.last?.revision ?? revision
        observer.finishEnumeratingChanges(
          upTo: NSFileProviderSyncAnchor(Data(String(latest).utf8)),
          moreComing: events.count == 256
        )
      } catch {
        observer.finishEnumeratingWithError(GardenProviderError.wrap(error))
      }
    }
  }

  func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
    Task {
      let revision = try? await api.revision()
      completionHandler(revision.map { NSFileProviderSyncAnchor(Data(String($0).utf8)) })
    }
  }

  private func nodeID(_ identifier: NSFileProviderItemIdentifier) throws -> Int {
    guard let id = Int(identifier.rawValue), id > 0 else {
      throw GardenAPIError.invalidResponse
    }
    return id
  }
}
