import Foundation
import FSKit

final class GardenStreamingItem: FSItem {
  let node: GardenNode?
  init(node: GardenNode? = nil) { self.node = node; super.init() }
  var id: Int { node?.id ?? 0 }
  var folder: Bool { node?.folder ?? true }
  var identifier: FSItem.Identifier { id == 0 ? .rootDirectory : FSItem.Identifier(UInt64(id) + 2) }

  func attributes() -> FSItem.Attributes {
    let result = FSItem.Attributes()
    result.type = folder ? .directory : .file
    result.mode = folder ? 0o555 : 0o444
    result.uid = getuid()
    result.gid = getgid()
    result.linkCount = 1
    result.size = UInt64(node?.size ?? 0)
    result.allocSize = 0
    result.fileID = identifier
    let parent = node?.parentID ?? 0
    result.parentID = parent == 0 ? .rootDirectory : FSItem.Identifier(UInt64(parent) + 2)
    let time = timespec(tv_sec: Int(node?.modifiedDate.timeIntervalSince1970 ?? 0), tv_nsec: 0)
    result.modifyTime = time
    result.changeTime = time
    result.birthTime = time
    result.accessTime = time
    return result
  }
}
