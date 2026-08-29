/// zuraffa_permissions — typed permission requests for the Zuraffa
/// ecosystem.
///
/// The permission layer every capability package builds on:
/// a [PermissionPort] (check/request/openSettings) over typed
/// [PermissionScope] entities, ten built-in scopes, a
/// [PermissionScopeRegistry] for customs, and an in-memory default
/// adapter so permission logic is testable in pure Dart. Platform
/// adapters (zuraffa_permissions_android/ios/…) implement the port as
/// federated siblings.
///
/// ```dart
/// final permissions = PermissionService();
/// final status = await permissions.request('camera');
/// if (status == PermissionStatus.permanentlyDenied) {
///   await permissions.openSettings();
/// }
/// ```
library;

export 'src/domain/permission/permission_port.dart';
export 'src/data/permission/in_memory_permission_adapter.dart';
export 'src/domain/entities/enums/permission_status.dart';
export 'src/domain/entities/permission_request_result/permission_request_result.dart';
export 'src/domain/entities/permission_scope/permission_scope.dart';
export 'src/domain/entities/scopes/built_in_permission_scopes.dart';
export 'src/permission_service.dart';
