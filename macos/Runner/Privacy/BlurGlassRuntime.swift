import AVFoundation
import Foundation
import LocalAuthentication
import Vision

final class BlurGlassRuntime {
  static let shared = BlurGlassRuntime()

  let engine = AttentionEngine()
  private let camera = CameraFaceMonitor()
  private let shield = ScreenShieldController.shared

  private var protecting = false
  private var enrolling = false
  private var enrollBuffer: [VNFeaturePrintObservation] = []
  private var enrollHandler: ((Result<Int, Error>) -> Void)?
  private var listener: (([String: Any]) -> Void)?
  private let lock = NSLock()
  private var lastSnapshot = AttentionSnapshot(
    state: ShieldReason.idle.rawValue,
    faceCount: 0,
    ownerMatch: false,
    yaw: nil,
    pitch: nil,
    matchDistance: nil,
    message: "Protection is off.",
    shieldVisible: false
  )

  var isProtecting: Bool {
    lock.lock()
    defer { lock.unlock() }
    return protecting
  }

  var hasOwnerTemplate: Bool { OwnerIdentityStore.shared.hasTemplate }

  private init() {
    camera.onFrame = { [weak self] frame in
      self?.handle(frame: frame)
    }
    camera.onError = { [weak self] message in
      guard let self else { return }
      self.emit(
        AttentionSnapshot(
          state: ShieldReason.error.rawValue,
          faceCount: 0,
          ownerMatch: false,
          yaw: nil,
          pitch: nil,
          matchDistance: nil,
          message: message,
          shieldVisible: true
        )
      )
      self.shield.setVisible(true, reason: message)
    }
  }

  func setListener(_ listener: (([String: Any]) -> Void)?) {
    lock.lock()
    self.listener = listener
    let snapshot = lastSnapshot
    lock.unlock()
    DispatchQueue.main.async {
      listener?(snapshot.toMap())
    }
  }

