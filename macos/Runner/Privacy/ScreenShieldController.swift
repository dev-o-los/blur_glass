import AppKit

/// Interactive emergency exit pill button on the frosted screen shield.
private final class ShieldEmergencyPillButton: NSControl {
  private var trackingArea: NSTrackingArea?
  private let iconImageView = NSImageView()
  private let labelField = NSTextField(labelWithString: "Emergency Exit")
  private let stackView = NSStackView()
  private var isPressed = false

  init(target: AnyObject?, action: Selector?) {
    super.init(frame: .zero)
    self.target = target
    self.action = action
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    wantsLayer = true
    layer?.cornerRadius = 20
    layer?.masksToBounds = true
    layer?.borderWidth = 1.2
    layer?.borderColor = NSColor(red: 1.0, green: 0.38, blue: 0.38, alpha: 0.55).cgColor
    layer?.backgroundColor = NSColor(white: 0.08, alpha: 0.70).cgColor

    // Content stack view for exact centered layout
    stackView.orientation = .horizontal
    stackView.spacing = 8
    stackView.alignment = .centerY
    stackView.translatesAutoresizingMaskIntoConstraints = false

    if #available(macOS 11.0, *) {
      let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
      iconImageView.image = NSImage(
        systemSymbolName: "lock.shield.fill",
        accessibilityDescription: "Emergency Exit"
      )?.withSymbolConfiguration(config)
    }
    iconImageView.contentTintColor = NSColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 1.0)
    iconImageView.translatesAutoresizingMaskIntoConstraints = false

    labelField.font = .systemFont(ofSize: 13, weight: .semibold)
    labelField.textColor = NSColor(red: 1.0, green: 0.50, blue: 0.50, alpha: 1.0)
    labelField.alignment = .center
    labelField.isEditable = false
    labelField.isSelectable = false
    labelField.isBezeled = false
    labelField.drawsBackground = false
    labelField.translatesAutoresizingMaskIntoConstraints = false

    stackView.addArrangedSubview(iconImageView)
    stackView.addArrangedSubview(labelField)
    addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    return true
  }

  override func hitTest(_ point: NSPoint) -> NSView? {
    guard let superview = superview else { return nil }
    let localPoint = convert(point, from: superview)
    return bounds.contains(localPoint) ? self : nil
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    if let trackingArea = trackingArea {
      removeTrackingArea(trackingArea)
    }
    let area = NSTrackingArea(
      rect: bounds,
      options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
      owner: self,
      userInfo: nil
    )
    addTrackingArea(area)
    self.trackingArea = area
  }

  override func resetCursorRects() {
    addCursorRect(bounds, cursor: .pointingHand)
  }

  override func mouseEntered(with event: NSEvent) {
    super.mouseEntered(with: event)
    updateState(hovered: true)
  }

  override func mouseExited(with event: NSEvent) {
    super.mouseExited(with: event)
    updateState(hovered: false)
  }

  override func mouseDown(with event: NSEvent) {
    isPressed = true
    updateState(hovered: true)
  }

  override func mouseUp(with event: NSEvent) {
    guard isPressed else { return }
    isPressed = false
    let localPoint = convert(event.locationInWindow, from: nil)
    if bounds.contains(localPoint) {
      if let action = action, let target = target {
        NSApp.sendAction(action, to: target, from: self)
      }
    }
    updateState(hovered: bounds.contains(localPoint))
  }

  private func updateState(hovered: Bool) {
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.15
      if isPressed {
        layer?.backgroundColor = NSColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 0.35).cgColor
        layer?.borderColor = NSColor(red: 1.0, green: 0.55, blue: 0.55, alpha: 1.0).cgColor
      } else if hovered {
        layer?.backgroundColor = NSColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 0.22).cgColor
        layer?.borderColor = NSColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 0.90).cgColor
        labelField.textColor = .white
        iconImageView.contentTintColor = .white
      } else {
        layer?.backgroundColor = NSColor(white: 0.08, alpha: 0.70).cgColor
        layer?.borderColor = NSColor(red: 1.0, green: 0.38, blue: 0.38, alpha: 0.55).cgColor
        labelField.textColor = NSColor(red: 1.0, green: 0.50, blue: 0.50, alpha: 1.0)
        iconImageView.contentTintColor = NSColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 1.0)
      }
    }
  }
}

