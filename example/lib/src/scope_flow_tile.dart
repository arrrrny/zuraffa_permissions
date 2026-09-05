import 'package:flutter/material.dart';
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

import 'matrix_controller.dart';
import 'status_theme.dart';

/// One scope's flow exerciser: what it does, its live status, and the
/// check → request → (open settings when permanently denied) actions —
/// every step through the public [PermissionService] API.
class ScopeFlowTile extends StatelessWidget {
  const ScopeFlowTile({super.key, required this.scope, required this.controller});

  final PermissionScope scope;
  final MatrixController controller;

  @override
  Widget build(BuildContext context) {
    final status = controller.statusOf(scope.id);
    final color = statusColor(status);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scope.id,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        scope.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  status.name,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                OutlinedButton.icon(
                  key: ValueKey('check-${scope.id}'),
                  onPressed: () => controller.check(scope.id),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Check'),
                ),
                FilledButton(
                  key: ValueKey('request-${scope.id}'),
                  onPressed: () => controller.request(scope.id),
                  child: const Text('Request'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
