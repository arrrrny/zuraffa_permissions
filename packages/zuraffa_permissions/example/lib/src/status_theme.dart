import 'package:flutter/material.dart';
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

/// The shared status palette: one color per [PermissionStatus], used by the
/// matrix cells, the status chips, and the flow log entries.
Color statusColor(PermissionStatus status) => switch (status) {
  PermissionStatus.granted => Colors.green.shade700,
  PermissionStatus.denied => Colors.orange.shade800,
  PermissionStatus.permanentlyDenied => Colors.red.shade700,
  PermissionStatus.undetermined => Colors.blueGrey,
  PermissionStatus.restricted => Colors.deepPurple,
  PermissionStatus.limited => Colors.teal.shade700,
};

/// One glyph per [PermissionStatus], used by the chips and log entries.
IconData statusIcon(PermissionStatus status) => switch (status) {
  PermissionStatus.granted => Icons.check_circle_outline,
  PermissionStatus.denied => Icons.cancel_outlined,
  PermissionStatus.permanentlyDenied => Icons.block,
  PermissionStatus.undetermined => Icons.help_outline,
  PermissionStatus.restricted => Icons.lock_outline,
  PermissionStatus.limited => Icons.filter_center_focus,
};
