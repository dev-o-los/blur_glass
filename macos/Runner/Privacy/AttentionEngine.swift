import Foundation

struct PrivacyConfig {
  var yawDegrees: Double = 22
  var pitchDegrees: Double = 24
  var unlockMs: Double = 350
  var noFaceLockMs: Double = 500
  var extraFaceLockMs: Double = 150
  var strangerLockMs: Double = 200
  var matchDistance: Float = 0.72
}

enum ShieldReason: String {
  case owner
  case lookAway
  case extraFace
  case stranger
  case noFace
  case idle
  case enrolling
  case error
}

struct AttentionSnapshot {
  var state: String
  var faceCount: Int
  var ownerMatch: Bool
  var yaw: Double?
  var pitch: Double?
  var matchDistance: Double?
  var message: String
  var shieldVisible: Bool

  func toMap() -> [String: Any] {
    var map: [String: Any] = [
      "state": state,
      "faceCount": faceCount,
      "ownerMatch": ownerMatch,
      "shieldVisible": shieldVisible,
      "message": message,
    ]
    if let yaw { map["yaw"] = yaw }
    if let pitch { map["pitch"] = pitch }
    if let matchDistance { map["matchDistance"] = matchDistance }
    return map
  }
}

struct FaceSample {
  var yawDegrees: Double?
  var pitchDegrees: Double?
  var area: CGFloat
  var ownerDistance: Float?
}

final class AttentionEngine {
  var config = PrivacyConfig()

  private var lockStarted: Date?
  private var unlockStarted: Date?
  private var currentLocked = true
  private var lastReason: ShieldReason = .idle

  func reset() {
    lockStarted = nil
    unlockStarted = nil
    currentLocked = true
    lastReason = .idle
  }

  func evaluate(faces: [FaceSample], hasOwnerTemplate: Bool, now: Date = Date()) -> AttentionSnapshot {
    let count = faces.count
    let primary = faces.max(by: { $0.area < $1.area })
    let yaw = primary?.yawDegrees
    let pitch = primary?.pitchDegrees
    let distance = primary?.ownerDistance
    let ownerMatch = hasOwnerTemplate && distance != nil && distance! <= config.matchDistance

    let desired: ShieldReason
    var message: String

    if count >= 2 {
      desired = .extraFace
      message = "Another person is in view. Screen hidden."
    } else if count == 0 {
      desired = .noFace
      message = "No face in view. Screen hidden."
    } else if hasOwnerTemplate && !ownerMatch {
      desired = .stranger
      message = "Face does not match the enrolled owner. Screen hidden."
    } else if lookingAway(yaw: yaw, pitch: pitch) {
      desired = .lookAway
      message = "Looking away. Screen hidden."
    } else {
      desired = .owner
      message = "Owner looking at the screen."
    }

    let shouldLock = desired != .owner
    let delayMs = delay(for: desired)
    if shouldLock {
      unlockStarted = nil
      if lockStarted == nil { lockStarted = now }
      let elapsed = now.timeIntervalSince(lockStarted!) * 1000
      if elapsed >= delayMs {
        currentLocked = true
        lastReason = desired
      }
    } else {
      lockStarted = nil
      if unlockStarted == nil { unlockStarted = now }
      let elapsed = now.timeIntervalSince(unlockStarted!) * 1000
      if elapsed >= config.unlockMs {
        currentLocked = false
        lastReason = .owner
      }
    }

    let state = currentLocked ? lastReason.rawValue : ShieldReason.owner.rawValue
    return AttentionSnapshot(
      state: state,
      faceCount: count,
      ownerMatch: ownerMatch,
      yaw: yaw,
      pitch: pitch,
      matchDistance: distance.map { Double($0) },
      message: currentLocked ? (lastReason == .owner ? message : messageFor(lastReason)) : message,
      shieldVisible: currentLocked
    )
  }

  private func lookingAway(yaw: Double?, pitch: Double?) -> Bool {
    if let yaw, abs(yaw) > config.yawDegrees { return true }
    if let pitch, abs(pitch) > config.pitchDegrees { return true }
    return false
  }

  private func delay(for reason: ShieldReason) -> Double {
    switch reason {
    case .extraFace: return config.extraFaceLockMs
    case .stranger: return config.strangerLockMs
    case .noFace: return config.noFaceLockMs
    case .lookAway: return 180
    default: return 0
    }
  }

  private func messageFor(_ reason: ShieldReason) -> String {
    switch reason {
    case .extraFace: return "Another person is in view. Screen hidden."
    case .stranger: return "Face does not match the enrolled owner. Screen hidden."
    case .noFace: return "No face in view. Screen hidden."
    case .lookAway: return "Looking away. Screen hidden."
    case .owner: return "Owner looking at the screen."
    case .enrolling: return "Learning your face…"
    case .error: return "Camera error."
    case .idle: return "Protection is off."
    }
  }
}
