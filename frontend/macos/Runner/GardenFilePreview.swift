import AppKit
import QuickLookUI

@MainActor final class GardenFilePreview: NSWindowController, NSWindowDelegate {
  private static var current: GardenFilePreview?
  private static var generation = 0
  private static var loading: Task<GardenFilePreview, Error>?
  private let preview: QLPreviewView?
  private let media: GardenMediaPreview?

  static func show(_ url: URL) async throws {
    guard url.isFileURL else { throw CocoaError(.fileReadUnsupportedScheme) }
    dismiss()
    let ticket = generation
    let task = Task { try await GardenFilePreview(url) }
    loading = task
    defer { if ticket == generation { loading = nil } }
    let controller: GardenFilePreview
    do { controller = try await task.value }
    catch {
      if ticket != generation { return }
      throw error
    }
    guard ticket == generation else {
      controller.close()
      return
    }
    current = controller
    controller.showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  static func dismiss() {
    generation += 1
    loading?.cancel()
    loading = nil
    current?.close()
    current = nil
  }

  private init(_ url: URL) async throws {
    let frame = NSRect(x: 0, y: 0, width: 800, height: 600)
    let content: NSView
    if GardenMediaPreview.supports(url) {
      let media = try await GardenMediaPreview(url)
      self.media = media
      self.preview = nil
      content = media.view
    } else {
      guard let preview = QLPreviewView(frame: frame, style: .normal) else {
        throw CocoaError(.featureUnsupported)
      }
      self.preview = preview
      self.media = nil
      content = preview
    }
    let window = NSWindow(contentRect: frame,
      styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
    window.title = url.lastPathComponent
    window.contentMinSize = NSSize(width: 360, height: 240)
    window.contentView = content
    window.isReleasedWhenClosed = false
    super.init(window: window)
    window.delegate = self
    preview?.shouldCloseWithWindow = true
    preview?.autostarts = false
    preview?.previewItem = url as NSURL
    window.center()
  }

  required init?(coder: NSCoder) { nil }

  func windowWillClose(_ notification: Notification) {
    preview?.close()
    media?.close()
    if Self.current === self { Self.current = nil }
  }
}
