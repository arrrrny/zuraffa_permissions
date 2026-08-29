import 'package:zuraffa_permissions/zuraffa_permissions.dart';
import 'package:zuraffa_permissions_platform_interface/zuraffa_permissions_platform_interface.dart';

/// The Android entrypoint: registers the MethodChannel implementation with
/// the shared platform interface so `MethodChannelPermissionAdapter` routes to
/// the Kotlin plugin, and wires the real [PermissionPort] so any app depending
/// on this package gets OS permissions by default.
class ZuraffaPermissionsAndroid {
  static void registerWith() {
    ZuraffaPermissionsPlatform.instance = MethodChannelZuraffaPermissions();
    setPlatformPermissionPortFactory(() => MethodChannelPermissionAdapter());
  }
}
