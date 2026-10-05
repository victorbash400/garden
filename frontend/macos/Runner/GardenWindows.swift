import Cocoa
@preconcurrency import FlutterMacOS

@MainActor enum GardenWindows {
  private static var windows: [String: NSWindow] = [:]
  private static var channels: [String: FlutterMethodChannel] = [:]
  private static var observers: [NSObjectProtocol] = []
  private static let accounts = WindowAccounts()
  private static let savedKey = "garden.accountWindows"

  private static var restored: [String: [String: Any]] = [:]
  private static var sessions: [String: Any] = {
    let arguments = ProcessInfo.processInfo.arguments
    do {
      let payload = try GardenSessionHandoff.consume(arguments: arguments)
      GardenRelaunchReceipt.acknowledge(arguments: arguments, accepted: true)
      return payload
    } catch {
      GardenRelaunchReceipt.acknowledge(arguments: arguments, accepted: false)
      return ["error": "Could not restore the account sessions. Sign in again."]
    }
  }()
  private static let relaunchKey = "garden.relaunchWindows"

  static func attach(_ window: NSWindow, controller: FlutterViewController, slot: String) {
    windows[slot] = window
    let messenger = controller.engine.binaryMessenger
    RegisterGeneratedPlugins(registry: controller)
    GardenActivityBridge.install(on: messenger)
    GardenBandwidthBridge.install(on: messenger)
    GardenCacheBridge.install(on: messenger)
    NativeSetupBridge.install(on: messenger)
    GardenFinderBridge.install(on: messenger)
    FlutterMethodChannel(name: "garden/native_auth", binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        result(call.method == "configured" ? nativeAuthenticationConfigured() : FlutterMethodNotImplemented)
      }
    let channel = FlutterMethodChannel(name: "garden/window", binaryMessenger: messenger)
    channels[slot] = channel
    channel.setMethodCallHandler { [weak window] call, result in
      guard let window else {
        result(FlutterError(code: "window", message: "Account window is closed.", details: nil)); return
      }
      switch call.method {
      case "initialize": result(["id": slot, "active": window.isMainWindow, "windows": list(), "build": GardenBuildUpdates.state, "session": sessions.removeValue(forKey: slot) ?? NSNull(), "sessionError": sessions["error"] ?? NSNull()])
      case "ready":
        if let state = restored.removeValue(forKey: slot), let frame = state["frame"] as? String {
          window.setFrame(NSRectFromString(frame), display: true)
          if state["visible"] as? Bool == false { window.orderOut(nil) }
        }
        result(nil)
      case "relaunch":
        Task {
          await GardenBuildUpdates.relaunch(beforeLaunch: {
            let state = windows.mapValues { window in
              ["frame": NSStringFromRect(window.frame), "visible": window.isVisible] as [String: Any]
            }
            UserDefaults.standard.set(state, forKey: relaunchKey)
          }, failed: { UserDefaults.standard.removeObject(forKey: relaunchKey) })
        }
        result(nil)
      case "new":
        if let hidden = windows.first(where: { $0.key != "main" && !$0.value.isVisible && !accounts.contains($0.key) }) {
          hidden.value.makeKeyAndOrderFront(nil)
        } else { open(slot: UUID().uuidString) }
        result(nil)
      case "show":
        guard let id = call.arguments as? String, let target = windows[id] else {
          result(FlutterError(code: "window", message: "Account window is unavailable.", details: nil)); return
        }
        target.makeKeyAndOrderFront(nil); result(nil)
      case "account":
        guard let value = call.arguments as? [String: String],
              let id = value["id"], let email = value["email"] else {
          result(FlutterError(code: "window", message: "Missing account.", details: nil)); return
        }
        accounts.set(id, window: slot)
        window.title = "Garden — \(email)"
        var saved = UserDefaults.standard.stringArray(forKey: savedKey) ?? []
        if !saved.contains(slot) { saved.append(slot); UserDefaults.standard.set(saved, forKey: savedKey) }
        publish(); result(nil)
      case "release":
        window.title = "Garden"
        let saved = UserDefaults.standard.stringArray(forKey: savedKey) ?? []
        UserDefaults.standard.set(saved.filter { $0 != slot }, forKey: savedKey)
        let last = accounts.release(slot)
        publish(); result(last)
      default: result(FlutterMethodNotImplemented)
      }
    }
    for notification in [NSWindow.didBecomeMainNotification, NSWindow.didResignMainNotification] {
      observers.append(NotificationCenter.default.addObserver(
        forName: notification, object: window, queue: .main
      ) { _ in channel.invokeMethod("active", arguments: window.isMainWindow) })
    }
    GardenBuildUpdates.install(channel, slot: slot)
    publish()
  }

  private static func list() -> [[String: String]] {
    windows.sorted { $0.key < $1.key }.map { ["id": $0.key, "title": $0.value.title] }
  }

  private static func publish() {
    let value = list()
    for channel in channels.values { channel.invokeMethod("windows", arguments: value) }
  }

  static func restore() {
    _ = sessions
    let snapshot = UserDefaults.standard.dictionary(forKey: relaunchKey) as? [String: [String: Any]]
    restored = snapshot ?? [:]
    UserDefaults.standard.removeObject(forKey: relaunchKey)
    let slots = snapshot.map { Array($0.keys) } ?? (UserDefaults.standard.stringArray(forKey: savedKey) ?? [])
    for slot in slots where slot != "main" {
      open(slot: slot)
    }
  }

  static func reopen() {
    if let window = windows.values.first { window.makeKeyAndOrderFront(nil) }
    else { open(slot: "main") }
  }

  private static func open(slot: String) {
    if let existing = windows[slot] { existing.makeKeyAndOrderFront(nil); return }
    let project = FlutterDartProject()
    let controller = FlutterViewController(project: project)
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1100, height: 740),
      styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    window.title = "Garden"
    window.appearance = NSAppearance(named: .aqua)
    window.minSize = NSSize(width: 900, height: 640)
    window.contentViewController = controller
    attach(window, controller: controller, slot: slot)
    window.center()
    window.makeKeyAndOrderFront(nil)
  }
}
