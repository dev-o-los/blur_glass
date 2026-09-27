import AppKit
import QuartzCore

/// Custom NSSecureTextFieldCell that vertically centers the text and cursor with precise insets.
private final class CenteredSecureTextFieldCell: NSSecureTextFieldCell {
  var horizontalPadding: CGFloat = 14

  override func drawingRect(forBounds rect: NSRect) -> NSRect {
    let textSize = cellSize(forBounds: rect)
    let heightDelta = rect.size.height - textSize.height
    let yOffset = heightDelta > 0 ? (heightDelta / 2.0).rounded(.down) : 0

    return NSRect(
      x: rect.origin.x + horizontalPadding,
      y: rect.origin.y + yOffset,
      width: max(0, rect.size.width - (horizontalPadding * 2)),
      height: textSize.height
    )
  }

  override func select(
    withFrame rect: NSRect,
    in controlView: NSView,
    editor textObj: NSText,
    delegate: Any?,
    start selStart: Int,
    length selLength: Int
  ) {
    let fieldRect = drawingRect(forBounds: rect)
    super.select(
      withFrame: fieldRect,
      in: controlView,
      editor: textObj,
      delegate: delegate,
      start: selStart,
      length: selLength
    )
  }

  override func edit(
    withFrame rect: NSRect,
    in controlView: NSView,
    editor textObj: NSText,
    delegate: Any?,
    event: NSEvent?
  ) {
    let fieldRect = drawingRect(forBounds: rect)
    super.edit(
      withFrame: fieldRect,
      in: controlView,
      editor: textObj,
      delegate: delegate,
      event: event
    )
  }
}

/// Custom Secure Text Field with modern frosted styling and centered cursor.
private final class CustomSecureTextField: NSSecureTextField {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    let customCell = CenteredSecureTextFieldCell(textCell: "")
    customCell.isScrollable = true
    customCell.lineBreakMode = .byClipping
    customCell.isEditable = true
    customCell.isSelectable = true
    customCell.isEnabled = true
    self.cell = customCell

    isEditable = true
    isSelectable = true
    isEnabled = true
    isBordered = false
    drawsBackground = false
    focusRingType = .none
    font = .systemFont(ofSize: 15, weight: .regular)
    textColor = .white

    wantsLayer = true
    layer?.backgroundColor = NSColor(white: 0.06, alpha: 0.85).cgColor
    layer?.cornerRadius = 10
    layer?.borderWidth = 1.2
    layer?.borderColor = NSColor.white.withAlphaComponent(0.22).cgColor

    let placeholderAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: NSColor.white.withAlphaComponent(0.35),
      .font: NSFont.systemFont(ofSize: 14, weight: .regular)
    ]
    placeholderAttributedString = NSAttributedString(
      string: "Enter emergency password",
      attributes: placeholderAttributes
    )
  }

  override var acceptsFirstResponder: Bool { true }
  override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

  func setFocused(_ focused: Bool) {
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.15
      layer?.borderColor = focused
        ? NSColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 0.85).cgColor
        : NSColor.white.withAlphaComponent(0.22).cgColor
    }
  }
}

/// Interactive frosted button with hover glow and pointing hand cursor.
private final class DialogPillButton: NSControl {
  enum Variant {
    case primary
    case secondary
  }

  private let variant: Variant
  private var trackingArea: NSTrackingArea?
  private let label = NSTextField()
  private var isPressed = false

  init(title: String, variant: Variant, target: AnyObject?, action: Selector?) {
    self.variant = variant
    super.init(frame: .zero)
    self.target = target
    self.action = action
    self.label.stringValue = title
    setup()
  }

