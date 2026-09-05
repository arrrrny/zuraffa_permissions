import 'package:flutter/material.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

/// Host app for the zuraffa_permissions federated plugin.
///
/// It wires the real (method-channel) [PermissionPort] onto GetIt via
/// [registerPermissionDependencies] and lets you check/request every scope
/// against the actual OS, so the native Android/iOS/macOS plugins can be
/// exercised on a device — not just the in-memory Dart adapter.
void main() {
  registerPermissionDependencies(GetIt.instance);
  runApp(const PermissionApp());
}

class PermissionApp extends StatelessWidget {
  const PermissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zuraffa_permissions',
      theme: ThemeData(useMaterial3: true),
      home: const PermissionHome(),
    );
  }
}

class PermissionHome extends StatefulWidget {
  const PermissionHome({super.key});

  @override
  State<PermissionHome> createState() => _PermissionHomeState();
}

class _PermissionHomeState extends State<PermissionHome> {
  final PermissionService _service = GetIt.instance<PermissionService>();
  final Map<String, PermissionStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    final entries = <String, PermissionStatus>{};
    for (final scope in _service.scopes) {
      entries[scope.id] = await _service.check(scope.id);
    }
    setState(() {
      _statuses
        ..clear()
        ..addAll(entries);
    });
  }

  Future<void> _request(String id) async {
    final result = await _service.request(id);
    setState(() => _statuses[id] = result.status);
  }

  Future<void> _openSettings() async {
    final launched = await _service.openSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(launched ? 'Settings opened' : 'Settings unavailable'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scopes = _service.scopes.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('zuraffa_permissions'),
        actions: [
          IconButton(onPressed: _refreshAll, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: scopes.length,
        itemBuilder: (context, index) {
          final scope = scopes[index];
          final status = _statuses[scope.id] ?? PermissionStatus.undetermined;
          return ListTile(
            title: Text(scope.id),
            subtitle: Text(scope.description),
            trailing: Chip(label: Text(status.name)),
            onTap: () => _request(scope.id),
          );
        },
      ),
    );
  }
}
