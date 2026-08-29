import 'package:zuraffa_permissions/zuraffa_permissions.dart';

import 'permission_platform_interface.dart';

/// Bridges the [ZuraffaPermissionsPlatform] native implementation onto
/// the package's pure-Dart [PermissionPort], so apps register the
/// real platform stack with the same DI seam as the in-memory tests:
///
/// ```dart
/// registerPermissionDependencies(
///   getIt,
///   port: MethodChannelPermissionAdapter(),
/// );
/// ```
///
/// Wire-status strings map onto the typed [PermissionStatus] enum; an
/// unknown wire value degrades to `undetermined` (forward-compatible:
/// a newer native SDK introducing a status never crashes older apps).
class MethodChannelPermissionAdapter implements PermissionPort {
  /// The platform instance backing this adapter (defaults to
  /// [ZuraffaPermissionsPlatform.instance]).
  final ZuraffaPermissionsPlatform platform;

  MethodChannelPermissionAdapter({
    ZuraffaPermissionsPlatform? platform,
  }) : platform = platform ?? ZuraffaPermissionsPlatform.instance;

  @override
  Future<PermissionStatus> check(String scope) async {
    final statuses = await platform.checkPermissions([scope]);
    return _toStatus(statuses[scope]);
  }

  @override
  Future<PermissionRequestResult> request(String scope) async {
    final statuses = await platform.requestPermissions([scope]);
    return PermissionRequestResult(
      scope: scope,
      status: _toStatus(statuses[scope]),
      requestedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<bool> openSettings() => platform.openSettings();

  static PermissionStatus _toStatus(String? wire) {
    switch (wire) {
      case PermissionWireStatus.granted:
        return PermissionStatus.granted;
      case PermissionWireStatus.denied:
        return PermissionStatus.denied;
      case PermissionWireStatus.permanentlyDenied:
        return PermissionStatus.permanentlyDenied;
      case PermissionWireStatus.restricted:
        return PermissionStatus.restricted;
      case PermissionWireStatus.limited:
        return PermissionStatus.limited;
      default:
        return PermissionStatus.undetermined;
    }
  }
}
