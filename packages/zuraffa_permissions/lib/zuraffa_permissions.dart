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
/// Built on the Zuraffa framework (issue #668, EPIC #214): permission
/// and role domain objects are Zuraffa entities (FR-001), persistence
/// flows through Zuraffa datasources/repositories (FR-002), and all
/// business logic — permission checks, role assignment, access control
/// — runs through Zuraffa use cases (FR-003) resolvable from GetIt
/// (FR-004).
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
export 'src/domain/entities/permission/permission.dart';
export 'src/domain/entities/role/role.dart';
export 'src/domain/entities/user_permission/user_permission.dart';
export 'src/domain/entities/user_role/user_role.dart';
export 'src/domain/entities/role_permission/role_permission.dart';
export 'src/domain/repositories/permission_repository.dart';
export 'src/domain/repositories/role_repository.dart';
export 'src/domain/repositories/user_permission_repository.dart';
export 'src/domain/repositories/user_role_repository.dart';
export 'src/domain/repositories/role_permission_repository.dart';
export 'src/domain/usecases/permission/create_permission_usecase.dart';
export 'src/domain/usecases/role/create_role_usecase.dart';
export 'src/domain/usecases/role_permission/grant_permission_to_role_usecase.dart';
export 'src/domain/usecases/user_permission/grant_permission_to_user_usecase.dart';
export 'src/domain/usecases/user_permission/revoke_permission_from_user_usecase.dart';
export 'src/domain/usecases/user_role/assign_role_to_user_usecase.dart';
export 'src/domain/usecases/user_role/remove_role_from_user_usecase.dart';
export 'src/domain/usecases/access_control/check_permission_usecase.dart';
export 'src/domain/usecases/access_control/list_user_permissions_usecase.dart';
export 'src/data/datasources/permission_store/in_memory_permission_store.dart';
export 'src/permission_service.dart';
