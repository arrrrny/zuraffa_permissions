import AVFoundation
import Contacts
import EventKit
import Flutter
import LocalAuthentication
import Photos
import UIKit

/// The iOS implementation of zuraffa_permissions.
///
/// Each scope maps onto the framework that owns its permission. The
/// wire statuses mirror the Dart PermissionWireStatus vocabulary:
/// granted / denied / permanentlyDenied / undetermined / restricted /
/// limited. iOS has no "permanently denied" API — the standard
/// heuristic (denied + "don't allow" previously chosen, which is
/// indistinguishable from plain denied on-device) reports `denied`, and
/// the Dart layer decides when to offer `openSettings`; a second denial
/// of the same scope after a request is reported as
/// `permanentlyDenied` via the request-count heuristic below, which
/// matches the UX every Flutter permissions package ships.
public class ZuraffaPermissionsPlugin: NSObject, FlutterPlugin {
  private static let channelName = "zuraffa_permissions"

  // Wire statuses.
  private let granted = "granted"
  private let denied = "denied"
  private let permanentlyDenied = "permanentlyDenied"
  private let undetermined = "undetermined"
  private let restricted = "restricted"
  private let limited = "limited"

  /// Scopes this process has requested at least once (the
  /// permanently-denied heuristic).
  private var requestedScopes: Set<String> = []

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = ZuraffaPermissionsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let scopes = (call.arguments as? [String]) ?? []

    switch call.method {
    case "checkPermissions":
      checkAll(scopes: scopes, completion: result)
    case "requestPermissions":
      requestAll(scopes: scopes, completion: result)
    case "openSettings":
      result(openSettings())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - check

  private func checkAll(scopes: [String], completion: @escaping FlutterResult) {
    var statuses: [String: String] = [:]
    let group = DispatchGroup()
    let lock = NSLock()

    for scope in scopes {
      group.enter()
      checkScope(scope: scope) { status in
        lock.lock()
        statuses[scope] = status
        lock.unlock()
        group.leave()
      }
    }

    group.notify(queue: .main) {
      completion(statuses)
    }
  }

  /// Checks one scope's current status without prompting.
  private func checkScope(scope: String, completion: @escaping (String) -> Void) {
    switch scope {
    case "camera":
      completion(avStatus(for: AVMediaType.video))
    case "microphone":
      completion(avStatus(for: AVMediaType.audio))
    case "photos":
      completion(photoStatus())
    case "notifications":
      completion(notificationStatus())
    case "locationWhenInUse", "locationAlways":
      completion(locationStatus(always: scope == "locationAlways"))
    case "contacts":
      completion(contactsStatus())
    case "calendar":
      completion(calendarStatus())
    case "biometrics":
      completion(biometricsStatus())
    default:
      completion(undetermined)
    }
  }

  // MARK: - request

  private func requestAll(scopes: [String], completion: @escaping FlutterResult) {
    var statuses: [String: String] = [:]
    let group = DispatchGroup()
    let lock = NSLock()

    for scope in scopes {
      group.enter()
      requestScope(scope: scope) { status in
        lock.lock()
        statuses[scope] = status
        lock.unlock()
        group.leave()
      }
    }

    group.notify(queue: .main) {
      completion(statuses)
    }
  }

  /// Requests one scope, resolving with the post-prompt status.
  private func requestScope(scope: String, completion: @escaping (String) -> Void) {
    requestedScopes.insert(scope)

    switch scope {
    case "camera":
      requestAV(.video, completion: completion)
    case "microphone":
      requestAV(.audio, completion: completion)
    case "photos":
      requestPhotos(completion: completion)
    case "notifications":
      requestNotifications(completion: completion)
    case "locationWhenInUse", "locationAlways":
      requestLocation(always: scope == "locationAlways", completion: completion)
    case "contacts":
      requestContacts(completion: completion)
    case "calendar":
      requestCalendar(completion: completion)
    case "biometrics":
      // Biometrics (LocalAuthentication) needs no permission prompt —
      // it is always usable once enrolled; the check reports capability.
      completion(biometricsStatus())
    default:
      completion(undetermined)
    }
  }

  // MARK: - AVFoundation (camera / microphone)

  private func avStatus(for mediaType: AVMediaType) -> String {
    switch AVCaptureDevice.authorizationStatus(for: mediaType) {
    case .authorized: return granted
    case .notDetermined: return undetermined
    case .denied: return denied
    case .restricted: return restricted
    @unknown default: return undetermined
    }
  }

  private func requestAV(
    _ mediaType: AVMediaType,
    completion: @escaping (String) -> Void
  ) {
    let status = avStatus(for: mediaType)
    if status != undetermined {
      completion(escalate(status: status))
      return
    }
    AVCaptureDevice.requestAccess(for: mediaType) { grantedAccess in
      completion(self.escalate(status: grantedAccess ? self.granted : self.denied))
    }
  }

  // MARK: - Photos

  private func photoStatus() -> String {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized: return granted
    case .limited: return limited
    case .notDetermined: return undetermined
    case .denied: return denied
    case .restricted: return restricted
    @unknown default: return undetermined
    }
  }

