import AVFoundation
import Contacts
import EventKit
import FlutterMacOS
import LocalAuthentication
import UserNotifications
import Photos
import AppKit

/// The macOS implementation of zuraffa_permissions.
///
/// macOS shares the framework-level permission surfaces with iOS
/// (AVFoundation, Photos, Contacts, EventKit, LocalAuthentication) but
/// routes notifications through NSUserNotification-style delegation and
/// settings through NSWorkspace. Location uses CoreLocation the same
/// way. The wire statuses mirror the Dart vocabulary.
public class ZuraffaPermissionsPlugin: NSObject, FlutterPlugin {
  private static let channelName = "zuraffa_permissions"

  // Wire statuses.
  private let granted = "granted"
  private let denied = "denied"
  private let permanentlyDenied = "permanentlyDenied"
  private let undetermined = "undetermined"
  private let restricted = "restricted"
  private let limited = "limited"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger
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
      completion(locationStatus())
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

  private func requestScope(scope: String, completion: @escaping (String) -> Void) {
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
      requestLocation(completion: completion)
    case "contacts":
      requestContacts(completion: completion)
    case "calendar":
      requestCalendar(completion: completion)
    case "biometrics":
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
      completion(status)
      return
    }
    AVCaptureDevice.requestAccess(for: mediaType) { grantedAccess in
      completion(grantedAccess ? self.granted : self.denied)
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
      completion(status)
      return
    }
    PHPhotoLibrary.requestAuthorization { newStatus in
      switch newStatus {
      case .authorized: completion(self.granted)
      case .limited: completion(self.limited)
      case .denied: completion(self.denied)
      case .restricted: completion(self.restricted)
      case .notDetermined: completion(self.undetermined)
      @unknown default: completion(self.undetermined)
      }
    }
  }

  // MARK: - Notifications

  /// macOS notification authorization runs through the same
  /// UserNotifications framework (UNUserNotificationCenter) on 10.14+.
  private func notificationStatus() -> String {
    let sem = DispatchSemaphore(value: 0)
    var isAuthorized = false
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral: isAuthorized = true
      default: isAuthorized = false
      }
      sem.signal()
    }
    _ = sem.wait(timeout: .now() + 2)
    return isAuthorized ? granted : undetermined
  }

  private func requestNotifications(completion: @escaping (String) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [
      .alert, .badge, .sound,
    ]) { grantedAccess, _ in
      completion(grantedAccess ? self.granted : self.denied)
    }
  }

  // MARK: - Location

  private func locationStatus() -> String {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways, .authorizedWhenInUse: return granted
    case .notDetermined: return undetermined
    case .denied: return denied
    case .restricted: return restricted
    @unknown default: return undetermined
    }
  }

  private func requestLocation(completion: @escaping (String) -> Void) {
    let status = locationStatus()
    if status != undetermined {
      completion(status)
      return
    }
    // Same bounded-poll workaround as iOS: request + poll the status. The
    // window is ~30s (200 × 0.15s) so a real user has time to respond to the
    // system dialog; a 9s window is too short and would wrongly report
    // undetermined for a slow tapper.
    let manager = CLLocationManager()
    var attempts = 0
    func poll() {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
        attempts += 1
        let current = self.locationStatus()
        if current != self.undetermined || attempts >= 200 {
          completion(current)
        } else {
          poll()
        }
      }
    }
    DispatchQueue.main.async {
      manager.requestWhenInUseAuthorization()
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
      completion(status)
      return
    }
    CNContactStore().requestAccess(for: .contacts) { grantedAccess, _ in
      completion(grantedAccess ? self.granted : self.denied)
    }
  }

  // MARK: - Calendar

  private func calendarStatus() -> String {
    let status = EKEventStore.authorizationStatus(for: .event)
    if #available(macOS 14.0, *) {
      switch status {
      case .authorized, .fullAccess: return granted
      case .writeOnly: return limited
      case .notDetermined: return undetermined
      case .denied: return denied
      case .restricted: return restricted
      @unknown default: return undetermined
      }
    } else {
      switch status {
      case .authorized: return granted
      case .notDetermined: return undetermined
      case .denied: return denied
      case .restricted: return restricted
      @unknown default: return undetermined
      }
    }
  }

  private func requestCalendar(completion: @escaping (String) -> Void) {
    let status = calendarStatus()
    if status != undetermined {
      completion(status)
      return
    }
    EKEventStore().requestAccess(to: .event) { grantedAccess, _ in
      completion(grantedAccess ? self.granted : self.denied)
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
      case LAError.biometryNotEnrolled.rawValue: return denied
      case LAError.biometryLockout.rawValue: return restricted
      case LAError.biometryNotAvailable.rawValue: return denied
      default: return denied
      }
    }
    return denied
  }

  // MARK: - Settings

  /// Opens System Preferences → Security & Privacy → Privacy → the
  /// app's pane on macOS.
  private func openSettings() -> Bool {
    let bundleId = Bundle.main.bundleIdentifier ?? ""
    let urlString =
      "x-apple.systempreferences:com.apple.preference.security?Privacy"
    guard let url = URL(string: urlString) else { return false }
    NSWorkspace.shared.open(url)
    _ = bundleId // The pane is app-agnostic on macOS; the URL opens it.
    return true
  }
}
