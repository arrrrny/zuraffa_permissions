import 'package:flutter/services.dart';
import 'package:zuraffa_permissions_platform_interface/zuraffa_permissions_platform_interface.dart';

/// The iOS entrypoint: binds the shared MethodChannel implementation
/// (the native Swift plugin registers the same channel name) to the
/// platform interface.
class ZuraffaPermissionsIOS {
  static void registerWith() {
    ZuraffaPermissionsPlatform.instance =
        MethodChannelZuraffaPermissions();
  }
}

// Channel reference kept so the entry point visibly binds to the
// protocol the Swift side implements.
// ignore: unused_element
final MethodChannel _channelReference =
    MethodChannelZuraffaPermissions.channel;