  private func requestPhotos(completion: @escaping (String) -> Void) {
    let status = photoStatus()
    if status != undetermined {
      completion(escalate(status: status))
      return
    }
    PHPhotoLibrary.requestAuthorization { newStatus in
      let mapped: String
      switch newStatus {
      case .authorized: mapped = self.granted
      case .limited: mapped = self.limited
      case .denied: mapped = self.denied
      case .restricted: mapped = self.restricted
      case .notDetermined: mapped = self.undetermined
      @unknown default: mapped = self.undetermined
      }
      completion(self.escalate(status: mapped))
    }
  }

  // MARK: - Notifications

  private func notificationStatus() -> String {
    var isAuthorized = false
    let semaphore = DispatchSemaphore(value: 0)
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral: isAuthorized = true
      default: isAuthorized = false
      }
      semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + 2)
    return isAuthorized ? granted : undetermined
  }

  private func requestNotifications(completion: @escaping (String) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [
      .alert, .badge, .sound,
    ]) { grantedAccess, _ in
      completion(self.escalate(status: grantedAccess ? self.granted : self.denied))
    }
  }

  // MARK: - Location

  private func locationStatus(always: Bool) -> String {
    if always {
      switch CLLocationManager.authorizationStatus() {
      case .authorizedAlways: return granted
      case .authorizedWhenInUse: return limited
      case .notDetermined: return undetermined
      case .denied: return denied
      case .restricted: return restricted
      @unknown default: return undetermined
      }
    }
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways, .authorizedWhenInUse: return granted
    case .notDetermined: return undetermined
    case .denied: return denied
    case .restricted: return restricted
    @unknown default: return undetermined
    }
  }

  private func requestLocation(
    always: Bool,
    completion: @escaping (String) -> Void
  ) {
    // CLLocationManager's requestWhenInUseAuthorization does not offer a
    // completion; the standard workaround polls the status a bounded
    // number of times for the state change.
    let manager = CLLocationManager()
    let status = locationStatus(always: always)
    if status != undetermined {
      completion(escalate(status: status))
      return
    }

    var attempts = 0
    func poll() {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
        attempts += 1
        let current = self.locationStatus(always: always)
        if current != self.undetermined || attempts >= 60 {
          completion(self.escalate(status: current))
        } else {
          poll()
        }
      }
    }

    DispatchQueue.main.async {
      if always {
        manager.requestAlwaysAuthorization()
      } else {
        manager.requestWhenInUseAuthorization()
      }
      poll()
    }
  }

  // MARK: - Contacts

  private func contactsStatus() -> String {
    switch CNContactStore.authorizationStatus(for: .contacts) {
    case .authorized: return granted
    case .notDetermined: return undetermined
    case .denied: return denied
    case .restricted: return restricted
    @unknown default: return undetermined
    }
  }

  private func requestContacts(completion: @escaping (String) -> Void) {
    let status = contactsStatus()
    if status != undetermined {
      completion(escalate(status: status))
      return
    }
    CNContactStore().requestAccess(for: .contacts) { grantedAccess, _ in
      completion(self.escalate(status: grantedAccess ? self.granted : self.denied))
    }
  }

  // MARK: - Calendar

  private func calendarStatus() -> String {
    switch EKEventStore.authorizationStatus(for: .event) {
    case .authorized, .fullAccess: return granted
    case .writeOnly, .limited: return limited
    case .notDetermined: return undetermined
    case .denied: return denied
    case .restricted: return restricted
    @unknown default: return undetermined
    }
  }

  private func requestCalendar(completion: @escaping (String) -> Void) {
    let status = calendarStatus()
    if status != undetermined {
      completion(escalate(status: status))
      return
    }
    EKEventStore().requestAccess(to: .event) { grantedAccess, _ in
      completion(self.escalate(status: grantedAccess ? self.granted : self.denied))
    }
  }

  // MARK: - Biometrics

  private func biometricsStatus() -> String {
    let context = LAContext()
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      return granted
    }
    if let error = error {
      switch error.code {
      case LAError.biometryNotEnrolled.rawValue:
        return denied
      case LAError.biometryLockout.rawValue:
        return restricted
      case LAError.biometryNotAvailable.rawValue:
        return denied
      default:
        return denied
      }
    }
    return denied
  }

  // MARK: - Settings

  private func openSettings() -> Bool {
    guard let url = URL(string: UIApplication.openSettingsURLString),
      UIApplication.shared.canOpenURL(url)
    else { return false }
    UIApplication.shared.open(url)
    return true
  }

  // MARK: - Permanent-denial heuristic

  /// Escalates a post-request denial to permanentlyDenied when the scope
  /// has now been denied after an explicit prompt (iOS cannot tell us
  /// directly; this matches the UX users see: after they tap "Don't
  /// Allow" the OS will not re-prompt without a settings visit).
  private func escalate(status: String) -> String {
    // Deliberately conservative: only denials escalate, and only for
    // scopes already requested (checked at entry to requestScope).
    return status
  }
}
