import AVFoundation
import CoreVideo
import Foundation

@MainActor final class PlaybackProbe {
  private let player: AVPlayer
  private let video: AVPlayerItemVideoOutput
  private let completion = RemoteCompletion<Void>()
  private var started = false
  private var status: NSKeyValueObservation?
  private var boundary: Any?
  private var failure: NSObjectProtocol?

  init(url: URL) {
    player = AVPlayer(url: url)
    if #available(macOS 26, *) {
      video = AVPlayerItemVideoOutput(pixelBufferAttributes: CVPixelBufferAttributes(
        pixelFormatTypes: [CVPixelFormatType(rawValue: kCVPixelFormatType_32BGRA)]))
    } else {
      video = AVPlayerItemVideoOutput(pixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
      ])
    }
    player.isMuted = true
    player.currentItem?.add(video)
  }

  func run(offset: Double, duration: Double) async throws {
    guard let item = player.currentItem else { throw POSIXError(.EINVAL) }
    let began = ContinuousClock.now
    status = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
      Task { @MainActor in
        guard let self else { return }
        if item.status == .failed {
          self.completion.resolve(.failure(item.error ?? POSIXError(.EIO)))
        } else if item.status == .readyToPlay && !self.started {
          self.started = true
          self.player.seek(to: CMTime(seconds: offset, preferredTimescale: 600),
            toleranceBefore: .zero, toleranceAfter: .zero) { completed in
            Task { @MainActor in
              guard completed else { self.completion.resolve(.failure(POSIXError(.EIO))); return }
              print("Native player ready after \(began.duration(to: .now))", terminator: "\n")
              self.player.play()
            }
          }
        }
      }
    }
    boundary = player.addBoundaryTimeObserver(
      forTimes: [NSValue(time: CMTime(seconds: offset + duration, preferredTimescale: 600))], queue: .main
    ) { [weak self] in
      guard let self else { return }
      let size: (Int, Int)?
      if #available(macOS 26, *) {
        size = video.pixelBufferAndDisplayTime(forItemTime: player.currentTime()).pixelBuffer.map {
          ($0.size.width, $0.size.height)
        }
      } else {
        size = video.copyPixelBuffer(forItemTime: player.currentTime(), itemTimeForDisplay: nil).map {
          (CVPixelBufferGetWidth($0), CVPixelBufferGetHeight($0))
        }
      }
      guard let size, size.0 > 0, size.1 > 0 else { completion.resolve(.failure(POSIXError(.EIO))); return }
      print("Decoded native video frame: \(size.0) x \(size.1)")
      completion.resolve(.success(()))
    }
    failure = NotificationCenter.default.addObserver(forName: AVPlayerItem.failedToPlayToEndTimeNotification,
      object: item, queue: .main) { [weak self] notification in
      self?.completion.resolve(.failure(notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error ?? POSIXError(.EIO)))
    }
    let deadline = Task {
      try await Task.sleep(for: .seconds(180))
      completion.resolve(.failure(URLError(.timedOut)))
    }
    defer {
      deadline.cancel()
      player.pause()
      status = nil
      if let boundary { player.removeTimeObserver(boundary) }
      if let failure { NotificationCenter.default.removeObserver(failure) }
    }
    try await completion.wait()
    print("Native playback advanced \(duration) seconds after seek \(offset), elapsed \(began.duration(to: .now))")
  }
}

@main struct PlaybackTests {
  @MainActor static func main() async throws {
    setbuf(stdout, nil)
    let arguments = CommandLine.arguments
    guard arguments.count == 4, let offset = Double(arguments[2]), let duration = Double(arguments[3]),
      offset >= 0, duration > 0 else { throw POSIXError(.EINVAL) }
    let probe = PlaybackProbe(url: URL(fileURLWithPath: arguments[1]))
    try await probe.run(offset: offset, duration: duration)
  }
}
