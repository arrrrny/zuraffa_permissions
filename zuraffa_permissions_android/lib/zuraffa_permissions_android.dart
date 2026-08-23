import 'package:flutter/services.dart';
import 'package:zuraffa_permissions_platform_interface/zuraffa_permissions_platform_interface.dart';

/// The Android entrypoint: registers the MethodChannel implementation
/// with the shared platform interface so `MethodChannelPermissionAdapter`
/// routes to the Kotlin plugin.
class ZuraffaPermissionsAndroid {
  static void registerWith() {
    ZuraffaPermissionsPlatform.instance =
        MethodChannelZuraffaPermissions();
  }
}

// Silence the unused-import warning: MethodChannel is referenced by the
// platform interface's channel definition the registration binds to.
// ignore: unused_element
final MethodChannel _channelReference =
    MethodChannelZuraffaPermissions.channel;
