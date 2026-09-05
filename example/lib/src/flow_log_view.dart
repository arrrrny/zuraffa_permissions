import 'package:flutter/material.dart';

import 'matrix_controller.dart';

/// The chronological flow log: every check, forced status, request, and
/// settings launch the matrix performed, with its from → to transition —
/// the outcome matrix's status-transition record (AC-003).
class FlowLogView extends StatelessWidget {
  const FlowLogView({super.key, required this.controller});

  final MatrixController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.events.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: Text('No events yet — tap a cell or a request button.'),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < controller.events.length; i++)
              Padding(
                key: ValueKey('flow-entry-$i'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  children: [
                    Icon(_iconOf(controller.events[i].kind), size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        controller.events[i].label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  IconData _iconOf(FlowEventKind kind) => switch (kind) {
    FlowEventKind.check => Icons.search,
    FlowEventKind.forced => Icons.touch_app,
    FlowEventKind.requested => Icons.arrow_circle_right_outlined,
    FlowEventKind.settingsOpened => Icons.settings_outlined,
  };
}
