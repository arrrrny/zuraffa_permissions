/// The platform interface for zuraffa_permissions: the MethodChannel
/// protocol every native implementation (Android/iOS/macOS) speaks, and
/// the [MethodChannelPermissionAdapter] that bridges it onto the
/// package's [PermissionPort].
library;

export 'src/method_channel_zuraffa_permissions.dart';
export 'src/permission_platform_interface.dart';
export 'src/method_channel_permission_adapter.dart';