  required init?(coder: NSCoder) {
    self.variant = .secondary
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    wantsLayer = true
    layer?.cornerRadius = 10
    layer?.masksToBounds = true

    label.font = .systemFont(ofSize: 13, weight: variant == .primary ? .semibold : .medium)
    label.alignment = .center
    label.isEditable = false
    label.isSelectable = false
    label.isBezeled = false
    label.drawsBackground = false
    label.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)

    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: centerXAnchor),
      label.centerYAnchor.constraint(equalTo: centerYAnchor),
      label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
      label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
    ])

    updateVisuals(hovered: false)
  }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    return true
  }

  override func hitTest(_ point: NSPoint) -> NSView? {
    guard let superview = superview else { return nil }
    let local = convert(point, from: superview)
    return bounds.contains(local) ? self : nil
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
    updateVisuals(hovered: true)
  }

  override func mouseExited(with event: NSEvent) {
    super.mouseExited(with: event)
    updateVisuals(hovered: false)
  }

  override func mouseDown(with event: NSEvent) {
    isPressed = true
    updateVisuals(hovered: true)
  }

  override func mouseUp(with event: NSEvent) {
    guard isPressed else { return }
    isPressed = false
    let local = convert(event.locationInWindow, from: nil)
    if bounds.contains(local) {
      if let action = action, let target = target {
        NSApp.sendAction(action, to: target, from: self)
      }
    }
    updateVisuals(hovered: bounds.contains(local))
  }

  private func updateVisuals(hovered: Bool) {
    NSAnimationContext.runAnimationGroup { context in
      context.duration = 0.15
      switch variant {
      case .primary:
        label.textColor = .white
        if isPressed {
          layer?.backgroundColor = NSColor(red: 0.75, green: 0.18, blue: 0.18, alpha: 1.0).cgColor
        } else {
          layer?.backgroundColor = hovered
            ? NSColor(red: 0.95, green: 0.28, blue: 0.28, alpha: 1.0).cgColor
            : NSColor(red: 0.85, green: 0.22, blue: 0.22, alpha: 0.95).cgColor
        }
        layer?.borderWidth = 1.0
        layer?.borderColor = NSColor(red: 1.0, green: 0.45, blue: 0.45, alpha: hovered ? 0.9 : 0.6).cgColor
      case .secondary:
        label.textColor = NSColor.white.withAlphaComponent(hovered ? 1.0 : 0.85)
        if isPressed {
          layer?.backgroundColor = NSColor.white.withAlphaComponent(0.25).cgColor
        } else {
          layer?.backgroundColor = hovered
            ? NSColor.white.withAlphaComponent(0.18).cgColor
            : NSColor.white.withAlphaComponent(0.10).cgColor
        }
        layer?.borderWidth = 1.0
        layer?.borderColor = NSColor.white.withAlphaComponent(hovered ? 0.35 : 0.20).cgColor
      }
    }
  }
}

/// High-priority modal dialog for emergency exit override when screen is shielded.
final class EmergencyExitDialog: NSPanel, NSTextFieldDelegate {
  private static var currentInstance: EmergencyExitDialog?

  static var isVisible: Bool {
    currentInstance?.isVisible == true
  }

  static func bringToFrontIfNeeded() {
    guard let instance = currentInstance, instance.isVisible else { return }
    instance.orderFrontRegardless()
  }

  private let passwordField = CustomSecureTextField()
  private let errorLabel = NSTextField(labelWithString: "")
  private var unlockButton: DialogPillButton!
  private var cancelButton: DialogPillButton!

