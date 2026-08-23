import '../entities/enums/permission_status.dart';

/// The technology-agnostic permission contract (FR-001).
///
/// Consumers program against this port; platform adapters
/// (zuraffa_permissions_android/ios/…) implement it. The default
/// [InMemoryPermissionAdapter] is a pure-Dart state machine so the whole
/// package — and every app's permission logic — tests without a platform.
abstract class PermissionPort {
  /// Returns the current status of [scope] without prompting.
  Future<PermissionStatus> check(String scope);

  /// Requests [scope]:
  /// - `undetermined` → prompts (adapter-defined) and returns the outcome.
  /// - `granted`/`denied` → returns the current status unchanged.
  /// - `permanentlyDenied` → returns the status WITHOUT prompting (FR-005);
  ///   the caller decides whether to route the user to [openSettings].
  Future<PermissionStatus> request(String scope);

  /// Opens the OS settings page where the user can change permissions.
  /// Returns whether settings could be launched at all.
  Future<bool> openSettings();
}
