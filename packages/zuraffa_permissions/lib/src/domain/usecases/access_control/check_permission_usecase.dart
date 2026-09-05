import 'package:zuraffa/zuraffa.dart';

import '../../entities/role_permission/role_permission.dart';
import '../../entities/user_permission/user_permission.dart';
import '../../entities/user_role/user_role.dart';
import '../../repositories/role_permission_repository.dart';
import '../../repositories/user_permission_repository.dart';
import '../../repositories/user_role_repository.dart';

/// Access control query (FR-003): which user + permission to check.
class CheckPermissionParams {
  const CheckPermissionParams({
    required this.userId,
    required this.permissionId,
  });

  final String userId;
  final String permissionId;
}

/// Permission check (FR-003): whether [CheckPermissionParams.userId]
/// holds [CheckPermissionParams.permissionId] — directly or through any
/// assigned role. Pure use case over the permission store; no statics,
/// no Flutter.
class CheckPermissionUseCase extends UseCase<bool, CheckPermissionParams> {
  CheckPermissionUseCase(
    this._userPermissions,
    this._userRoles,
    this._rolePermissions,
  );

  final UserPermissionRepository _userPermissions;
  final UserRoleRepository _userRoles;
  final RolePermissionRepository _rolePermissions;

  @override
  Future<bool> execute(
    CheckPermissionParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();

    final directGrants = await _userPermissions.getList(
      ListQueryParams<UserPermission>(
        params: {'userId': params.userId, 'permissionId': params.permissionId},
      ),
    );
    if (directGrants.isNotEmpty) return true;

    final assignments = await _userRoles.getList(
      ListQueryParams<UserRole>(params: {'userId': params.userId}),
    );
    for (final assignment in assignments) {
      final memberships = await _rolePermissions.getList(
        ListQueryParams<RolePermission>(
          params: {
            'roleId': assignment.roleId,
            'permissionId': params.permissionId,
          },
        ),
      );
      if (memberships.isNotEmpty) return true;
    }
    return false;
  }
}
