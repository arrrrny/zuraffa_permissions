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
/// (AVFoundation, Photos, Contacts, EventKit, LocalAuthentication) and
/// routes notifications through the same UserNotifications framework
/// (UNUserNotificationCenter, macOS 10.14+); settings deep-links NSWorkspace.
/// The macOS desktop surface supports notifications natively; camera and
/// location are unsupported scopes — they report denied WITHOUT prompting
/// (issue #14, the adopting app's parity contract). The wire statuses
/// mirror the Dart vocabulary.
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
    case "camera", "locationWhenInUse", "locationAlways":
      // Unsupported on the macOS desktop surface: denied, without
      // prompting (issue #14) — check never prompts anyway.
      completion(denied)
    case "microphone":
      completion(avStatus(for: AVMediaType.audio))
    case "photos":
      completion(photoStatus())
    case "notifications":
      completion(notificationStatus())
    case "contacts":
      completion(contactsStatus())
    case "calendar":
      completion(calendarStatus())
    case "biometrics":
      completion(biometricsStatus())
    default:
      // Unknown scope: unsupported — denied without prompting, never
      // undetermined (the adopting app maps unknown to denied).
      completion(denied)
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
    case "camera", "locationWhenInUse", "locationAlways":
      // Unsupported on the macOS desktop surface: denied WITHOUT
      // prompting (issue #14) — no OS dialog may ever appear for them.
      completion(denied)
    case "microphone":
      requestAV(.audio, completion: completion)
    case "photos":
      requestPhotos(completion: completion)
    case "notifications":
      requestNotifications(completion: completion)
    case "contacts":
      requestContacts(completion: completion)
    case "calendar":
      requestCalendar(completion: completion)
    case "biometrics":
      completion(biometricsStatus())
    default:
      // Unknown scope: unsupported — denied without prompting, never
      // undetermined and never a prompt (the adopting app maps unknown
      // to denied).
      completion(denied)
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
  /// `check` reports the current authorization status: a decided denial
  /// is `denied` (the app routes it to settings), a never-decided scope
  /// is `undetermined`, and every grant — including the provisional and
  /// ephemeral cases — is `granted` (the app folds provisional at its
  /// own boundary).
  private func notificationStatus() -> String {
    let sem = DispatchSemaphore(value: 0)
    var status = undetermined
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral: status = self.granted
      case .denied: status = self.denied
      case .notDetermined: status = self.undetermined
      @unknown default: status = self.undetermined
      }
      sem.signal()
    }
    _ = sem.wait(timeout: .now() + 2)
    return status
  }

  private func requestNotifications(completion: @escaping (String) -> Void) {
    // Idempotent at the OS level: an already-decided scope resolves
    // immediately without a dialog, so a denied scope is never
    // re-prompted (FR-005) — only Settings can change the answer.
    UNUserNotificationCenter.current().requestAuthorization(options: [
      .alert, .badge, .sound,
    ]) { grantedAccess, _ in
      completion(grantedAccess ? self.granted : self.denied)
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

  /// Opens System Settings → Notifications — the pane where the app's
  /// notification permission is controlled. The adopting app's
  /// settings routing deep-links exactly this pane
  /// (`x-apple.systempreferences:com.apple.Notifications-Settings`);
  /// parity is the contract, not just "Settings opens" (issue #14).
  private func openSettings() -> Bool {
    guard
      let url = URL(
        string: "x-apple.systempreferences:com.apple.Notifications-Settings"
      )
    else { return false }
    return NSWorkspace.shared.open(url)
  }
}
