import Foundation
import CoreServices

final class GardenBuildWatch {
  private let bundle: URL
  private let runningID: String
  private let changed: (Bool) -> Void
  private let queue = DispatchQueue(label: "garden.build", qos: .utility)
  private var stream: FSEventStreamRef?
  private var pending: DispatchWorkItem?

  init(bundle: URL, changed: @escaping (Bool) -> Void) throws {
    self.bundle = bundle
    self.runningID = try Self.buildID(bundle)
    self.changed = changed
    var context = FSEventStreamContext(version: 0,
      info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
    stream = FSEventStreamCreate(nil, { _, info, _, _, _, _ in
      guard let info else { return }
      Unmanaged<GardenBuildWatch>.fromOpaque(info).takeUnretainedValue().schedule()
    }, &context, [bundle.appendingPathComponent("Contents").path] as CFArray,
      FSEventStreamEventId(kFSEventStreamEventIdSinceNow), 0.2,
      FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagWatchRoot))
    guard let stream else { throw CocoaError(.fileReadUnknown) }
    FSEventStreamSetDispatchQueue(stream, queue)
    guard FSEventStreamStart(stream) else { throw CocoaError(.fileReadUnknown) }
  }

  private func schedule() {
    pending?.cancel()
    let work = DispatchWorkItem { [weak self] in
      guard let self else { return }
      let candidate = try? Self.buildID(bundle)
      let ready = candidate != nil && candidate != runningID && Self.validSignature(bundle)
      DispatchQueue.main.async { [weak self] in self?.changed(ready) }
    }
    pending = work
    queue.asyncAfter(deadline: .now() + 0.6, execute: work)
  }

  static func buildID(_ bundle: URL) throws -> String {
    let url = bundle.appendingPathComponent("Contents/Resources/GardenBuildID")
    let value = try String(contentsOf: url, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    guard UUID(uuidString: value) != nil else { throw CocoaError(.fileReadCorruptFile) }
    return value
  }

  static func validSignature(_ bundle: URL) -> Bool {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
    task.arguments = ["--verify", "--deep", "--strict", bundle.path]
    task.standardOutput = FileHandle.nullDevice
    task.standardError = FileHandle.nullDevice
    do { try task.run(); task.waitUntilExit(); return task.terminationStatus == 0 }
    catch { return false }
  }

  deinit {
    pending?.cancel()
    if let stream { FSEventStreamStop(stream); FSEventStreamInvalidate(stream); FSEventStreamRelease(stream) }
  }
}
