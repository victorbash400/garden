import FileProvider
import Foundation

final class GardenFileProvider: NSObject, NSFileProviderReplicatedExtension, NSFileProviderPartialContentFetching {
  private let domain: NSFileProviderDomain
  private let api: GardenAPI

  required init(domain: NSFileProviderDomain) {
    self.domain = domain
    self.api = GardenAPI(domainID: domain.identifier.rawValue)
    super.init()
  }

  func invalidate() {}

  func item(
    for identifier: NSFileProviderItemIdentifier,
    request: NSFileProviderRequest,
    completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void
  ) -> Progress {
    let progress = Progress(totalUnitCount: 1)
    Task {
      do {
        let item: GardenItem
        if identifier == .rootContainer {
          item = GardenItem(driveName: domain.displayName)
        } else {
          item = GardenItem(node: try await api.get(nodeID(identifier)))
        }
        completionHandler(item, nil)
      } catch { completionHandler(nil, error) }
      progress.completedUnitCount = 1
    }
    return progress
  }

  func fetchContents(
    for itemIdentifier: NSFileProviderItemIdentifier,
    version requestedVersion: NSFileProviderItemVersion?,
    request: NSFileProviderRequest,
    completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void
  ) -> Progress {
    let progress = Progress(totalUnitCount: 1)
    Task {
      do {
        let node = try await api.get(nodeID(itemIdentifier))
        guard !node.folder else { throw GardenAPIError.invalidResponse }
        if let requestedVersion,
           requestedVersion.contentVersion != Data(String(node.version).utf8) {
          throw NSFileProviderError(.versionNoLongerAvailable)
        }
        let url = try temporaryFile()
        try await writeRange(node: node, start: 0, end: node.size, to: url)
        completionHandler(url, GardenItem(node: node), nil)
      } catch { completionHandler(nil, nil, error) }
      progress.completedUnitCount = 1
    }
    return progress
  }

  func fetchPartialContents(
    for itemIdentifier: NSFileProviderItemIdentifier,
    version requestedVersion: NSFileProviderItemVersion,
    request: NSFileProviderRequest,
    minimalRange: NSRange,
    aligningTo alignment: Int,
    options: NSFileProviderFetchContentsOptions,
    completionHandler: @escaping (URL?, NSFileProviderItem?, NSRange, NSFileProviderMaterializationFlags, Error?) -> Void
  ) -> Progress {
    let progress = Progress(totalUnitCount: 1)
    Task {
      do {
        let node = try await api.get(nodeID(itemIdentifier))
        guard !node.folder else { throw GardenAPIError.invalidResponse }
        if requestedVersion.contentVersion != Data(String(node.version).utf8) {
          throw NSFileProviderError(.versionNoLongerAvailable)
        }
        let unit = max(alignment, 1)
        let start = (minimalRange.location / unit) * unit
        let end = min(node.size, ((NSMaxRange(minimalRange) + unit - 1) / unit) * unit)
        let url = try temporaryFile()
        try await writeRange(node: node, start: start, end: end, to: url)
        completionHandler(
          url, GardenItem(node: node), NSRange(location: start, length: end - start), [], nil
        )
      } catch { completionHandler(nil, nil, NSRange(location: 0, length: 0), [], error) }
      progress.completedUnitCount = 1
    }
    return progress
  }

  func createItem(
    basedOn itemTemplate: NSFileProviderItem,
    fields: NSFileProviderItemFields,
    contents url: URL?,
    options: NSFileProviderCreateItemOptions = [],
    request: NSFileProviderRequest,
    completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void
  ) -> Progress {
    let progress = Progress(totalUnitCount: 1)
    Task {
      do {
        let parent = try parentID(itemTemplate.parentItemIdentifier)
        guard let contentType = itemTemplate.contentType else {
          throw GardenAPIError.invalidResponse
        }
        let folder = contentType.conforms(to: .folder)
        let created = try await api.create(parentID: parent, name: itemTemplate.filename, folder: folder)
        do {
          let saved = if let url, !folder {
            try await api.upload(id: created.id, baseVersion: 0, fileURL: url)
          } else {
            created
          }
          completionHandler(GardenItem(node: saved), [], false, nil)
        } catch {
          let uploadError = error
          do {
            try await api.delete(created.id)
          } catch {
            throw GardenAPIError.cleanup(
              "Upload failed and the empty file could not be removed: \(error.localizedDescription)"
            )
          }
          throw uploadError
        }
      } catch { completionHandler(nil, [], false, error) }
      progress.completedUnitCount = 1
    }
    return progress
  }

