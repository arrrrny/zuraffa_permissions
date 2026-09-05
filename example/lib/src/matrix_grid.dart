import 'package:flutter/material.dart';
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

import 'matrix_controller.dart';
import 'status_theme.dart';

/// The outcome matrix: one row per registered scope, one column per
/// [PermissionStatus] (in enum order).
///
/// Tapping a cell places the scope in that status through the simulator's
/// in-memory seam — every scope × status combination on demand — and the
/// active cell carries the row's marker so the current outcome is always
/// visible at a glance.
class MatrixGrid extends StatelessWidget {
  const MatrixGrid({super.key, required this.controller});

  final MatrixController controller;

  static const double _labelWidth = 168;
  static const double _cellWidth = 92;
  static const double _rowHeight = 46;

  @override
  Widget build(BuildContext context) {
    final statuses = PermissionStatus.values;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _labelWidth + _cellWidth * statuses.length,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeaderRow(statuses: statuses),
              const Divider(height: 1),
              for (final scope in controller.scopes)
                _ScopeRow(
                  scope: scope,
                  controller: controller,
                  statuses: statuses,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.statuses});

  final List<PermissionStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SizedBox(
            width: MatrixGrid._labelWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Scope',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          for (final status in statuses)
            SizedBox(
              width: MatrixGrid._cellWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  status.name,
                  key: ValueKey('matrix-col-${status.name}'),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor(status),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScopeRow extends StatelessWidget {
  const _ScopeRow({
    required this.scope,
    required this.controller,
    required this.statuses,
  });

  final PermissionScope scope;
  final MatrixController controller;
  final List<PermissionStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final current = controller.statusOf(scope.id);
    final canForce = controller.canForceStatus;
    return SizedBox(
      height: MatrixGrid._rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: MatrixGrid._labelWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scope.id,
                    key: ValueKey('matrix-scope-${scope.id}'),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  StatusBadge(scopeId: scope.id, status: current),
                ],
              ),
            ),
          ),
          for (final status in statuses)
            _StatusCell(
              scopeId: scope.id,
              status: status,
              active: status == current,
              onTap: canForce ? () => controller.forceStatus(scope.id, status) : null,
            ),
        ],
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({
    required this.scopeId,
    required this.status,
    required this.active,
    required this.onTap,
  });

  final String scopeId;
  final PermissionStatus status;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return InkResponse(
      key: ValueKey('matrix-cell-$scopeId-${status.name}'),
      onTap: onTap,
      child: Container(
        width: MatrixGrid._cellWidth,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.18) : null,
          border: Border(
            right: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
          ),
        ),
        child: active
            ? Container(
                key: ValueKey('matrix-active-dot-$scopeId'),
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              )
            : null,
      ),
    );
  }
}

/// The colored status badge shown next to every scope id.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.scopeId, required this.status});

  final String scopeId;
  final PermissionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      key: ValueKey('status-chip-$scopeId'),
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
          Flexible(
            child: Text(
              status.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
