import 'package:flutter/services.dart';

import 'permission_platform_interface.dart';

/// The MethodChannel client half: what the native Kotlin/Swift plugins
/// implement. Platform packages typically re-export this as their
/// registration target so the channel name and protocol stay identical
/// across platforms.
class MethodChannelZuraffaPermissions extends ZuraffaPermissionsPlatform {
  /// The shared channel — every platform package registers the same
  /// name (`zuraffa_permissions`).
  static const MethodChannel channel = MethodChannel('zuraffa_permissions');

  @override
  Future<Map<String, String>> checkPermissions(List<String> scopes) async {
    final raw = await channel.invokeMethod<Map<Object?, Object?>>(
      'checkPermissions',
      scopes,
    );
    return _normalize(raw);
  }

  @override
  Future<Map<String, String>> requestPermissions(List<String> scopes) async {
    final raw = await channel.invokeMethod<Map<Object?, Object?>>(
      'requestPermissions',
      scopes,
    );
    return _normalize(raw);
  }

  @override
  Future<bool> openSettings() async {
    final launched = await channel.invokeMethod<bool>('openSettings');
    return launched ?? false;
  }

  static Map<String, String> _normalize(Map<Object?, Object?>? raw) {
    if (raw == null) return const {};
    return {
      for (final entry in raw.entries)
        '${entry.key}': '${entry.value}',
    };
  }
}
