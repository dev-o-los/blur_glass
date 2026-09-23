import AppKit

/// Full-desktop frost above Safari, YouTube, and every other app — not the Flutter window.
final class ScreenShieldController {
  static let shared = ScreenShieldController()

  private var windows: [ObjectIdentifier: ShieldWindow] = [:]
  private var reason: String = ""
  private var visible = false

  private init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screensChanged),
      name: NSApplication.didChangeScreenParametersNotification,
      object: nil
    )
  }

  func setVisible(_ on: Bool, reason: String) {
    DispatchQueue.main.async {
      self.reason = reason
      self.visible = on
      self.rebuildIfNeeded()
      for window in self.windows.values {
        window.updateCopy(reason)
        if on {
          window.ignoresMouseEvents = false
          window.orderFrontRegardless()
        } else {
          window.ignoresMouseEvents = true
          window.orderOut(nil)
        }
      }
    }
  }

  @objc private func screensChanged() {
    rebuildIfNeeded()
    if visible {
      setVisible(true, reason: reason)
    }
  }

  private func rebuildIfNeeded() {
    let screens = NSScreen.screens
    var keep: Set<ObjectIdentifier> = []
    for screen in screens {
      let id = ObjectIdentifier(screen)
      keep.insert(id)
      if windows[id] == nil {
        windows[id] = ShieldWindow(screen: screen)
      } else {
        windows[id]?.reposition(on: screen)
      }
    }
    for key in windows.keys where !keep.contains(key) {
      windows[key]?.orderOut(nil)
      windows[key] = nil
    }
  }
}

private final class ShieldWindow: NSPanel {
  private let effect = NSVisualEffectView()
  private let titleLabel = NSTextField(labelWithString: "Blur Glass")
  private let detailLabel = NSTextField(labelWithString: "")

  convenience init(screen: NSScreen) {
    self.init(
      contentRect: Self.shieldFrame(for: screen),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    configure()
    reposition(on: screen)
  }

  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }

  func reposition(on screen: NSScreen) {
    setFrame(Self.shieldFrame(for: screen), display: true)
  }

  func updateCopy(_ reason: String) {
    detailLabel.stringValue = reason
  }

  private func configure() {
    isOpaque = false
    backgroundColor = .clear
    hasShadow = false
    hidesOnDeactivate = false
    isFloatingPanel = true
    becomesKeyOnlyIfNeeded = true
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
    level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow)))
    sharingType = .none
    animationBehavior = .none
    isReleasedWhenClosed = false

    effect.material = .hudWindow
    effect.blendingMode = .behindWindow
    effect.state = .active
    effect.frame = contentView?.bounds ?? .zero
    effect.autoresizingMask = [.width, .height]
    contentView = effect

    titleLabel.font = .systemFont(ofSize: 28, weight: .semibold)
    titleLabel.textColor = .white
    titleLabel.alignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    detailLabel.font = .systemFont(ofSize: 16, weight: .regular)
    detailLabel.textColor = NSColor.white.withAlphaComponent(0.85)
    detailLabel.alignment = .center
    detailLabel.translatesAutoresizingMaskIntoConstraints = false

    effect.addSubview(titleLabel)
    effect.addSubview(detailLabel)
    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: effect.centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: effect.centerYAnchor, constant: -12),
      detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
      detailLabel.centerXAnchor.constraint(equalTo: effect.centerXAnchor),
      detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: effect.leadingAnchor, constant: 40),
      detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: effect.trailingAnchor, constant: -40),
    ])
  }

  /// Leave the menu bar uncovered so Pause still works while frosted.
  private static func shieldFrame(for screen: NSScreen) -> NSRect {
    var frame = screen.frame
    let menu: CGFloat = (screen == NSScreen.screens.first) ? 24 : 0
    frame.size.height -= menu
    return frame
  }
}
