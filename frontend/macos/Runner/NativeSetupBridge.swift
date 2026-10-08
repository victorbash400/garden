import Cocoa
import FlutterMacOS
import ServiceManagement

enum NativeSetupBridge {
  private static var backgroundActivity: NSObjectProtocol?
  private static var wakeObservers: [NSObjectProtocol] = []

  static func install(on messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "garden/setup", binaryMessenger: messenger)
    let observer = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
    ) { _ in channel.invokeMethod("wake", arguments: nil) }
    wakeObservers.append(observer)
    channel.setMethodCallHandler { call, result in
      do {
        switch call.method {
        case "status":
          result(status())
        case "setLaunchAtLogin":
          guard let enabled = call.arguments as? Bool else {
            throw FinderBridgeError.invalidArguments
          }
          try setLaunchAtLogin(enabled)
          result(status())
        case "openLoginSettings":
          try openLoginSettings()
          result(nil)
        case "openHelp":
          let links = [
            "approval": "https://support.apple.com/102445",
            "macFuse": "https://macfuse.github.io/"
          ]
          guard let name = call.arguments as? String,
            let address = links[name], let url = URL(string: address),
            NSWorkspace.shared.open(url) else {
            throw NSError(domain: "GardenSetup", code: 2,
              userInfo: [NSLocalizedDescriptionKey: "Could not open the setup instructions."])
          }
          result(nil)
        case "setBackgroundActive":
          guard let active = call.arguments as? Bool else {
            throw FinderBridgeError.invalidArguments
          }
          setBackgroundActive(active)
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      } catch {
        result(FlutterError(code: "setup_error", message: error.localizedDescription, details: nil))
      }
    }
  }

  static func status() -> [String: Any] {
    let helper = Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/GardenRemote.app")
    let available = Bundle(url: helper)?.bundleIdentifier == "com.victorbash.garden.remote"
      && FileManager.default.fileExists(atPath: "/Library/Filesystems/macfuse.fs")
    var login = "unsupported"
    if #available(macOS 13.0, *) {
      switch SMAppService.mainApp.status {
      case .enabled: login = "enabled"
      case .notRegistered: login = "disabled"
      case .requiresApproval: login = "requiresApproval"
      case .notFound: login = "notFound"
      @unknown default: login = "unknown"
      }
    }
    return ["finderAvailable": available, "launchAtLogin": login]
  }

  static func openLoginSettings() throws {
    guard #available(macOS 13.0, *) else {
      throw NSError(domain: "GardenSetup", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Login item controls require macOS 13 or later."])
    }
    SMAppService.openSystemSettingsLoginItems()
  }

  private static func setLaunchAtLogin(_ enabled: Bool) throws {
    guard #available(macOS 13.0, *) else {
      throw NSError(domain: "GardenSetup", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Launch at login requires macOS 13 or later."])
    }
    let service = SMAppService.mainApp
    if enabled && service.status != .enabled && service.status != .requiresApproval {
      do {
        try service.register()
      } catch {
        // Registration can require approval even when macOS returns an error.
        guard service.status == .requiresApproval else { throw error }
      }
    } else if !enabled && service.status != .notRegistered {
      try service.unregister()
    }
  }

  private static func setBackgroundActive(_ active: Bool) {
    if active && backgroundActivity == nil {
      backgroundActivity = ProcessInfo.processInfo.beginActivity(
        options: .userInitiatedAllowingIdleSystemSleep,
        reason: "Synchronize Garden drives")
    } else if !active, let activity = backgroundActivity {
      ProcessInfo.processInfo.endActivity(activity)
      backgroundActivity = nil
    }
  }
}
