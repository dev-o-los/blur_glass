import CryptoKit
import Foundation

/// Secure on-device store for the user's emergency exit password.
/// Stored as a salted SHA-256 hash in Application Support/BlurGlass (POSIX 0600).
final class EmergencyPasswordStore {
  static let shared = EmergencyPasswordStore()

  private let directoryName = "BlurGlass"
  private let filename = "emergency-pass.bin"
  private let salt = "blur_glass_emergency_exit_salt_2026"
  private let lock = NSLock()
  private var cachedHash: String?
  private var cacheLoaded = false

  private init() {}

  private var fileURL: URL? {
    guard let base = FileManager.default.urls(
      for: .applicationSupportDirectory, in: .userDomainMask
    ).first else { return nil }
    let dir = base.appendingPathComponent(directoryName, isDirectory: true)
    do {
      try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    } catch {
      return nil
    }
    return dir.appendingPathComponent(filename)
  }

  var hasPassword: Bool {
    lock.lock()
    defer { lock.unlock() }
    ensureCacheLoaded()
    return !(cachedHash?.isEmpty ?? true)
  }

  func setPassword(_ plain: String) throws {
    let trimmed = plain.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      clearPassword()
      return
    }
    guard let url = fileURL else {
      throw NSError(
        domain: "BlurGlass",
        code: 30,
        userInfo: [NSLocalizedDescriptionKey: "Could not reach private app storage."]
      )
    }
    let hash = computeHash(trimmed)
    let data = hash.data(using: .utf8) ?? Data()
    try data.write(to: url, options: .atomic)
    try? FileManager.default.setAttributes(
      [.posixPermissions: 0o600],
      ofItemAtPath: url.path
    )

    lock.lock()
    cachedHash = hash
    cacheLoaded = true
    lock.unlock()
  }

  func verifyPassword(_ candidate: String) -> Bool {
    lock.lock()
    ensureCacheLoaded()
    let expected = cachedHash
    lock.unlock()

    guard let expected, !expected.isEmpty else {
      // If no password was set, any non-empty or empty check shouldn't fail silently
      return false
    }
    let candidateHash = computeHash(candidate.trimmingCharacters(in: .whitespacesAndNewlines))
    return candidateHash == expected
  }

  func clearPassword() {
    if let url = fileURL {
      try? FileManager.default.removeItem(at: url)
    }
    lock.lock()
    cachedHash = nil
    cacheLoaded = true
    lock.unlock()
  }

  private func ensureCacheLoaded() {
    guard !cacheLoaded else { return }
    cachedHash = loadHash()
    cacheLoaded = true
  }

  private func loadHash() -> String? {
    guard let url = fileURL, let data = try? Data(contentsOf: url) else { return nil }
    let str = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    return str?.isEmpty == false ? str : nil
  }

  private func computeHash(_ input: String) -> String {
    let salted = "\(input):\(salt)"
    let digest = SHA256.hash(data: Data(salted.utf8))
    return digest.compactMap { String(format: "%02x", $0) }.joined()
  }
}
