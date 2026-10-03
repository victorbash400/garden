import Foundation
import FSKit

final class GardenStreamingVolume: FSVolume, FSVolume.Handler, FSVolume.ReadWriteHandler, FSVolume.OpenCloseHandler {
  let index: GardenStreamingIndex
  let ranges: GardenRangeCache
  let root = GardenStreamingItem()
  let maximumLinkCount = 1
  let maximumNameLength = 255
  let restrictsOwnershipChanges = true
  let truncatesLongNames = false
  let maximumXattrSize = 0
  let maximumFileSize: UInt64 = 1 << 40
  var volumeStatistics: FSStatFSResult { FSStatFSResult(fileSystemTypeName: "gardenfs") }
  var supportedVolumeCapabilities: FSVolume.SupportedCapabilities {
    let result = FSVolume.SupportedCapabilities()
    result.supports64BitObjectIDs = true
    result.supportsPersistentObjectIDs = true
    result.doesNotSupportSettingFilePermissions = true
    result.doesNotSupportVolumeSizes = true
    result.caseFormat = .insensitive
    return result
  }

  init(domainID: String) throws {
    guard let uuid = UUID(uuidString: try FinderCredentialStore.read(domainID).accountID) else { throw POSIXError(.EINVAL) }
    let api = GardenAPI(domainID: domainID)
    index = GardenStreamingIndex(api: api)
    ranges = GardenRangeCache(api: api, domainID: domainID)
    guard let identifier = FSVolume.Identifier(uuid: uuid, qualifierData: Data(domainID.utf8)) else { throw POSIXError(.EINVAL) }
    super.init(volumeID: identifier, volumeName: FSFileName(string: "Garden"))
  }

  func activateVolume(options: FSTaskOptions) async throws -> FSActivateResult {
    guard let result = FSActivateResult(rootItem: root) else { throw POSIXError(.EIO) }
    return result
  }
  func deactivateVolume(options: FSDeactivateOptions) async throws { await ranges.invalidate() }
  func mount(options: FSTaskOptions) async throws {}
  func unmount() async {}
  func synchronize(flags: FSSyncFlags) async throws {}
  func reclaimItem(_ item: FSItem) async throws {}

  func lookupItem(named name: FSFileName, in directory: FSItem, context: FSContext) async throws -> FSLookupItemResult {
    guard let directory = directory as? GardenStreamingItem, directory.folder,
      let text = name.string else { throw POSIXError(.EINVAL) }
    if text == "." || text == ".." {
      let parentID = directory.node?.parentID ?? 0
      let item = text == "." ? directory : (parentID == 0 ? root : GardenStreamingItem(node: try await index.api.get(parentID)))
      guard let result = FSLookupItemResult(foundItem: item, itemName: name, itemAttributes: item.attributes()) else { throw POSIXError(.EIO) }
      return result
    }
    let items = try await index.children(directory.id)
    guard let item = items.first(where: { $0.node?.name.lowercased() == text.lowercased() }), let node = item.node else { throw POSIXError(.ENOENT) }
    guard let result = FSLookupItemResult(foundItem: item, itemName: FSFileName(string: node.name), itemAttributes: item.attributes()) else { throw POSIXError(.EIO) }
    return result
  }

  func attributes(_ request: FSItem.GetAttributesRequest, of item: FSItem, context: FSContext) async throws -> FSGetAttributesResult {
    guard let item = item as? GardenStreamingItem else { throw POSIXError(.EINVAL) }
    guard let result = FSGetAttributesResult(attributes: item.attributes()) else { throw POSIXError(.EIO) }
    return result
  }

  func enumerateDirectory(_ directory: FSItem, startingAt cookie: FSDirectoryCookie,
    verifier: FSDirectoryVerifier, attributes: FSItem.GetAttributesRequest?, packer: FSDirectoryEntryPacker, context: FSContext) async throws -> FSEnumerateDirectoryResult {
    guard let directory = directory as? GardenStreamingItem else { throw POSIXError(.EINVAL) }
    guard directory.folder else { throw POSIXError(.ENOTDIR) }
    var entries = try await index.children(directory.id).map { ($0.node!.name, $0) }
    if attributes == nil {
      let parentID = directory.node?.parentID ?? 0
      let parent = parentID == 0 ? root : GardenStreamingItem(node: try await index.api.get(parentID))
      entries.insert(("..", parent), at: 0)
      entries.insert((".", directory), at: 0)
    }
    let start = Int(cookie.rawValue)
    guard start <= entries.count else { throw POSIXError(.EINVAL) }
    for position in start..<entries.count {
      let (name, item) = entries[position]
      if !packer.packEntry(name: FSFileName(string: name), itemType: item.folder ? .directory : .file,
        itemID: item.identifier, nextCookie: FSDirectoryCookie(UInt64(position + 1)), attributes: attributes == nil ? nil : item.attributes()) { break }
    }
    guard let result = FSEnumerateDirectoryResult(verifier: 1) else { throw POSIXError(.EIO) }
    return result
  }

  func read(from item: FSItem, at offset: off_t, length: Int, into buffer: FSMutableFileDataBuffer) async throws -> FSReadFileResult {
    guard let item = item as? GardenStreamingItem, let node = item.node, !node.folder, offset >= 0, length >= 0 else { throw POSIXError(.EINVAL) }
    var copied = 0
    let wanted = offset >= node.size ? 0 : min(length, buffer.length, node.size - Int(offset))
    while copied < wanted {
      let data = try await ranges.read(node: node, offset: Int(offset) + copied,
        length: min(GardenRangeCache.blockSize, wanted - copied))
      _ = buffer.withUnsafeMutableBytes { target in
        data.copyBytes(to: UnsafeMutableRawBufferPointer(rebasing: target[copied..<(copied + data.count)]))
      }
      copied += data.count
    }
    guard let result = FSReadFileResult(bytesRead: copied, itemAttributes: item.attributes()) else { throw POSIXError(.EIO) }
    return result
  }

  func openItem(_ item: FSItem, modes: FSVolume.OpenModes, context: FSContext) async throws {
    if modes.contains(.write) { throw POSIXError(.EROFS) }
  }
  func closeItem(_ item: FSItem, modes: FSVolume.OpenModes, context: FSContext) async throws {}
}
