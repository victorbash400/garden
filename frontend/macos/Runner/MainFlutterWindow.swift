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
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    FlutterMethodChannel(
      name: "garden/native_auth", binaryMessenger: flutterViewController.engine.binaryMessenger
    ).setMethodCallHandler { call, result in
      if call.method == "configured" {
        result(nativeAuthenticationConfigured())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    FlutterMethodChannel(
      name: "garden/finder", binaryMessenger: flutterViewController.engine.binaryMessenger
    ).setMethodCallHandler { call, result in
      if call.method == "openSettings" {
        do {
          try FinderDomainManager.openSettings()
          result(nil)
        } catch {
          result(FlutterError(code: "finder_error", message: error.localizedDescription, details: nil))
        }
        return
      }
      guard let arguments = call.arguments as? [String: Any],
            let accountID = arguments["accountID"] as? String else {
        result(FlutterError(code: "invalid_arguments", message: "Missing account ID", details: nil))
        return
      }
      Task {
        do {
          switch call.method {
          case "missing":
            guard let driveIDs = arguments["driveIDs"] as? [Int] else {
              throw FinderBridgeError.invalidArguments
            }
            result(try await FinderDomainManager.missing(accountID: accountID, driveIDs: driveIDs))
          case "register":
            guard let driveID = arguments["driveID"] as? Int,
                  let name = arguments["name"] as? String,
                  let serverURL = arguments["serverURL"] as? String,
                  let token = arguments["token"] as? String,
                  let tokenID = arguments["tokenID"] as? String,
                  let refreshToken = arguments["refreshToken"] as? String else {
              throw FinderBridgeError.invalidArguments
            }
            try await FinderDomainManager.register(
              accountID: accountID, driveID: driveID, name: name,
              credential: FinderCredential(
                serverURL: serverURL, accountID: accountID, driveID: driveID,
                tokenID: tokenID,
                token: token, refreshToken: refreshToken
              )
            )
            result(nil)
          case "reconcile":
            guard let driveIDs = arguments["driveIDs"] as? [Int] else {
              throw FinderBridgeError.invalidArguments
            }
            try await FinderDomainManager.reconcile(accountID: accountID, driveIDs: driveIDs)
            result(nil)
          case "signOut":
            try await FinderDomainManager.signOut(accountID: accountID)
            result(nil)
          case "tokenIDs":
            result(try await FinderDomainManager.tokenIDs(accountID: accountID))
          case "enabled":
            guard let driveIDs = arguments["driveIDs"] as? [Int] else {
              throw FinderBridgeError.invalidArguments
            }
            result(try await FinderDomainManager.enabled(accountID: accountID, driveIDs: driveIDs))
          case "open":
            guard let driveID = arguments["driveID"] as? Int else {
              throw FinderBridgeError.invalidArguments
            }
            try await FinderDomainManager.open(accountID: accountID, driveID: driveID)
            result(nil)
          case "signal":
            guard let driveID = arguments["driveID"] as? Int,
                  let parentIDs = arguments["parentIDs"] as? [Int] else {
              throw FinderBridgeError.invalidArguments
            }
            try await FinderDomainManager.signal(
              accountID: accountID, driveID: driveID, parentIDs: parentIDs
            )
            result(nil)
          default:
            result(FlutterMethodNotImplemented)
          }
        } catch {
          result(FlutterError(code: "finder_error", message: error.localizedDescription, details: nil))
        }
      }
    }

    appearance = NSAppearance(named: .aqua)
    super.awakeFromNib()
  }
}
