import Cocoa
import FlutterMacOS

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

    appearance = NSAppearance(named: .aqua)
    super.awakeFromNib()
  }
}
