import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The string statuses exchanged over the MethodChannel (stable wire
/// vocabulary — the typed enum lives in the app-facing package).
abstract final class PermissionWireStatus {
  static const granted = 'granted';
  static const denied = 'denied';
  static const permanentlyDenied = 'permanentlyDenied';
  static const undetermined = 'undetermined';
  static const restricted = 'restricted';
  static const limited = 'limited';
}

/// The native contract every zuraffa_permissions platform package
/// implements: check/request permissions by scope id, open the OS
/// settings page.
///
/// The channel protocol (method → arguments → result):
/// - `checkPermissions` → `[List<String> scopes]` →
///   `Map<Object?, Object?>` scope → wire status string.
/// - `requestPermissions` → `[List<String> scopes]` →
///   `Map<Object?, Object?>` scope → wire status string.
/// - `openSettings` → none → `bool`.
abstract class ZuraffaPermissionsPlatform extends PlatformInterface {
  /// Constructs a platform interface.
  ZuraffaPermissionsPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZuraffaPermissionsPlatform _instance =
      DefaultZuraffaPermissionsPlatform();

  /// The default instance (overridden by platform packages at
  /// registration time via [instance = ...]).
  static ZuraffaPermissionsPlatform get instance => _instance;

  /// Platform packages set this to their native implementation.
  static set instance(ZuraffaPermissionsPlatform value) {
    PlatformInterface.verifyToken(value, _token);
    _instance = value;
  }

  /// Returns the current status for every scope (wire status strings,
  /// absent scopes map to `undetermined`).
  Future<Map<String, String>> checkPermissions(List<String> scopes);

  /// Requests every scope and returns the resulting statuses. Native
  /// implementations must resolve every requested scope exactly once
  /// (granted/denied/permanentlyDenied per the OS verdict).
  Future<Map<String, String>> requestPermissions(List<String> scopes);

  /// Opens the OS settings page; returns whether it could be launched.
  Future<bool> openSettings();
}

/// The fallback used when no platform package registered — reports
/// every scope as undetermined and cannot open settings. This makes
/// the interface safe to depend on before a platform package loads
/// (tests, pure-Dart hosts).
class DefaultZuraffaPermissionsPlatform extends ZuraffaPermissionsPlatform {
  @override
  Future<Map<String, String>> checkPermissions(List<String> scopes) async => {
    for (final scope in scopes) scope: PermissionWireStatus.undetermined,
  };

  @override
  Future<Map<String, String>> requestPermissions(List<String> scopes) async => {
    for (final scope in scopes) scope: PermissionWireStatus.undetermined,
  };

  @override
  Future<bool> openSettings() async => false;
}