  static func show() {
    DispatchQueue.main.async {
      NSApp.activate(ignoringOtherApps: true)
      let dialog: EmergencyExitDialog
      if let existing = currentInstance {
        dialog = existing
      } else {
        dialog = EmergencyExitDialog()
        currentInstance = dialog
        dialog.center()
      }
      dialog.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow)) + 100)
      dialog.makeKeyAndOrderFront(nil)
      dialog.orderFrontRegardless()
      dialog.makeFirstResponder(dialog.passwordField)
      dialog.passwordField.selectText(nil)
    }
  }

  static func dismiss() {
    DispatchQueue.main.async {
      currentInstance?.close()
      currentInstance = nil
    }
  }

  init() {
    let width: CGFloat = 430
    let height: CGFloat = 290
    let rect = NSRect(x: 0, y: 0, width: width, height: height)

    super.init(
      contentRect: rect,
      styleMask: [.titled, .fullSizeContentView, .closable],
      backing: .buffered,
      defer: false
    )

    configure()
  }

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }

  private func configure() {
    isFloatingPanel = true
    becomesKeyOnlyIfNeeded = false
    level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow)) + 100)
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    isOpaque = false
    backgroundColor = .clear
    hasShadow = true
    hidesOnDeactivate = false
    isMovableByWindowBackground = true
    animationBehavior = .alertPanel

    let container = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 430, height: 290))
    container.material = .hudWindow
    container.blendingMode = .behindWindow
    container.state = .active
    container.wantsLayer = true
    container.layer?.cornerRadius = 18
    container.layer?.masksToBounds = true
    container.layer?.borderColor = NSColor.white.withAlphaComponent(0.20).cgColor
    container.layer?.borderWidth = 1.2
    contentView = container

    // Icon container with soft red background glow
    let iconContainer = NSView()
    iconContainer.wantsLayer = true
    iconContainer.layer?.cornerRadius = 22
    iconContainer.layer?.backgroundColor = NSColor(red: 1.0, green: 0.32, blue: 0.32, alpha: 0.15).cgColor
    iconContainer.layer?.borderColor = NSColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 0.35).cgColor
    iconContainer.layer?.borderWidth = 1.0
    iconContainer.translatesAutoresizingMaskIntoConstraints = false

    let iconView = NSImageView()
    if #available(macOS 11.0, *) {
      let config = NSImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
      iconView.image = NSImage(
        systemSymbolName: "lock.shield.fill",
        accessibilityDescription: "Emergency Exit"
      )?.withSymbolConfiguration(config)
    }
    iconView.contentTintColor = NSColor(red: 1.0, green: 0.40, blue: 0.40, alpha: 1.0)
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconContainer.addSubview(iconView)

    // Title
    let title = NSTextField(labelWithString: "Emergency Exit")
    title.font = .systemFont(ofSize: 19, weight: .bold)
    title.textColor = .white
    title.alignment = .center
    title.translatesAutoresizingMaskIntoConstraints = false

    // Description
    let hasPassword = EmergencyPasswordStore.shared.hasPassword
    let desc = NSTextField(
      labelWithString: hasPassword
        ? "Enter your emergency password to immediately stop protection and restore your screen."
        : "No password set. Authenticate with Touch ID or your Mac credentials to exit."
    )
    desc.font = .systemFont(ofSize: 13, weight: .regular)
    desc.textColor = NSColor.white.withAlphaComponent(0.78)
    desc.alignment = .center
    desc.maximumNumberOfLines = 2
    desc.cell?.wraps = true
    desc.translatesAutoresizingMaskIntoConstraints = false

    // Password input field
    passwordField.target = self
    passwordField.action = #selector(onUnlock)
    passwordField.delegate = self
    passwordField.translatesAutoresizingMaskIntoConstraints = false
    passwordField.isHidden = !hasPassword

    // Error label
    errorLabel.font = .systemFont(ofSize: 12, weight: .medium)
    errorLabel.textColor = NSColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0)
    errorLabel.alignment = .center
    errorLabel.translatesAutoresizingMaskIntoConstraints = false
    errorLabel.stringValue = ""

    // Buttons
    cancelButton = DialogPillButton(
      title: "Cancel",
      variant: .secondary,
      target: self,
      action: #selector(onCancel)
    )
    cancelButton.translatesAutoresizingMaskIntoConstraints = false

    unlockButton = DialogPillButton(
      title: hasPassword ? "Unlock & Stop" : "Authenticate & Exit",
      variant: .primary,
      target: self,
      action: #selector(onUnlock)
    )
    unlockButton.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(iconContainer)
    container.addSubview(title)
    container.addSubview(desc)
    container.addSubview(passwordField)
    container.addSubview(errorLabel)
    container.addSubview(cancelButton)
    container.addSubview(unlockButton)

    NSLayoutConstraint.activate([
      // Icon
      iconContainer.topAnchor.constraint(equalTo: container.topAnchor, constant: 22),
      iconContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      iconContainer.widthAnchor.constraint(equalToConstant: 44),
      iconContainer.heightAnchor.constraint(equalToConstant: 44),

      iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
      iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

      // Title
      title.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 10),
      title.centerXAnchor.constraint(equalTo: container.centerXAnchor),

      // Description
      desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
      desc.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 28),
      desc.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -28),

      // Password Field
      passwordField.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 16),
      passwordField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 36),
      passwordField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -36),
      passwordField.heightAnchor.constraint(equalToConstant: 38),

      // Error Label
      errorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 6),
      errorLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

      // Buttons
      cancelButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
      cancelButton.trailingAnchor.constraint(equalTo: container.centerXAnchor, constant: -6),
      cancelButton.widthAnchor.constraint(equalToConstant: 110),
      cancelButton.heightAnchor.constraint(equalToConstant: 36),

      unlockButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
      unlockButton.leadingAnchor.constraint(equalTo: container.centerXAnchor, constant: 6),
      unlockButton.widthAnchor.constraint(equalToConstant: 160),
      unlockButton.heightAnchor.constraint(equalToConstant: 36),
    ])
  }

  override func keyDown(with event: NSEvent) {
    if event.keyCode == 53 { // Esc key
      onCancel()
      return
    }
    if event.keyCode == 36 || event.keyCode == 76 { // Return / Enter
      onUnlock()
      return
    }
    super.keyDown(with: event)
  }

  func controlTextDidBeginEditing(_ obj: Notification) {
    passwordField.setFocused(true)
    errorLabel.stringValue = ""
  }

  func controlTextDidEndEditing(_ obj: Notification) {
    passwordField.setFocused(false)
  }

  @objc private func onUnlock() {
    if !EmergencyPasswordStore.shared.hasPassword {
      BlurGlassRuntime.shared.authenticateMacUser { [weak self] ok, _ in
        guard let self else { return }
        if ok {
          self.performEmergencyExit()
        } else {
          self.shake()
          self.errorLabel.stringValue = "Authentication failed."
        }
      }
      return
    }

    let candidate = passwordField.stringValue
    if EmergencyPasswordStore.shared.verifyPassword(candidate) {
      performEmergencyExit()
    } else {
      shake()
      errorLabel.stringValue = "Incorrect emergency password. Please try again."
      passwordField.selectText(nil)
    }
  }

  @objc private func onCancel() {
    EmergencyExitDialog.dismiss()
  }

  private func performEmergencyExit() {
    EmergencyExitDialog.dismiss()
    BlurGlassRuntime.shared.emergencyExit()
  }

  private func shake() {
    let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
    animation.timingFunction = CAMediaTimingFunction(name: .linear)
    animation.duration = 0.4
    animation.values = [-12.0, 12.0, -8.0, 8.0, -4.0, 4.0, 0.0]
    contentView?.layer?.add(animation, forKey: "shake")
  }
}
