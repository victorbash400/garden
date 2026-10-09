import FlutterMacOS
import Foundation

enum GardenFinderBridge {
  @MainActor static func install(on messenger: FlutterBinaryMessenger) {
    FlutterEventChannel(name: "garden/finder/updates", binaryMessenger: messenger)
      .setStreamHandler(GardenFinderEvents())
    FlutterMethodChannel(name: "garden/finder", binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        Task { @MainActor in
          do {
            if call.method == "openPrepared" {
              guard let arguments = call.arguments as? [String: Any], let path = arguments["path"] as? String else {
                throw FinderBridgeError.invalidArguments
              }
              let application = try GardenFileApplications.resolve(arguments["application"] as? String)
              result(try await GardenRemoteBridge.openPath(path, application: application))
              return
            }
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
            if call.method == "prepareOpen" {
              result(try await GardenRemoteBridge.request("location", request))
              return
            }
            if call.method == "signOut" { GardenFilePreview.dismiss() }
            if call.method == "preview" {
              guard request.nodeID != nil,
                let path = try await GardenRemoteBridge.request("location", request) as? String else {
                throw FinderBridgeError.invalidArguments
              }
              try await GardenFilePreview.show(URL(fileURLWithPath: path, isDirectory: false))
              result(nil)
              return
            }
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
              let status = try await GardenRemoteBridge.request("status", request) as? [String: [Int]]
              let disabled = Set(status?["disabled"] ?? [])
              for id in ids where !disabled.contains(id) {
                _ = try await GardenRemoteBridge.request("location", GardenRemoteRequest(accountID: accountID, driveID: id))
              }
              try await FinderDomainManager.retire(accountID: accountID)
            }
            result(value is NSNull ? nil : value)
          } catch {
            if error is CancellationError {
              result(FlutterError(code: "file_open_cancelled", message: "Opening canceled.", details: nil))
              return
            }
            let failure = error as NSError
            let code: String
            let message: String
            if failure.domain == NSURLErrorDomain && failure.code == NSURLErrorTimedOut ||
              failure.domain == "GardenRemote" && failure.code == 408 {
              code = "finder_timeout"
              message = "The drive took too long to respond. Check Connections in Settings and try again."
            } else if failure.domain == "GardenRemote" && failure.code == 401 {
              code = "finder_session_expired"
              message = "The drive connection has expired. Reconnect it in Settings and try again."
            } else if failure.domain == "GardenRemote" && failure.code == 403 {
              code = "finder_access_denied"
              message = "You no longer have access to this drive. Ask its owner to restore access."
            } else if failure.domain == "GardenRemote" && failure.code == 503 {
              code = "finder_unmounted"
              message = "This drive is not connected. Open Drives in Settings to mount or reconnect it."
            } else if failure.domain == NSOSStatusErrorDomain && failure.code == -10814 {
              code = "file_no_application"
              message = "No installed application can open this file. Choose an application with Open With."
            } else {
              code = "finder_error"
              message = error.localizedDescription
            }
            result(FlutterError(code: code, message: message, details: nil))
          }
        }
      }
  }
}