/// Full-desktop frost above every app, Space, and the menu bar.
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
      EmergencyExitDialog.bringToFrontIfNeeded()
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
  private let centerContainer = NSView()
  private let shieldIconContainer = NSView()
  private let shieldIconView = NSImageView()
  private let titleLabel = NSTextField(labelWithString: "Blur Glass")
  private let detailLabel = NSTextField(labelWithString: "")
  private var emergencyExitButton: ShieldEmergencyPillButton!

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
    detailLabel.isHidden = reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// Fades the frost in/out. Repeat calls with the same state are no-ops.
  func setShielded(_ on: Bool, animated: Bool) {
    if on == shielded {
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
        alphaValue = 0
        orderFrontRegardless()
      }
      animator().alphaValue = on ? 1 : 0
    }, completionHandler: {
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

    // Center container holds the badge, title, and description
    centerContainer.translatesAutoresizingMaskIntoConstraints = false
    effect.addSubview(centerContainer)

    // Shield Icon Badge
    shieldIconContainer.wantsLayer = true
    shieldIconContainer.layer?.cornerRadius = 28
    shieldIconContainer.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.08).cgColor
    shieldIconContainer.layer?.borderColor = NSColor.white.withAlphaComponent(0.20).cgColor
    shieldIconContainer.layer?.borderWidth = 1.2
    shieldIconContainer.translatesAutoresizingMaskIntoConstraints = false

    if #available(macOS 11.0, *) {
      let config = NSImage.SymbolConfiguration(pointSize: 26, weight: .medium)
      shieldIconView.image = NSImage(
        systemSymbolName: "eye.slash.fill",
        accessibilityDescription: "Privacy Active"
      )?.withSymbolConfiguration(config)
    }
    shieldIconView.contentTintColor = NSColor.white.withAlphaComponent(0.90)
    shieldIconView.translatesAutoresizingMaskIntoConstraints = false
    shieldIconContainer.addSubview(shieldIconView)

    // Title
    titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
    titleLabel.textColor = .white
    titleLabel.alignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    // Detail / Subtitle
    detailLabel.font = .systemFont(ofSize: 15, weight: .regular)
    detailLabel.textColor = NSColor.white.withAlphaComponent(0.85)
    detailLabel.alignment = .center
    detailLabel.maximumNumberOfLines = 3
    detailLabel.cell?.wraps = true
    detailLabel.translatesAutoresizingMaskIntoConstraints = false

    centerContainer.addSubview(shieldIconContainer)
    centerContainer.addSubview(titleLabel)
    centerContainer.addSubview(detailLabel)

    // Emergency Exit Button at Bottom
    emergencyExitButton = ShieldEmergencyPillButton(
      target: self,
      action: #selector(onEmergencyExitClicked)
    )
    emergencyExitButton.translatesAutoresizingMaskIntoConstraints = false
    effect.addSubview(emergencyExitButton)

    NSLayoutConstraint.activate([
      // Center container centered exactly on screen
      centerContainer.centerXAnchor.constraint(equalTo: effect.centerXAnchor),
      centerContainer.centerYAnchor.constraint(equalTo: effect.centerYAnchor),
      centerContainer.widthAnchor.constraint(lessThanOrEqualTo: effect.widthAnchor, constant: -80),

      // Shield Icon Badge
      shieldIconContainer.topAnchor.constraint(equalTo: centerContainer.topAnchor),
      shieldIconContainer.centerXAnchor.constraint(equalTo: centerContainer.centerXAnchor),
      shieldIconContainer.widthAnchor.constraint(equalToConstant: 56),
      shieldIconContainer.heightAnchor.constraint(equalToConstant: 56),

      shieldIconView.centerXAnchor.constraint(equalTo: shieldIconContainer.centerXAnchor),
      shieldIconView.centerYAnchor.constraint(equalTo: shieldIconContainer.centerYAnchor),

      // Title
      titleLabel.topAnchor.constraint(equalTo: shieldIconContainer.bottomAnchor, constant: 14),
      titleLabel.centerXAnchor.constraint(equalTo: centerContainer.centerXAnchor),
      titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: centerContainer.leadingAnchor),
      titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: centerContainer.trailingAnchor),

      // Detail
      detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      detailLabel.centerXAnchor.constraint(equalTo: centerContainer.centerXAnchor),
      detailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: centerContainer.leadingAnchor),
      detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: centerContainer.trailingAnchor),
      detailLabel.bottomAnchor.constraint(equalTo: centerContainer.bottomAnchor),

      // Emergency Exit Button
      emergencyExitButton.centerXAnchor.constraint(equalTo: effect.centerXAnchor),
      emergencyExitButton.bottomAnchor.constraint(equalTo: effect.bottomAnchor, constant: -50),
      emergencyExitButton.heightAnchor.constraint(equalToConstant: 40),
      emergencyExitButton.widthAnchor.constraint(equalToConstant: 180),
    ])
  }

  @objc private func onEmergencyExitClicked() {
    EmergencyExitDialog.show()
  }
}
