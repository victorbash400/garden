import AppKit
import FlutterMacOS

@MainActor final class GardenFileMenu: NSObject {
  private var selected: String?

  static func install(on messenger: FlutterBinaryMessenger, view: NSView) {
    FlutterMethodChannel(name: "garden/file-menu", binaryMessenger: messenger)
      .setMethodCallHandler { [weak view] call, result in
        Task { @MainActor in
          guard call.method == "show", let args = call.arguments as? [String: Any],
            let entries = args["entries"] as? [[String: Any]], let view,
            let x = args["x"] as? Double, let y = args["y"] as? Double else {
            result(FlutterError(code: "menu_arguments", message: "The file menu could not be opened.", details: nil))
            return
          }
          let target = GardenFileMenu()
          let menu = NSMenu()
          menu.autoenablesItems = false
          menu.font = .systemFont(ofSize: 13)
          for entry in entries {
            if entry["separator"] as? Bool == true { menu.addItem(.separator()); continue }
            guard let title = entry["title"] as? String, let value = entry["value"] as? String else { continue }
            let item = target.item(title, value: value)
            item.isEnabled = entry["enabled"] as? Bool ?? true
            if value == "openWith", let filename = args["filename"] as? String {
              let submenu = NSMenu()
              submenu.autoenablesItems = false
              for url in GardenFileApplications.candidates(filename) {
                guard let identifier = Bundle(url: url)?.bundleIdentifier else { continue }
                let app = target.item(FileManager.default.displayName(atPath: url.path), value: "openWith:" + identifier)
                app.image = NSWorkspace.shared.icon(forFile: url.path)
                app.image?.size = NSSize(width: 16, height: 16)
                submenu.addItem(app)
              }
              if !submenu.items.isEmpty { submenu.addItem(.separator()) }
              submenu.addItem(target.item("Other…", value: "openWith:other"))
              item.submenu = submenu
            }
            menu.addItem(item)
          }
          view.window?.makeKeyAndOrderFront(nil)
          NSApp.activate(ignoringOtherApps: true)
          let point = NSPoint(x: x, y: view.isFlipped ? y : view.bounds.height - y)
          menu.popUp(positioning: nil, at: point, in: view)
          result(target.selected)
        }
      }
  }

  private func item(_ title: String, value: String) -> NSMenuItem {
    let item = NSMenuItem(title: title, action: #selector(choose(_:)), keyEquivalent: "")
    item.target = self
    item.representedObject = value
    return item
  }

  @objc private func choose(_ item: NSMenuItem) { selected = item.representedObject as? String }
}
