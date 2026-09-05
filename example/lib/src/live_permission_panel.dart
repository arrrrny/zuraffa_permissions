import 'package:flutter/material.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

import 'status_theme.dart';

/// The live tab: the same public [PermissionService] API against the
/// GetIt-registered stack — the federated platform adapters
/// (method-channel on Android/iOS/macOS) where they exist, the pure-Dart
/// in-memory fallback elsewhere.
///
/// A production `main()` calls `registerPermissionDependencies` before
/// `runApp`, so this panel's default service is whatever the platform
/// packages registered. Tests inject their own.
class LivePermissionPanel extends StatefulWidget {
  const LivePermissionPanel({super.key, this.service});

  final PermissionService? service;

  @override
  State<LivePermissionPanel> createState() => _LivePermissionPanelState();
}

class _LivePermissionPanelState extends State<LivePermissionPanel> {
  PermissionService? _resolved;
  final Map<String, PermissionStatus> _statuses = {};

  PermissionService get _service =>
      _resolved ??= widget.service ?? GetIt.instance<PermissionService>();

  @override
  void initState() {
    super.initState();
    _checkAll();
  }

  Future<void> _checkAll() async {
    final statuses = <String, PermissionStatus>{};
    for (final scope in _service.scopes) {
      statuses[scope.id] = await _service.check(scope.id);
    }
    if (!mounted) return;
    setState(() => _statuses.addAll(statuses));
  }

  Future<void> _check(String scopeId) async {
    final status = await _service.check(scopeId);
    if (!mounted) return;
    setState(() => _statuses[scopeId] = status);
  }

  Future<void> _request(String scopeId) async {
    final result = await _service.request(scopeId);
    if (!mounted) return;
    setState(() => _statuses[scopeId] = result.status);
  }

  Future<void> _openSettings(String scopeId) async {
    final launched = await _service.openSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(launched ? 'Settings opened' : 'Settings unavailable'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scopes = _service.scopes.toList();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live permissions — the federated platform adapters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Runs the stack registerPermissionDependencies wired: the '
                  'method-channel adapters on Android/iOS/macOS, the pure-Dart '
                  'in-memory fallback elsewhere. Requests hit the real OS.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: const Icon(Icons.hub_outlined, size: 16),
                    label: Text('port: ${_service.port.runtimeType}'),
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final scope in scopes)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scope.id,
                          key: ValueKey('live-scope-${scope.id}'),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      _LiveStatusBadge(
                        scopeId: scope.id,
                        status:
                            _statuses[scope.id] ?? PermissionStatus.undetermined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      OutlinedButton.icon(
                        key: ValueKey('live-check-${scope.id}'),
                        onPressed: () => _check(scope.id),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Check'),
                      ),
                      FilledButton(
                        key: ValueKey('live-request-${scope.id}'),
                        onPressed: () => _request(scope.id),
                        child: const Text('Request'),
                      ),
                      if (_statuses[scope.id] ==
                          PermissionStatus.permanentlyDenied)
                        FilledButton.icon(
                          key: ValueKey('live-settings-${scope.id}'),
                          style: FilledButton.styleFrom(
                            backgroundColor: statusColor(
                              PermissionStatus.permanentlyDenied,
                            ),
                          ),
                          onPressed: () => _openSettings(scope.id),
                          icon: const Icon(Icons.settings, size: 16),
                          label: const Text('Open Settings'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _LiveStatusBadge extends StatelessWidget {
  const _LiveStatusBadge({required this.scopeId, required this.status});

  final String scopeId;
  final PermissionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      key: ValueKey('live-status-$scopeId'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(status), size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            status.name,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
