import Darwin
import Foundation

@main struct FileStatTests {
  static func node(size: Int, folder: Bool = false) throws -> GardenNode {
    try GardenNode(["id": 1, "parentId": 0, "name": "media.wav",
      "kind": folder ? "folder" : "file", "size": size, "version": 1,
      "updatedAt": "2026-10-06T10:00:00.000Z", "deleted": false])
  }

  static func require(_ condition: Bool) throws {
    guard condition else { throw POSIXError(.EINVAL) }
  }

  static func main() throws {
    for (size, blocks) in [(0, 0), (1, 1), (511, 1), (512, 1), (513, 2),
      (1_347_884, 2633), (5_000_000_000, 9_765_625), (Int.max, Int.max / 512 + 1)] {
      let attributes = try fileStat(node(size: size))
      try require(attributes.st_size == size && attributes.st_blocks == blocks)
      try require(attributes.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG))
    }
    try require(fileStat(nil).st_blocks == 0)
    try require(fileStat(node(size: 0, folder: true)).st_blocks == 0)
    do {
      _ = try fileStat(node(size: -1))
      throw POSIXError(.EIO)
    } catch let error as POSIXError {
      try require(error.code == .EINVAL)
    }
    print("File allocation metadata passed for empty, partial, large and invalid sizes")
  }
}
