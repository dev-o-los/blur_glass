import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.title = "Blur Glass"
    self.minSize = NSSize(width: 420, height: 560)
    self.delegate = self

    RegisterGeneratedPlugins(registry: flutterViewController)
    PrivacyPlugin.register(with: flutterViewController.registrar(forPlugin: "PrivacyPlugin"))

    super.awakeFromNib()
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    sender.orderOut(nil)
    return false
  }
}
