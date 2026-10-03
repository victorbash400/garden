import Foundation
import FSKit

extension GardenStreamingVolume {
  func write(contents: Data, to item: FSItem, at offset: off_t) async throws -> FSWriteFileResult { throw POSIXError(.EROFS) }
  func setAttributes(_ request: FSItem.SetAttributesRequest, on item: FSItem, context: FSContext) async throws -> FSSetAttributesResult { throw POSIXError(.EROFS) }
  func createItem(named name: FSFileName, type: FSItem.ItemType, in directory: FSItem, attributes: FSItem.SetAttributesRequest, context: FSContext) async throws -> FSCreateItemResult { throw POSIXError(.EROFS) }
  func createSymbolicLink(named name: FSFileName, in directory: FSItem, attributes: FSItem.SetAttributesRequest, linkContents: FSFileName, context: FSContext) async throws -> FSCreateSymlinkResult { throw POSIXError(.EROFS) }
  func createLink(to item: FSItem, named name: FSFileName, in directory: FSItem, context: FSContext) async throws -> FSCreateLinkResult { throw POSIXError(.EROFS) }
  func renameItem(_ item: FSItem, inDirectory source: FSItem, named name: FSFileName, to destinationName: FSFileName, inDirectory destination: FSItem, overItem: FSItem?, context: FSContext) async throws -> FSRenameItemResult { throw POSIXError(.EROFS) }
  func removeItem(_ item: FSItem, named name: FSFileName, from directory: FSItem, context: FSContext) async throws -> FSRemoveItemResult { throw POSIXError(.EROFS) }
  func readSymbolicLink(_ item: FSItem, context: FSContext) async throws -> FSReadSymlinkResult { throw POSIXError(.ENOTSUP) }
}
