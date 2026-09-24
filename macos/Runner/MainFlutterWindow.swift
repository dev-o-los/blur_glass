import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.title = "Blur Glass"

    // Liquid glass: the window is transparent and an NSVisualEffectView
    // behind the Flutter surface blurs whatever is beneath it — the desktop
    // wallpaper and any windows below. darkAqua keeps the material dark
    // regardless of the system appearance (the app is dark-only).
    let vibrancy = NSVisualEffectView(
      frame: NSRect(origin: .zero, size: windowFrame.size)
    )
    vibrancy.material = .underWindowBackground
    vibrancy.blendingMode = .behindWindow
    vibrancy.state = .active
    vibrancy.appearance = NSAppearance(named: .darkAqua)
    vibrancy.autoresizingMask = [.width, .height]
    contentView?.addSubview(vibrancy, positioned: .below, relativeTo: flutterViewController.view)

    self.appearance = NSAppearance(named: .darkAqua)
    self.titlebarAppearsTransparent = true
    self.isOpaque = false
    self.backgroundColor = .clear
    self.isMovableByWindowBackground = true
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
