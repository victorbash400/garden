import Foundation

enum RemotePlatform {
  static func requireModule() throws {
    // FSClient filters modules by signing team. macFUSE's signed helper checks approval at mount time.
    let module = "/Library/Filesystems/macfuse.fs/Contents/Resources/macfuse.app/Contents/Extensions/io.macfuse.app.fsmodule.macfuse-local.appex"
    guard FileManager.default.fileExists(atPath: module) else {
      throw NSError(domain: "GardenRemote", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Install macFUSE to mount streaming drives."])
    }
  }
}
