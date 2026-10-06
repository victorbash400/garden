import AVFoundation
import CryptoKit
import Foundation
import ImageIO

@main struct MediaReadTests {
  static func require(_ condition: Bool, _ message: String) throws {
    if !condition { throw NSError(domain: "MediaReadTests", code: 1,
      userInfo: [NSLocalizedDescriptionKey: message]) }
  }

  static func main() async {
    setbuf(stdout, nil)
    do {
      for domain in CommandLine.arguments.dropFirst() { try await check(domain) }
    } catch { print("Media read test failed: \(error.localizedDescription)"); exit(1) }
  }

  static func check(_ domain: String) async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("garden-media-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let engine = try RemoteEngine(domainID: domain, state: root.appendingPathComponent("state"),
      cache: root.appendingPathComponent("cache"), limit: 64 * 1024 * 1024)
    try await engine.prepare()
    let path = "/Volumes/GardenMediaTest-\(UUID())"
    let mount = try await RemoteMount.start(engine: engine, path: path, name: "Garden Media Test")
    let running = Task { try await mount.run() }
    do {
      var after = 0
      var nodes: [GardenNode] = []
      while true {
        let page = try await engine.api.snapshot(after: after)
        nodes.append(contentsOf: page)
        if page.count < 256 { break }
        guard let next = page.last?.id, next > after else { throw GardenAPIError.invalidResponse }
        after = next
      }
      var checked = 0
      for node in nodes where !node.folder && node.parentID == 0 {
        let name = node.name.lowercased()
        let url = URL(fileURLWithPath: path).appendingPathComponent(node.name)
        let started = ContinuousClock.now
        let before = await engine.ranges.remoteBytes
        if name.hasSuffix(".wav") {
          let audio = try AVAudioFile(forReading: url)
          guard let buffer = AVAudioPCMBuffer(pcmFormat: audio.processingFormat, frameCapacity: 4096) else {
            throw GardenAPIError.invalidResponse
          }
          try audio.read(into: buffer, frameCount: 4096)
          try require(buffer.frameLength > 0 && audio.length > 0, "Audio frames must decode")
          audio.framePosition = max(0, audio.length - 4096)
          try audio.read(into: buffer, frameCount: 4096)
          try require(buffer.frameLength > 0, "An audio seek near EOF must decode")
          print("WAV", node.id, "frames", audio.length, "rate", audio.fileFormat.sampleRate)
        } else if name.hasSuffix(".png") || name.hasSuffix(".jpg") || name.hasSuffix(".jpeg") {
          guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0,
              [kCGImageSourceShouldCacheImmediately: true] as CFDictionary) else {
            throw GardenAPIError.invalidResponse
          }
          try require(image.width > 0 && image.height > 0, "Image pixels must decode")
          print("IMAGE", node.id, image.width, image.height)
        } else if name.hasSuffix(".md") || name.hasSuffix(".svg") {
          let data = try Data(contentsOf: url)
          try require(data.count == node.size && String(data: data, encoding: .utf8) != nil,
            "Text documents must have their exact length and valid UTF-8")
          if name.hasSuffix(".svg") { _ = try XMLDocument(data: data) }
          print("DOCUMENT", node.id, data.count)
        } else { continue }
        let fetched = await engine.ranges.remoteBytes - before
        print("COLD", node.id, started.duration(to: .now), "remote bytes", fetched, "file size", node.size)
        let warm = ContinuousClock.now
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        try require(data.count == node.size, "Complete media reads must preserve file size")
        print("COMPLETE", node.id, warm.duration(to: .now), "native read seconds")
        var reference = SHA256()
        var offset = 0
        while offset < node.size {
          let count = min(256 * 1024, node.size - offset)
          let chunk = try await engine.api.read(id: node.id, version: node.version, offset: offset, length: count)
          try require(chunk.count == count, "Cloud verification reads must have their exact length")
          reference.update(data: chunk)
          offset += count
        }
        try require(reference.finalize() == SHA256.hash(data: data), "Every downloaded byte must match the cloud object")
        print("VERIFIED", node.id, "complete SHA256 and size passed")
        checked += 1
      }
      try require(checked > 0, "The media fixture drive must contain supported test files")
      try await mount.unmount()
      try await running.value
      await engine.stop()
      print("Media decode, seeks and complete downloads passed", checked)
    } catch {
      do { try await mount.unmount() } catch { print("Media test unmount failed: \(error.localizedDescription)") }
      _ = await running.result
      await engine.stop()
      throw error
    }
  }
}