  func modifyItem(
    _ item: NSFileProviderItem,
    baseVersion version: NSFileProviderItemVersion,
    changedFields: NSFileProviderItemFields,
    contents newContents: URL?,
    options: NSFileProviderModifyItemOptions = [],
    request: NSFileProviderRequest,
    completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void
  ) -> Progress {
    let progress = Progress(totalUnitCount: 1)
    Task {
      do {
        let originalID = try nodeID(item.itemIdentifier)
        var node = try await api.get(originalID)
        if let newContents {
          guard let baseVersion = Int(String(data: version.contentVersion, encoding: .utf8) ?? "") else {
            throw GardenAPIError.invalidResponse
          }
          node = try await api.upload(
            id: node.id,
            baseVersion: baseVersion,
            fileURL: newContents
          )
          if node.id != originalID {
            completionHandler(GardenItem(node: node), [], false, nil)
            progress.completedUnitCount = 1
            return
          }
        }
        let parent = try parentID(item.parentItemIdentifier)
        if node.name != item.filename || node.parentID != parent {
          node = try await api.move(id: node.id, parentID: parent, name: item.filename)
        }
        completionHandler(GardenItem(node: node), [], false, nil)
      } catch { completionHandler(nil, [], false, error) }
      progress.completedUnitCount = 1
    }
    return progress
  }

  func deleteItem(
    identifier: NSFileProviderItemIdentifier,
    baseVersion version: NSFileProviderItemVersion,
    options: NSFileProviderDeleteItemOptions = [],
    request: NSFileProviderRequest,
    completionHandler: @escaping (Error?) -> Void
  ) -> Progress {
    let progress = Progress(totalUnitCount: 1)
    Task {
      do {
        try await api.delete(nodeID(identifier))
        completionHandler(nil)
      } catch { completionHandler(error) }
      progress.completedUnitCount = 1
    }
    return progress
  }

  func enumerator(
    for containerItemIdentifier: NSFileProviderItemIdentifier,
    request: NSFileProviderRequest
  ) throws -> NSFileProviderEnumerator {
    GardenEnumerator(container: containerItemIdentifier, api: api)
  }

  private func nodeID(_ identifier: NSFileProviderItemIdentifier) throws -> Int {
    guard let id = Int(identifier.rawValue), id > 0 else {
      throw GardenAPIError.invalidResponse
    }
    return id
  }

  private func parentID(_ identifier: NSFileProviderItemIdentifier) throws -> Int {
    identifier == .rootContainer ? 0 : try nodeID(identifier)
  }

  private func temporaryFile() throws -> URL {
    guard let manager = NSFileProviderManager(for: domain) else {
      throw GardenAPIError.invalidResponse
    }
    return try manager.temporaryDirectoryURL().appendingPathComponent(UUID().uuidString)
  }

  private func writeRange(node: GardenNode, start: Int, end: Int, to url: URL) async throws {
    guard start >= 0, end >= start, end <= node.size else {
      throw GardenAPIError.invalidResponse
    }
    FileManager.default.createFile(atPath: url.path, contents: nil)
    let handle = try FileHandle(forWritingTo: url)
    defer { try? handle.close() }
    try handle.truncate(atOffset: UInt64(node.size))
    try handle.seek(toOffset: UInt64(start))
    var offset = start
    while offset < end {
      let bytes = try await api.read(
        id: node.id, version: node.version, offset: offset,
        length: min(256 * 1024, end - offset)
      )
      guard !bytes.isEmpty else { throw GardenAPIError.invalidResponse }
      try handle.write(contentsOf: bytes)
      offset += bytes.count
    }
  }
}