  func cameraAuthorization() -> String {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized: return "authorized"
    case .denied: return "denied"
    case .restricted: return "restricted"
    case .notDetermined: return "notDetermined"
    @unknown default: return "unknown"
    }
  }

  func requestCameraAccess(_ completion: @escaping (Bool) -> Void) {
    AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
  }

  func authenticateMacUser(_ completion: @escaping (Bool, String?) -> Void) {
    let context = LAContext()
    var error: NSError?
    let reason = "Confirm you are the Mac user before Blur Glass learns your face."
    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
      context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { ok, err in
        DispatchQueue.main.async {
          completion(ok, err?.localizedDescription)
        }
      }
    } else {
      completion(true, error?.localizedDescription)
    }
  }

  func startEnrollment(_ completion: @escaping (Result<Int, Error>) -> Void) {
    lock.lock()
    enrollBuffer.removeAll()
    enrolling = true
    enrollHandler = completion
    engine.reset()
    lock.unlock()

    emit(
      AttentionSnapshot(
        state: ShieldReason.enrolling.rawValue,
        faceCount: 0,
        ownerMatch: false,
        yaw: nil,
        pitch: nil,
        matchDistance: nil,
        message: "Sit in your usual seat and look at the camera.",
        shieldVisible: false
      )
    )
    do {
      try camera.start()
    } catch {
      lock.lock()
      enrolling = false
      enrollHandler = nil
      lock.unlock()
      completion(.failure(error))
      return
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
      guard let self else { return }
      self.lock.lock()
      let stillEnrolling = self.enrolling
      self.lock.unlock()
      if stillEnrolling {
        self.finishEnrollment(error: NSError(
          domain: "BlurGlass",
          code: 10,
          userInfo: [NSLocalizedDescriptionKey: "Could not capture a stable owner face. Look straight at the camera and try again."]
        ))
      }
    }
  }

  func cancelEnrollment() {
    lock.lock()
    let isEnrolling = enrolling
    lock.unlock()
    guard isEnrolling else { return }
    finishEnrollment(
      error: NSError(
        domain: "BlurGlass",
        code: 12,
        userInfo: [NSLocalizedDescriptionKey: "Enrollment cancelled."]
      )
    )
  }

  func startProtection() throws {
    guard OwnerIdentityStore.shared.hasTemplate else {
      throw NSError(
        domain: "BlurGlass",
        code: 11,
        userInfo: [NSLocalizedDescriptionKey: "Enroll the owner face before turning protection on."]
      )
    }
    lock.lock()
    protecting = true
    engine.reset()
    lock.unlock()
    shield.setVisible(true, reason: "Starting Blur Glass…")
    try camera.start()
  }

  func stopProtection() {
    lock.lock()
    protecting = false
    let isEnrolling = enrolling
    engine.reset()
    lock.unlock()
    if !isEnrolling {
      camera.stop()
    }
    shield.setVisible(false, reason: "")
    emit(
      AttentionSnapshot(
        state: ShieldReason.idle.rawValue,
        faceCount: 0,
        ownerMatch: false,
        yaw: nil,
        pitch: nil,
        matchDistance: nil,
        message: "Protection is off.",
        shieldVisible: false
      )
    )
  }

  func applyConfig(_ map: [String: Any]) {
    if let v = map["yawDegrees"] as? Double { engine.config.yawDegrees = v }
    if let v = map["pitchDegrees"] as? Double { engine.config.pitchDegrees = v }
    if let v = map["unlockMs"] as? Double { engine.config.unlockMs = v }
    if let v = map["noFaceLockMs"] as? Double { engine.config.noFaceLockMs = v }
    if let v = map["matchDistance"] as? Double { engine.config.matchDistance = Float(v) }
  }

  func clearOwner() {
    stopProtection()
    OwnerIdentityStore.shared.clear()
  }

  private func handle(frame: VisionFrame) {
    lock.lock()
    let isEnrolling = enrolling
    let isProtecting = protecting
    lock.unlock()

    if isEnrolling {
      collectEnrollment(frame)
      return
    }
    guard isProtecting else { return }
    let snapshot = engine.evaluate(
      faces: frame.faces,
      hasOwnerTemplate: OwnerIdentityStore.shared.hasTemplate
    )
    emit(snapshot)
    shield.setVisible(snapshot.shieldVisible, reason: snapshot.message)
  }

  private func collectEnrollment(_ frame: VisionFrame) {
    lock.lock()
    let count = enrollBuffer.count
    lock.unlock()

    emit(
      AttentionSnapshot(
        state: ShieldReason.enrolling.rawValue,
        faceCount: frame.faces.count,
        ownerMatch: false,
        yaw: frame.faces.first?.yawDegrees,
        pitch: frame.faces.first?.pitchDegrees,
        matchDistance: nil,
        message: "Hold still — learning your face (\(count)/10).",
        shieldVisible: false
      )
    )
    guard frame.faces.count == 1, let print = frame.prints.first else { return }
    let yaw = abs(frame.faces[0].yawDegrees ?? 0)
    if yaw > 18 { return }

    var readyToFinish = false
    lock.lock()
    if enrolling {
      enrollBuffer.append(print)
      readyToFinish = enrollBuffer.count >= 10
    }
    lock.unlock()

    if readyToFinish {
      finishEnrollment(error: nil)
    }
  }

  private func finishEnrollment(error: Error?) {
    lock.lock()
    guard enrolling else {
      lock.unlock()
      return
    }
    enrolling = false
    let handler = enrollHandler
    enrollHandler = nil
    let isProtecting = protecting
    let buffer = enrollBuffer
    enrollBuffer.removeAll()
    lock.unlock()

    if !isProtecting {
      camera.stop()
    }
    if let error {
      DispatchQueue.main.async {
        handler?(.failure(error))
      }
      return
    }
    do {
      try OwnerIdentityStore.shared.save(prints: Array(buffer.prefix(10)))
      DispatchQueue.main.async {
        handler?(.success(buffer.count))
      }
    } catch {
      DispatchQueue.main.async {
        handler?(.failure(error))
      }
    }
  }

  private func emit(_ snapshot: AttentionSnapshot) {
    lock.lock()
    lastSnapshot = snapshot
    let l = listener
    lock.unlock()
    let map = snapshot.toMap()
    DispatchQueue.main.async {
      l?(map)
    }
  }
}

