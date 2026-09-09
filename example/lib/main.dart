import 'package:flutter/material.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

import 'src/outcome_matrix_screen.dart';

/// Host app for the zuraffa_permissions federated plugin: the outcome-matrix
/// demonstrator (issue #7).
///
/// It wires the real (method-channel) [PermissionPort] onto GetIt via
/// [registerPermissionDependencies] — the federated platform adapters
/// (`zuraffa_permissions_android` / `_ios` / `_macos`) register their port
/// factory when Flutter starts the app, so the live tab exercises the actual OS
/// permission flow. The simulator tab drives the package's pure-Dart
/// [InMemoryPermissionAdapter] so every scope × status outcome can be forced,
/// requested, and observed on demand — including the combinations a real OS
/// would never hand you.
void main() {
  registerPermissionDependencies(GetIt.instance);
  runApp(const PermissionApp());
}

/// The example app root.
///
/// Both tabs share the public [PermissionService] API; only the adapter behind
/// the port differs (in-memory simulator vs. the GetIt-registered live stack).
class PermissionApp extends StatelessWidget {
  const PermissionApp({super.key, this.matrixService, this.liveService});

  /// Service behind the simulator tab; defaults to a fresh in-memory service.
  final PermissionService? matrixService;

  /// Service behind the live tab; defaults to the instance GetIt registered.
  final PermissionService? liveService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zuraffa_permissions',
      theme: ThemeData(useMaterial3: true),
      home: OutcomeMatrixScreen(
        matrixService: matrixService,
        liveService: liveService,
      ),
    );
  }
}
