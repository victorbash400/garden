import AppKit
import UniformTypeIdentifiers

@MainActor enum GardenFileApplications {
  static func candidates(_ filename: String) -> [URL] {
    let suffix = (filename as NSString).pathExtension
    guard let type = UTType(filenameExtension: suffix) else { return [] }
    if #available(macOS 12.0, *) { return NSWorkspace.shared.urlsForApplications(toOpen: type) }
    return []
  }

  static func resolve(_ identifier: String?) throws -> URL? {
    guard let identifier else { return nil }
    if identifier == "other" {
      let picker = NSOpenPanel()
      picker.allowedContentTypes = [.applicationBundle]
      picker.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
      picker.canChooseDirectories = false
      picker.allowsMultipleSelection = false
      picker.prompt = "Open"
      guard picker.runModal() == .OK, let selected = picker.url else { throw CancellationError() }
      return selected
    }
    guard let application = NSWorkspace.shared.urlForApplication(withBundleIdentifier: identifier) else {
      throw NSError(domain: "GardenOpen", code: 1, userInfo: [NSLocalizedDescriptionKey:
        "The selected application is no longer installed. Choose another application."])
    }
    return application
  }
}
