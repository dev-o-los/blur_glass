import AppKit
import QuartzCore

/// High-priority modal dialog for emergency exit override when screen is shielded.
final class EmergencyExitDialog: NSPanel, NSTextFieldDelegate {
  private static var currentInstance: EmergencyExitDialog?

  private let passwordField = NSSecureTextField()
  private let errorLabel = NSTextField(labelWithString: "")
  private let unlockButton = NSButton(title: "Unlock & Stop Protection", target: nil, action: nil)
  private let cancelButton = NSButton(title: "Cancel", target: nil, action: nil)

  static func show() {
    DispatchQueue.main.async {
      if let existing = currentInstance {
        existing.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        return
      }

      let dialog = EmergencyExitDialog()
      currentInstance = dialog
      dialog.center()
      dialog.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
      dialog.makeFirstResponder(dialog.passwordField)
    }
  }

  static func dismiss() {
    DispatchQueue.main.async {
      currentInstance?.close()
      currentInstance = nil
    }
  }

  init() {
    let width: CGFloat = 420
    let height: CGFloat = 280
    let rect = NSRect(x: 0, y: 0, width: width, height: height)

    super.init(
      contentRect: rect,
      styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )

    configure()
  }

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }

  private func configure() {
    isFloatingPanel = true
    level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow)) + 20)
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    isOpaque = false
    backgroundColor = .clear
    hasShadow = true
    isMovableByWindowBackground = true
    animationBehavior = .alertPanel

    let visualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 420, height: 280))
    visualEffect.material = .hudWindow
    visualEffect.blendingMode = .behindWindow
    visualEffect.state = .active
    visualEffect.wantsLayer = true
    visualEffect.layer?.cornerRadius = 16
    visualEffect.layer?.masksToBounds = true
    visualEffect.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
    visualEffect.layer?.borderWidth = 1
    contentView = visualEffect

    // Icon
    let iconView = NSImageView()
    if #available(macOS 11.0, *) {
      let config = NSImage.SymbolConfiguration(pointSize: 32, weight: .medium)
      iconView.image = NSImage(
        systemSymbolName: "lock.shield.fill",
        accessibilityDescription: "Emergency Exit"
      )?.withSymbolConfiguration(config)
    }
    iconView.contentTintColor = NSColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0)
    iconView.translatesAutoresizingMaskIntoConstraints = false

    // Title
    let title = NSTextField(labelWithString: "Emergency Exit")
    title.font = .systemFont(ofSize: 18, weight: .bold)
    title.textColor = .white
    title.alignment = .center
    title.translatesAutoresizingMaskIntoConstraints = false

    // Description
    let desc = NSTextField(
      labelWithString: EmergencyPasswordStore.shared.hasPassword
        ? "Enter your emergency exit password to immediately stop protection and restore your screen."
        : "No emergency exit password is set. Click Unlock to authenticate with Touch ID / Mac password."
    )
    desc.font = .systemFont(ofSize: 13, weight: .regular)
    desc.textColor = NSColor.white.withAlphaComponent(0.8)
    desc.alignment = .center
    desc.maximumNumberOfLines = 3
    desc.cell?.wraps = true
    desc.translatesAutoresizingMaskIntoConstraints = false

    // Password input field
    passwordField.placeholderString = "Emergency Password"
    passwordField.font = .systemFont(ofSize: 14)
    passwordField.textColor = .white
    passwordField.backgroundColor = NSColor.black.withAlphaComponent(0.35)
    passwordField.isBordered = true
    passwordField.wantsLayer = true
    passwordField.layer?.cornerRadius = 8
    passwordField.layer?.borderColor = NSColor.white.withAlphaComponent(0.25).cgColor
    passwordField.layer?.borderWidth = 1
    passwordField.focusRingType = .none
    passwordField.target = self
    passwordField.action = #selector(onUnlock)
    passwordField.delegate = self
    passwordField.translatesAutoresizingMaskIntoConstraints = false
    passwordField.isHidden = !EmergencyPasswordStore.shared.hasPassword

    // Error label
    errorLabel.font = .systemFont(ofSize: 12, weight: .medium)
    errorLabel.textColor = NSColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
    errorLabel.alignment = .center
    errorLabel.translatesAutoresizingMaskIntoConstraints = false
    errorLabel.stringValue = ""

    // Buttons
    cancelButton.target = self
    cancelButton.action = #selector(onCancel)
    cancelButton.bezelStyle = .rounded
    cancelButton.keyEquivalent = "\u{1b}" // Esc key
    cancelButton.translatesAutoresizingMaskIntoConstraints = false

    unlockButton.target = self
    unlockButton.action = #selector(onUnlock)
    unlockButton.bezelStyle = .rounded
    unlockButton.keyEquivalent = "\r" // Return key
    unlockButton.translatesAutoresizingMaskIntoConstraints = false

    visualEffect.addSubview(iconView)
    visualEffect.addSubview(title)
    visualEffect.addSubview(desc)
    visualEffect.addSubview(passwordField)
    visualEffect.addSubview(errorLabel)
    visualEffect.addSubview(cancelButton)
    visualEffect.addSubview(unlockButton)

    NSLayoutConstraint.activate([
      iconView.topAnchor.constraint(equalTo: visualEffect.topAnchor, constant: 20),
      iconView.centerXAnchor.constraint(equalTo: visualEffect.centerXAnchor),
      iconView.widthAnchor.constraint(equalToConstant: 40),
      iconView.heightAnchor.constraint(equalToConstant: 40),

      title.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
      title.centerXAnchor.constraint(equalTo: visualEffect.centerXAnchor),

      desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
      desc.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor, constant: 24),
      desc.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor, constant: -24),

      passwordField.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 14),
      passwordField.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor, constant: 36),
      passwordField.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor, constant: -36),
      passwordField.heightAnchor.constraint(equalToConstant: 32),

      errorLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 6),
      errorLabel.centerXAnchor.constraint(equalTo: visualEffect.centerXAnchor),

      cancelButton.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor, constant: -18),
      cancelButton.trailingAnchor.constraint(equalTo: unlockButton.leadingAnchor, constant: -12),
      cancelButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

      unlockButton.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor, constant: -18),
      unlockButton.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor, constant: -28),
      unlockButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 130),
    ])
  }

  @objc private func onUnlock() {
    if !EmergencyPasswordStore.shared.hasPassword {
      // If no emergency password is set, authenticate via Mac credentials
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
      errorLabel.stringValue = "Incorrect password. Please try again."
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
