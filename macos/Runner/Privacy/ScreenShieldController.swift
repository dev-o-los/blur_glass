import AppKit

/// Full-desktop frost above every app, Space, and the menu bar — not the Flutter window.
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
        window.setShielded(on, animated: true)
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
  private let emergencyExitButton = NSButton()

  /// Fade timings (seconds).
  private let fadeInDuration: TimeInterval = 0.28
  private let fadeOutDuration: TimeInterval = 0.38

  private var shielded = false

  convenience init(screen: NSScreen) {
    self.init(
      contentRect: screen.frame,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )
    configure()
    reposition(on: screen)
  }

  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }

  /// Full screen frame — menu bar and notch included, nothing left uncovered.
  func reposition(on screen: NSScreen) {
    setFrame(screen.frame, display: true)
  }

  func updateCopy(_ reason: String) {
    detailLabel.stringValue = reason
  }

  /// Fades the frost in/out. Repeat calls with the same state are no-ops,
  /// so the engine can push snapshots every frame without restarting animations.
  func setShielded(_ on: Bool, animated: Bool) {
    if on == shielded {
      if on { orderFrontRegardless() }
      return
    }
    shielded = on
    ignoresMouseEvents = !on

    guard animated else {
      alphaValue = on ? 1 : 0
      if on { orderFrontRegardless() } else { orderOut(nil) }
      return
    }

    NSAnimationContext.runAnimationGroup({ context in
      context.duration = on ? fadeInDuration : fadeOutDuration
      context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      context.allowsImplicitAnimation = false
      if on {
        // Start fully transparent so the first ordered-front frame is blank,
        // then fade up. No readable flash frame.
        alphaValue = 0
        orderFrontRegardless()
      }
      animator().alphaValue = on ? 1 : 0
    }, completionHandler: {
      // A newer toggle may have flipped the state mid-animation.
      if !self.shielded {
        self.orderOut(nil)
        self.alphaValue = 1
      }
    })
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
    alphaValue = 0

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

    emergencyExitButton.title = " Emergency Exit"
    if #available(macOS 11.0, *) {
      let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
      emergencyExitButton.image = NSImage(
        systemSymbolName: "lock.shield",
        accessibilityDescription: "Emergency Exit"
      )?.withSymbolConfiguration(config)
      emergencyExitButton.imagePosition = .imageLeading
    }
    emergencyExitButton.bezelStyle = .regularSquare
    emergencyExitButton.isBordered = false
    emergencyExitButton.wantsLayer = true
    emergencyExitButton.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.55).cgColor
    emergencyExitButton.layer?.cornerRadius = 18
    emergencyExitButton.layer?.borderWidth = 1.2
    emergencyExitButton.layer?.borderColor = NSColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 0.7).cgColor
    emergencyExitButton.contentTintColor = NSColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
    emergencyExitButton.font = .systemFont(ofSize: 13, weight: .semibold)
    emergencyExitButton.target = self
    emergencyExitButton.action = #selector(onEmergencyExitClicked)
    emergencyExitButton.translatesAutoresizingMaskIntoConstraints = false

    effect.addSubview(titleLabel)
    effect.addSubview(detailLabel)
    effect.addSubview(emergencyExitButton)

    NSLayoutConstraint.activate([
      titleLabel.centerXAnchor.constraint(equalTo: effect.centerXAnchor),
      titleLabel.centerYAnchor.constraint(equalTo: effect.centerYAnchor, constant: -12),
      detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
      detailLabel.centerXAnchor.constraint(equalTo: effect.centerXAnchor),
      detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: effect.leadingAnchor, constant: 40),
      detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: effect.trailingAnchor, constant: -40),

      emergencyExitButton.centerXAnchor.constraint(equalTo: effect.centerXAnchor),
      emergencyExitButton.bottomAnchor.constraint(equalTo: effect.bottomAnchor, constant: -50),
      emergencyExitButton.heightAnchor.constraint(equalToConstant: 36),
      emergencyExitButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
    ])
  }

  @objc private func onEmergencyExitClicked() {
    EmergencyExitDialog.show()
  }
}

