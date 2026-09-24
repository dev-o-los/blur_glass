import Foundation
import Vision

/// On-device owner face prints. Apple Face ID / Touch ID templates are not
/// readable, so Blur Glass stores its own Vision feature prints.
///
/// Storage is the app's private Application Support directory (POSIX 0600):
/// - Sandboxed app data is readable only by Blur Glass for this user.
/// - Unlike the Keychain, reading it NEVER triggers a system password prompt.
///   (Keychain ACLs are invalidated whenever a debug build is re-signed, so
///   Keychain-backed secrets made macOS ask for the login password on every
///   app launch — exactly what users describe as scammy.)
final class OwnerIdentityStore {
  static let shared = OwnerIdentityStore()

  private let directoryName = "BlurGlass"
  private let filename = "owner-featureprints.bin"
  private let lock = NSLock()
  private var cachedPrints: [VNFeaturePrintObservation]?
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

  var hasTemplate: Bool {
    lock.lock()
    defer { lock.unlock() }
    ensureCacheLoaded()
    return !(cachedPrints?.isEmpty ?? true)
  }

  func save(prints: [VNFeaturePrintObservation]) throws {
    guard let url = fileURL else {
      throw NSError(
        domain: "BlurGlass", code: 20,
        userInfo: [NSLocalizedDescriptionKey: "Could not reach private app storage."]
      )
    }
    let data = try NSKeyedArchiver.archivedData(withRootObject: prints, requiringSecureCoding: true)
    try data.write(to: url, options: .atomic)
    // Restrict to the owning user (rw-------).
    try? FileManager.default.setAttributes(
      [.posixPermissions: 0o600],
      ofItemAtPath: url.path
    )
    lock.lock()
    cachedPrints = prints
    cacheLoaded = true
    lock.unlock()
  }

  func clear() {
    if let url = fileURL {
      try? FileManager.default.removeItem(at: url)
    }
    lock.lock()
    cachedPrints = nil
    cacheLoaded = true
    lock.unlock()
  }

  func bestDistance(to candidate: VNFeaturePrintObservation) -> Float? {
    lock.lock()
    ensureCacheLoaded()
    let prints = cachedPrints
    lock.unlock()

    guard let prints, !prints.isEmpty else { return nil }
    var best: Float = .greatestFiniteMagnitude
    for print in prints {
      var distance: Float = 0
      do {
        try print.computeDistance(&distance, to: candidate)
        best = min(best, distance)
      } catch {
        continue
      }
    }
    return best == .greatestFiniteMagnitude ? nil : best
  }

  private func ensureCacheLoaded() {
    guard !cacheLoaded else { return }
    cachedPrints = loadPrints()
    cacheLoaded = true
  }

  private func loadPrints() -> [VNFeaturePrintObservation]? {
    guard let url = fileURL, let data = try? Data(contentsOf: url) else { return nil }
    return try? NSKeyedUnarchiver.unarchivedObject(
      ofClasses: [NSArray.self, VNFeaturePrintObservation.self],
      from: data
    ) as? [VNFeaturePrintObservation]
  }
}
