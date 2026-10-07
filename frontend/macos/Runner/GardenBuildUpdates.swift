import Cocoa
@preconcurrency import FlutterMacOS

@MainActor enum GardenBuildUpdates {
  private static var watch: GardenBuildWatch?
  private static var channels: [String: FlutterMethodChannel] = [:]
  private static var ready = false
  private static var restarting = false
  private static var error: String?

  static var state: [String: Any] {
    ["ready": ready, "restarting": restarting, "error": error as Any? ?? NSNull()]
  }

  static func install(_ channel: FlutterMethodChannel, slot: String) {
    channels[slot] = channel
    guard watch == nil else { return }
    do {
      watch = try GardenBuildWatch(bundle: Bundle.main.bundleURL) { available in
        ready = available
        publish()
      }
    } catch { self.error = "Build detection is unavailable." }
  }

  private static func publish() {
    for channel in channels.values { channel.invokeMethod("build", arguments: state) }
  }

  private static func prepare(_ channel: FlutterMethodChannel) async -> Result<[String: Any], Error> {
    await withCheckedContinuation { continuation in
      var completed = false
      let deadline = DispatchWorkItem {
        guard !completed else { return }
        completed = true
        continuation.resume(returning: .failure(NSError(domain: "GardenRelaunch", code: 1,
          userInfo: [NSLocalizedDescriptionKey: "An account window is not responding."])))
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: deadline)
      channel.invokeMethod("prepareRelaunch", arguments: nil) { response in
        guard !completed else { return }
        completed = true
        deadline.cancel()
        if let session = response as? [String: Any] { continuation.resume(returning: .success(session)) }
        else {
          let message = response as? String ?? "An account window is not ready to relaunch."
          continuation.resume(returning: .failure(NSError(domain: "GardenRelaunch", code: 1,
            userInfo: [NSLocalizedDescriptionKey: message])))
        }
      }
    }
  }

  static func relaunch(beforeLaunch: () -> Void, failed: () -> Void) async {
    guard ready, !restarting else { return }
    restarting = true
    error = nil
    publish()
    var sessions: [String: Any] = [:]
    for (slot, channel) in channels {
      switch await prepare(channel) {
      case .success(let session): sessions[slot] = session
      case .failure(let failure): cancel(failure.localizedDescription); return
      }
    }
    let bundle = Bundle.main.bundleURL
    let valid = await Task.detached { GardenBuildWatch.validSignature(bundle) }.value
    guard valid else { cancel("The build is still being written. Try again when it finishes."); return }
    let handoff: String
    do { handoff = try GardenSessionHandoff.create(sessions) }
    catch { cancel("Could not preserve the account sessions. Try again."); return }
    do { try await GardenRemoteBridge.prepareUpdate() }
    catch {
      GardenSessionHandoff.remove(handoff)
      cancel("Could not update Garden's background service: \(error.localizedDescription)")
      return
    }
    beforeLaunch()
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.createsNewApplicationInstance = true
    configuration.arguments = [GardenSessionHandoff.argument, handoff]
    let receipt = GardenRelaunchReceipt(name: handoff)
    defer { receipt.close() }
    do {
      let application = try await NSWorkspace.shared.openApplication(at: bundle, configuration: configuration)
      do { try await receipt.wait() }
      catch { application.terminate(); throw error }
      GardenSessionHandoff.remove(handoff)
      NSApplication.shared.terminate(nil)
    } catch {
      GardenSessionHandoff.remove(handoff)
      failed()
      cancel("Could not relaunch Garden. Try again.")
    }
  }

  private static func cancel(_ message: String) {
    restarting = false
    error = message
    for channel in channels.values { channel.invokeMethod("cancelRelaunch", arguments: nil) }
    publish()
  }
}
