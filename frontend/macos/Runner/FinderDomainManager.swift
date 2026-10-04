import AppKit
import FileProvider
import Foundation

// Retire only Garden's previous File Provider domains after the replacement volumes mount.
enum FinderDomainManager {
  static func retire(accountID: String) async throws {
    guard UUID(uuidString: accountID)?.uuidString.lowercased() == accountID else { throw POSIXError(.EINVAL) }
    let prefix = "account-\(accountID)-drive-"
    let domains = try await NSFileProviderManager.domains()
    var preservedFiles: [URL] = []
    for domain in domains where domain.identifier.rawValue.hasPrefix(prefix) {
      let preserved = try await NSFileProviderManager.remove(domain, mode: .preserveDirtyUserData)
      if let preserved {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
          .appendingPathComponent("GardenRemote")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true,
          attributes: [.posixPermissions: 0o700])
        let receipt = root.appendingPathComponent("preserved-files.json")
        var paths = FileManager.default.fileExists(atPath: receipt.path)
          ? try JSONDecoder().decode([String].self, from: Data(contentsOf: receipt)) : []
        paths.append(preserved.path)
        try JSONEncoder().encode(Array(Set(paths)).sorted()).write(to: receipt, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: receipt.path)
        preservedFiles.append(preserved)
      }
    }
    if !preservedFiles.isEmpty {
      let locations = preservedFiles
      await MainActor.run { NSWorkspace.shared.activateFileViewerSelecting(locations) }
    }
  }
}
