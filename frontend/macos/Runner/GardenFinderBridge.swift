import FlutterMacOS
import Foundation

enum GardenFinderBridge {
  static func install(on messenger: FlutterBinaryMessenger) {
    FlutterEventChannel(name: "garden/finder/updates", binaryMessenger: messenger)
      .setStreamHandler(GardenFinderEvents())
    FlutterMethodChannel(name: "garden/finder", binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        Task { @MainActor in
          do {
            if call.method == "openSettings" {
              try NativeSetupBridge.openLoginSettings()
              result(nil)
              return
            }
            guard let arguments = call.arguments as? [String: Any],
              let accountID = arguments["accountID"] as? String else { throw FinderBridgeError.invalidArguments }
            var request = GardenRemoteRequest(accountID: accountID,
              driveIDs: arguments["driveIDs"] as? [Int], driveID: arguments["driveID"] as? Int,
              name: arguments["name"] as? String, nodeID: arguments["nodeID"] as? Int)
            try GardenRemoteBridge.registerService()
            if call.method == "open" {
              result(try await GardenRemoteBridge.open(request))
              return
            }
            if call.method == "register" {
              guard let driveID = request.driveID, let serverURL = arguments["serverURL"] as? String,
                let token = arguments["token"] as? String, let tokenID = arguments["tokenID"] as? String,
                let refreshToken = arguments["refreshToken"] as? String else { throw FinderBridgeError.invalidArguments }
              request.credential = FinderCredential(serverURL: serverURL, accountID: accountID,
                driveID: driveID, tokenID: tokenID, token: token, refreshToken: refreshToken)
            }
            let value = try await GardenRemoteBridge.request(call.method, request)
            if call.method == "reconcile" {
              guard let ids = request.driveIDs else { throw FinderBridgeError.invalidArguments }
              for id in ids {
                _ = try await GardenRemoteBridge.request("location", GardenRemoteRequest(accountID: accountID, driveID: id))
              }
              try await FinderDomainManager.retire(accountID: accountID)
            }
            result(value is NSNull ? nil : value)
          } catch {
            result(FlutterError(code: "finder_error", message: error.localizedDescription, details: nil))
          }
        }
      }
  }
}
