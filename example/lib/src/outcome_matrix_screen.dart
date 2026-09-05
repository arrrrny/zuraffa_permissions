import 'package:flutter/material.dart';
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

import 'flow_log_view.dart';
import 'live_permission_panel.dart';
import 'matrix_controller.dart';
import 'matrix_grid.dart';
import 'scope_flow_tile.dart';

/// The outcome-matrix home (issue #7): the simulator tab — scope × status
/// matrix, per-scope exerciser, flow log — and the live tab, which runs the
/// same public [PermissionService] API against the GetIt-registered stack (the
/// federated platform adapters where they exist, the pure-Dart fallback
/// elsewhere).
class OutcomeMatrixScreen extends StatefulWidget {
  const OutcomeMatrixScreen({super.key, this.matrixService, this.liveService});

  /// Service behind the simulator tab; defaults to a fresh in-memory service.
  final PermissionService? matrixService;

  /// Service behind the live tab; defaults to the instance GetIt registered.
  final PermissionService? liveService;

  @override
  State<OutcomeMatrixScreen> createState() => _OutcomeMatrixScreenState();
}

class _OutcomeMatrixScreenState extends State<OutcomeMatrixScreen> {
  late final MatrixController _controller = MatrixController(
    service: widget.matrixService,
  );

  @override
  void initState() {
    super.initState();
    _controller.checkAll();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('zuraffa_permissions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Matrix'),
              Tab(text: 'Live'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MatrixPanel(controller: _controller),
            LivePermissionPanel(service: widget.liveService),
          ],
        ),
      ),
    );
  }
}

/// The simulator tab: every scope × status outcome, on demand.
class MatrixPanel extends StatelessWidget {
  const MatrixPanel({super.key, required this.controller});

  final MatrixController controller;

  @override
  Widget build(BuildContext context) {
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
                  'Outcome matrix — every scope × status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a cell to place a scope in that status, then request it '
                  'and watch the flow: check → request → openSettings when '
                  'permanently denied.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(
                      controller.canForceStatus
                          ? Icons.science_outlined
                          : Icons.devices,
                      size: 16,
                    ),
                    label: Text(
                      controller.canForceStatus
                          ? 'simulator: in-memory adapter'
                          : 'live port (cells disabled)',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: MatrixGrid(controller: controller),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                  child: Text(
                    'Permission flow — check → request → openSettings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) => Column(
                    children: [
                      for (final scope in controller.scopes)
                        ScopeFlowTile(scope: scope, controller: controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                  child: Text(
                    'Flow log',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FlowLogView(controller: controller),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
