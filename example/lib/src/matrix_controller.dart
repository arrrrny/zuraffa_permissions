import 'package:flutter/foundation.dart';
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

/// Drives the outcome-matrix simulator: the scope × status grid state, the
/// per-scope check/request surface, and the flow log.
///
/// The controller never bypasses the public [PermissionService] API — the
/// simulator tab simply runs the package's own [InMemoryPermissionAdapter]
/// behind the port, which is what makes every scope × status outcome
/// demonstrable on demand.
class MatrixController extends ChangeNotifier {
  /// Creates a controller over [service] (a fresh in-memory service by
  /// default, so the simulator tab works with no platform at all).
  MatrixController({PermissionService? service})
    : service = service ?? PermissionService();

  /// The public permission API the whole panel drives.
  final PermissionService service;

  /// Current status per scope id (the matrix's visual state).
  final Map<String, PermissionStatus> _statuses = {};

  /// All registered scopes (built-ins plus customs), in registration order.
  List<PermissionScope> get scopes => service.scopes.toList();

  /// The current status of [scopeId]; `undetermined` until observed.
  PermissionStatus statusOf(String scopeId) =>
      _statuses[scopeId] ?? PermissionStatus.undetermined;

  /// The in-memory seam, present when the simulator drives the pure-Dart
  /// adapter. Null when the port is a real platform adapter.
  InMemoryPermissionAdapter? get _simAdapter => switch (service.port) {
    final InMemoryPermissionAdapter adapter => adapter,
    _ => null,
  };

  /// Whether the matrix cells can force statuses (simulator mode only).
  bool get canForceStatus => _simAdapter != null;

  /// Checks every scope's current status without prompting.
  Future<void> checkAll() async {
    for (final scope in scopes) {
      _statuses[scope.id] = await service.check(scope.id);
    }
    notifyListeners();
  }

  /// Places [scopeId] into [status] through the in-memory adapter seam —
  /// the cell the matrix grid taps. Any scope × status combination, on
  /// demand; a no-op against a real platform port.
  void forceStatus(String scopeId, PermissionStatus status) {
    final adapter = _simAdapter;
    if (adapter == null) return;
    adapter.setStatus(scopeId, status);
    _statuses[scopeId] = status;
    notifyListeners();
  }
}
