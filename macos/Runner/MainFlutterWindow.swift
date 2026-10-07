import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  override func awakeFromNib() {
    super.awakeFromNib()

    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    self.title = "Blur Glass"

    let windowWidth: CGFloat = 420
    let windowHeight: CGFloat = 228

    // Prevent macOS from restoring any old/large window frames
    self.isRestorable = false
    self.setFrameAutosaveName("")
    UserDefaults.standard.removeObject(forKey: "NSWindow Frame Blur Glass")

    // Configure window appearance
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)
    self.styleMask.insert(.resizable)
    self.isOpaque = false
    self.backgroundColor = .clear
    self.hasShadow = true
    self.isMovableByWindowBackground = true

    // Initial size and minimum/maximum adjustable bounds
    self.minSize = NSSize(width: 380, height: 215)
    self.maxSize = NSSize(width: 1200, height: 1000)
    self.setContentSize(NSSize(width: windowWidth, height: windowHeight))
    self.setFrame(
      NSRect(
        x: self.frame.origin.x,
        y: self.frame.origin.y,
        width: windowWidth,
        height: windowHeight
      ),
      display: true,
      animate: false
    )

    self.standardWindowButton(.zoomButton)?.isEnabled = true
    self.standardWindowButton(.zoomButton)?.isHidden = false

    self.delegate = self
    self.center()

    // --- Transparent Flutter surface -------------------------------------
    makeFlutterSurfaceTransparent(flutterViewController.view)
    if let layer = flutterViewController.view.layer {
      layer.isOpaque = false
      layer.backgroundColor = NSColor.clear.cgColor
    }
    clearOpaqueMetalLayers(flutterViewController.view.layer)
    contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    // ----------------------------------------------------------------------

    RegisterGeneratedPlugins(registry: flutterViewController)
    PrivacyPlugin.register(with: flutterViewController.registrar(forPlugin: "PrivacyPlugin"))
    setupWindowChannel(with: flutterViewController)
  }

  private func setupWindowChannel(with controller: FlutterViewController) {
    let channel = FlutterMethodChannel(name: "blur_glass/window", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else {
        result(nil)
        return
      }
      if call.method == "setWindowSize",
         let args = call.arguments as? [String: Any],
         let width = args["width"] as? Double,
         let height = args["height"] as? Double {
        let animate = (args["animate"] as? Bool) ?? true
        self.resizeWindow(to: NSSize(width: CGFloat(width), height: CGFloat(height)), animated: animate)
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func resizeWindow(to newSize: NSSize, animated: Bool) {
    var frame = self.frame
    let heightDiff = frame.size.height - newSize.height
    frame.origin.y += heightDiff
    frame.size = newSize
    self.setFrame(frame, display: true, animate: animated)
  }

  private func makeFlutterSurfaceTransparent(_ view: NSView) {
    guard let viewClass = object_getClass(view) else { return }
    let opaqueSelector = #selector(getter: NSView.isOpaque)
    guard let method = class_getInstanceMethod(viewClass, opaqueSelector) else { return }
    let transparentImp = imp_implementationWithBlock(
      { (_: AnyObject) -> Bool in false } as @convention(block) (AnyObject) -> Bool
    )
    method_setImplementation(method, transparentImp)
  }

  private func clearOpaqueMetalLayers(_ layer: CALayer?) {
    guard let layer else { return }
    if layer is CAMetalLayer {
      layer.isOpaque = false
      layer.backgroundColor = NSColor.clear.cgColor
    }
    for sublayer in layer.sublayers ?? [] {
      clearOpaqueMetalLayers(sublayer)
    }
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
}
