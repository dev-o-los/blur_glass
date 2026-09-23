import Foundation
import Vision

/// On-device owner face prints. Apple Face ID / Touch ID templates are not readable.
final class OwnerIdentityStore {
  static let shared = OwnerIdentityStore()

  private let service = "com.example.blurGlass.ownerPrints"
  private let account = "ownerFeaturePrints"
  private let lock = NSLock()
  private var cachedPrints: [VNFeaturePrintObservation]?
  private var cacheLoaded = false

  private init() {}

  var hasTemplate: Bool {
    lock.lock()
    defer { lock.unlock() }
    ensureCacheLoaded()
    return cachedPrints != nil && !(cachedPrints?.isEmpty ?? true)
  }

  func save(prints: [VNFeaturePrintObservation]) throws {
    let data = try NSKeyedArchiver.archivedData(withRootObject: prints, requiringSecureCoding: true)
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    SecItemDelete(query as CFDictionary)
    var add = query
    add[kSecValueData as String] = data
    add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    let status = SecItemAdd(add as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
    }
    lock.lock()
    cachedPrints = prints
    cacheLoaded = true
    lock.unlock()
  }

  func clear() {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
    ]
    SecItemDelete(query as CFDictionary)
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
    cachedPrints = loadPrintsFromKeychain()
    cacheLoaded = true
  }

  private func loadPrintsFromKeychain() -> [VNFeaturePrintObservation]? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status == errSecSuccess, let data = item as? Data else { return nil }
    return try? NSKeyedUnarchiver.unarchivedObject(
      ofClasses: [NSArray.self, VNFeaturePrintObservation.self],
      from: data
    ) as? [VNFeaturePrintObservation]
  }
}

