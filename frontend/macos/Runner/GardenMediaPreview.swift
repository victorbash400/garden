import AVKit
import UniformTypeIdentifiers

@MainActor final class GardenMediaPreview {
  let view: AVPlayerView
  private let player: AVPlayer
  private var statusObservation: NSKeyValueObservation?

  static func supports(_ url: URL) -> Bool {
    guard let type = UTType(filenameExtension: url.pathExtension) else { return false }
    return type.conforms(to: .audio) || type.conforms(to: .movie)
  }

  init(_ url: URL) async throws {
    let asset = AVURLAsset(url: url)
    var timedOut = false
    let deadline = Task { @MainActor in
      do { try await Task.sleep(for: .seconds(30)) }
      catch { return }
      timedOut = true
      asset.cancelLoading()
    }
    defer { deadline.cancel() }
    let playable: Bool
    do {
      playable = try await withTaskCancellationHandler {
        try await asset.load(.isPlayable)
      } onCancel: { asset.cancelLoading() }
      try Task.checkCancellation()
    }
    catch {
      if timedOut { throw URLError(.timedOut) }
      throw error
    }
    guard playable else {
      throw NSError(domain: "GardenPreview", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "macOS cannot play this format. Use Open to choose its default application."])
    }
    let item = AVPlayerItem(asset: asset)
    player = AVPlayer(playerItem: item)
    view = AVPlayerView(frame: .zero)
    view.controlsStyle = .floating
    view.player = player
    statusObservation = item.observe(\.status, options: [.new]) { [weak self] item, _ in
      Task { @MainActor [weak self] in
        guard item.status == .failed, let window = self?.view.window else { return }
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Unable to play file"
        alert.informativeText = item.error?.localizedDescription ?? "The media player could not read this file."
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: window)
      }
    }
  }

  func close() {
    statusObservation?.invalidate()
    statusObservation = nil
    player.pause()
    player.replaceCurrentItem(with: nil)
    view.player = nil
  }
}
