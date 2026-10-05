import Cocoa
import FlutterMacOS

enum FinderBridgeError: LocalizedError {
  case invalidArguments
  case domainMissing
  case cannotOpen
  case cannotOpenSettings

  var errorDescription: String? {
    switch self {
    case .invalidArguments: "Garden Finder received invalid arguments."
    case .domainMissing: "Garden Finder drive is not registered."
    case .cannotOpen: "Finder could not open this drive."
    case .cannotOpenSettings: "System Settings could not open."
    }
  }
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
#if DEBUG
    if CommandLine.arguments.contains("--unregister-remote-service") {
      Task { @MainActor in
        do {
          try await GardenRemoteBridge.unregisterService()
          FileHandle.standardOutput.write(Data("Garden background service unregistered.\n".utf8))
          exit(0)
        } catch {
          FileHandle.standardError.write(Data("Garden background service: \(error.localizedDescription)\n".utf8))
          exit(1)
        }
      }
      super.awakeFromNib()
      return
    }
    if CommandLine.arguments.contains("--check-remote-service") {
      Task { @MainActor in
        do {
          let arguments = CommandLine.arguments
          guard arguments.count == 4, let driveID = Int(arguments[3]) else {
            throw FinderBridgeError.invalidArguments
          }
          let request = GardenRemoteRequest(accountID: arguments[2], driveIDs: [driveID], driveID: driveID)
          guard let path = try await GardenRemoteBridge.request("location", request) as? String,
                let status = try await GardenRemoteBridge.request("status", request) as? [String: [Int]],
                status["enabled"] == [driveID],
                path == "/Volumes/Garden-\(arguments[2])-\(driveID)" else {
            throw GardenAPIError.invalidResponse
          }
          FileHandle.standardOutput.write(Data("Signed Garden control verified: \(path)\n".utf8))
          exit(0)
        } catch {
          FileHandle.standardError.write(Data("Garden background service: \(error.localizedDescription)\n".utf8))
          exit(1)
        }
      }
      super.awakeFromNib()
      return
    }
    if CommandLine.arguments.contains("--register-remote-service") {
      do {
        try GardenRemoteBridge.registerService()
        FileHandle.standardOutput.write(Data("Garden background service registered.\n".utf8))
        exit(0)
      } catch {
        FileHandle.standardError.write(Data("Garden background service: \(error.localizedDescription)\n".utf8))
        exit(1)
      }
    }
#endif
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    GardenBandwidthBridge.install(on: flutterViewController.engine.binaryMessenger)
    GardenCacheBridge.install(on: flutterViewController.engine.binaryMessenger)
    NativeSetupBridge.install(on: flutterViewController.engine.binaryMessenger)
    FlutterMethodChannel(
      name: "garden/native_auth", binaryMessenger: flutterViewController.engine.binaryMessenger
    ).setMethodCallHandler { call, result in
      if call.method == "configured" {
        result(nativeAuthenticationConfigured())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    GardenFinderBridge.install(on: flutterViewController.engine.binaryMessenger)

    appearance = NSAppearance(named: .aqua)
    super.awakeFromNib()
  }
}
