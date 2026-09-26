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
    vibrancy.autoresizingMask = [.width, .height]
    contentView?.addSubview(vibrancy, positioned: .below, relativeTo: nil)

    self.titlebarAppearsTransparent = true
    // Frameless look: the Flutter sidebar paints flush behind the traffic
    // lights, exactly like the product mock.
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)
    self.isOpaque = false
    self.backgroundColor = .clear
    self.isMovableByWindowBackground = true
    self.minSize = NSSize(width: 640, height: 520)
    self.delegate = self

    // --- Transparent Flutter surface -------------------------------------
    // FlutterView reports isOpaque == true, which tells AppKit to composite
    // its metal surface WITHOUT alpha — a black rectangle that hides any
    // vibrancy behind it. Clearing the layer is not enough; the view-level
    // opaque flag must go. Replace the isOpaque implementation on the
    // Flutter view's runtime class only (safe: no global swizzling).
    makeFlutterSurfaceTransparent(flutterViewController.view)
    if let layer = flutterViewController.view.layer {
      layer.isOpaque = false
      layer.backgroundColor = NSColor.clear.cgColor
    }
    // Some Flutter versions host the metal surface in a sublayer; clear those
    // too so nothing paints as an opaque black plane.
    clearOpaqueMetalLayers(flutterViewController.view.layer)
    contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    // ----------------------------------------------------------------------

    RegisterGeneratedPlugins(registry: flutterViewController)
    PrivacyPlugin.register(with: flutterViewController.registrar(forPlugin: "PrivacyPlugin"))

    super.awakeFromNib()
  }

  /// Replaces `-[<FlutterView class> isOpaque]` with an implementation that
  /// returns false. Uses the view's actual runtime class, so this works even
  /// if Flutter renames the class in a future release.
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
    sender.orderOut(nil)
    return false
  }
}
