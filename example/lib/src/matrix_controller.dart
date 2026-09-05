import 'package:flutter/foundation.dart';
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

/// One chronological outcome-matrix event: what happened, to which scope, and
/// the from → to statuses it transitioned through.
enum FlowEventKind { check, forced, requested, settingsOpened }

class FlowEvent {
  const FlowEvent({
    required this.kind,
    this.scope,
    this.from,
    this.to,
    this.launched,
  });

  final FlowEventKind kind;
  final String? scope;
  final PermissionStatus? from;
  final PermissionStatus? to;
  final bool? launched;

  /// The one-line record the flow log renders, e.g.
  /// `request camera: undetermined → denied`.
  String get label => switch (kind) {
    FlowEventKind.check => 'check $scope → ${to!.name}',
    FlowEventKind.forced => 'set $scope: ${from!.name} → ${to!.name}',
    FlowEventKind.requested => 'request $scope: ${from!.name} → ${to!.name}',
    FlowEventKind.settingsOpened =>
      (launched ?? false) ? 'openSettings: launched' : 'openSettings: unavailable',
  };
}

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

  /// The chronological flow log (what the matrix did, and how statuses
  /// transitioned) — the AC-003 transition record.
  final List<FlowEvent> events = [];

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
      await check(scope.id);
    }
  }

  /// Re-checks a single scope's current status without prompting.
  Future<void> check(String scopeId) async {
    final status = await service.check(scopeId);
    events.add(FlowEvent(kind: FlowEventKind.check, scope: scopeId, to: status));
    _statuses[scopeId] = status;
    notifyListeners();
  }

  /// Places [scopeId] into [status] through the in-memory adapter seam —
  /// the cell the matrix grid taps. Any scope × status combination, on
  /// demand; a no-op against a real platform port.
  void forceStatus(String scopeId, PermissionStatus status) {
    final adapter = _simAdapter;
    if (adapter == null) return;
    final from = statusOf(scopeId);
    adapter.setStatus(scopeId, status);
    _statuses[scopeId] = status;
    events.add(
      FlowEvent(kind: FlowEventKind.forced, scope: scopeId, from: from, to: status),
    );
    notifyListeners();
  }

  /// Requests [scopeId] through the public port — the real flow, whatever
  /// adapter sits behind it: an undetermined scope resolves the prompt
  /// outcome, an already-decided one returns unchanged, and a
  /// permanently-denied one does not re-prompt (the caller routes to
  /// [openSettings]).
  Future<PermissionRequestResult> request(String scopeId) async {
    final from = statusOf(scopeId);
    final result = await service.request(scopeId);
    events.add(
      FlowEvent(
        kind: FlowEventKind.requested,
        scope: scopeId,
        from: from,
        to: result.status,
      ),
    );
    _statuses[scopeId] = result.status;
    notifyListeners();
    return result;
  }

  /// Opens the OS settings page through the port; reports whether it could
  /// be launched.
  Future<bool> openSettings() async {
    final launched = await service.openSettings();
    events.add(FlowEvent(kind: FlowEventKind.settingsOpened, launched: launched));
    notifyListeners();
    return launched;
  }
}
