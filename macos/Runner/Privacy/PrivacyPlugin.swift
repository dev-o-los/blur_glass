import AppKit
import FlutterMacOS
import Foundation

final class PrivacyPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = PrivacyPlugin()
    let method = FlutterMethodChannel(name: "blur_glass/privacy", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(instance, channel: method)
    let events = FlutterEventChannel(name: "blur_glass/privacy/events", binaryMessenger: registrar.messenger)
    events.setStreamHandler(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let runtime = BlurGlassRuntime.shared
    switch call.method {
    case "getCameraPermission":
      result(runtime.cameraAuthorization())
    case "requestCameraPermission":
      runtime.requestCameraAccess { granted in
        DispatchQueue.main.async {
          result(granted)
        }
      }
    case "openCameraSettings":
      if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
        NSWorkspace.shared.open(url)
      }
      result(nil)
    case "authenticateOwner":
      runtime.authenticateMacUser { ok, error in
        DispatchQueue.main.async {
          if ok {
            result(true)
          } else {
            result(FlutterError(code: "auth_failed", message: error?.localizedDescription ?? "Authentication failed", details: nil))
          }
        }
      }
    case "hasOwnerTemplate":
      result(runtime.hasOwnerTemplate)
    case "enrollOwner":
      runtime.startEnrollment { outcome in
        DispatchQueue.main.async {
          switch outcome {
          case .success(let count):
            result(count)
          case .failure(let error):
            result(FlutterError(code: "enroll_failed", message: error.localizedDescription, details: nil))
          }
        }
      }
    case "cancelEnrollment":
      runtime.cancelEnrollment()
      result(nil)
    case "clearOwner":
      runtime.clearOwner()
      result(nil)
    case "startProtection":
      // Verified flow: Touch ID/password → enroll if needed → protect.
      runtime.enableProtection { outcome in
        DispatchQueue.main.async {
          switch outcome {
          case .enabled:
            result(true)
          case .cancelled:
            result(false)
          case .failed(let message):
            result(FlutterError(code: "start_failed", message: message, details: nil))
          }
        }
      }
    case "stopProtection":
      runtime.stopProtection()
      result(true)
    case "isProtecting":
      result(runtime.isProtecting)
    case "setConfig":
      if let map = call.arguments as? [String: Any] {
        runtime.applyConfig(map)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    BlurGlassRuntime.shared.setListener { [weak self] map in
      DispatchQueue.main.async {
        self?.eventSink?(map)
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    BlurGlassRuntime.shared.setListener(nil)
    return nil
  }
}

