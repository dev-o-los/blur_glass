import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var statusItem: NSStatusItem?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    _ = BlurGlassRuntime.shared
    setupStatusItem()
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    showControlWindow()
    return true
  }

  private func setupStatusItem() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let icon = NSImage(
      systemSymbolName: "eye.trianglebadge.exclamationmark",
      accessibilityDescription: "Blur Glass"
    ) ?? NSImage(
      systemSymbolName: "eye.slash",
      accessibilityDescription: "Blur Glass"
    ) ?? NSImage(
      systemSymbolName: "eye",
      accessibilityDescription: "Blur Glass"
    )
    statusItem?.button?.image = icon

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Open Blur Glass", action: #selector(showControlWindow), keyEquivalent: "o"))
    menu.addItem(NSMenuItem(title: "Start protection", action: #selector(startProtection), keyEquivalent: ""))
    menu.addItem(NSMenuItem(title: "Pause protection", action: #selector(stopProtection), keyEquivalent: ""))
    menu.addItem(.separator())
    menu.addItem(NSMenuItem(title: "Quit Blur Glass", action: #selector(quitApp), keyEquivalent: "q"))
    statusItem?.menu = menu
  }

  @objc func showControlWindow() {
    NSApp.activate(ignoringOtherApps: true)
    mainFlutterWindow?.makeKeyAndOrderFront(nil)
  }

  @objc private func startProtection() {
    try? BlurGlassRuntime.shared.startProtection()
  }

  @objc private func stopProtection() {
    BlurGlassRuntime.shared.stopProtection()
  }

  @objc private func quitApp() {
    BlurGlassRuntime.shared.stopProtection()
    NSApp.terminate(nil)
  }
}

