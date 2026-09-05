import '../../domain/entities/enums/permission_status.dart';
import '../../domain/entities/permission_request_result/permission_request_result.dart';
import '../../domain/permission/permission_port.dart';

/// Pure-Dart default adapter (FR-006): an in-memory permission state
/// machine. Every scope starts `undetermined`; [grant]/[deny] mutate
/// state — the seams platform adapters and tests drive.
///
/// ```dart
/// final adapter = InMemoryPermissionAdapter()
///   ..grant('camera');
/// final port = adapter;
/// await port.check('camera'); // PermissionStatus.granted
/// ```
class InMemoryPermissionAdapter implements PermissionPort {
  final Map<String, PermissionStatus> _status = {};

  /// Prepares an outcome for the next [request] of [scope] — the value a
  /// platform prompt would return.
  final Map<String, PermissionStatus> _nextPromptOutcome = {};

  /// Whether [openSettings] reports success (default true).
  bool settingsLaunchable = true;

  /// Forces the status of [scope] (test/setup seam).
  void setStatus(String scope, PermissionStatus status) {
    _status[scope] = status;
  }

  /// Alias for `setStatus(scope, PermissionStatus.granted)`.
  void grant(String scope) => setStatus(scope, PermissionStatus.granted);

  /// Alias for `setStatus(scope, PermissionStatus.denied)`.
  void deny(String scope) => setStatus(scope, PermissionStatus.denied);

  /// Marks [scope] as permanently denied.
  void permanentlyDeny(String scope) =>
      setStatus(scope, PermissionStatus.permanentlyDenied);

  /// The status the next [request] of [scope] resolves with when the scope
  /// is currently `undetermined` (simulating the user's prompt answer).
  void setPromptOutcome(String scope, PermissionStatus outcome) {
    _nextPromptOutcome[scope] = outcome;
  }

  @override
  Future<PermissionStatus> check(String scope) async {
    return _status[scope] ?? PermissionStatus.undetermined;
  }

  @override
  Future<PermissionRequestResult> request(String scope) async {
    final current = await check(scope);
    PermissionStatus resolved;
    // Permanently denied never re-prompts (FR-005) — the OS would not show
    // a dialog either; the caller routes to settings.
    if (current == PermissionStatus.permanentlyDenied) {
      resolved = current;
    } else if (current == PermissionStatus.granted ||
        current == PermissionStatus.denied ||
        current == PermissionStatus.limited ||
        current == PermissionStatus.restricted) {
      // Already decided: return as-is (idempotent request).
      resolved = current;
    } else {
      // Undetermined: the "prompt". Resolve with the prepared outcome,
      // defaulting to granted (an optimistic in-memory default).
      resolved = _nextPromptOutcome.remove(scope) ?? PermissionStatus.granted;
      _status[scope] = resolved;
    }
    return PermissionRequestResult(
      scope: scope,
      status: resolved,
      requestedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<bool> openSettings() async => settingsLaunchable;
}
