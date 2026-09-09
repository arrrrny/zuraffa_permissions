import 'package:zuraffa/zuraffa.dart';

import '../../entities/permission/permission.dart';
import '../../entities/role_permission/role_permission.dart';
import '../../entities/user_permission/user_permission.dart';
import '../../entities/user_role/user_role.dart';
import '../../repositories/permission_repository.dart';
import '../../repositories/role_permission_repository.dart';
import '../../repositories/user_permission_repository.dart';
import '../../repositories/user_role_repository.dart';

/// Effective-permission query (FR-003): which user's permissions to
/// resolve.
class ListUserPermissionsParams {
  const ListUserPermissionsParams({required this.userId});

  final String userId;
}

/// Access control (FR-003): resolves a user's effective permissions by
/// merging direct grants with permissions inherited through assigned
/// roles, deduplicated by permission id.
class ListUserPermissionsUseCase
    extends UseCase<List<Permission>, ListUserPermissionsParams> {
  ListUserPermissionsUseCase(
    this._userPermissions,
    this._userRoles,
    this._rolePermissions,
    this._permissions,
  );

  final UserPermissionRepository _userPermissions;
  final UserRoleRepository _userRoles;
  final RolePermissionRepository _rolePermissions;
  final PermissionRepository _permissions;

  @override
  Future<List<Permission>> execute(
    ListUserPermissionsParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();

    final permissionIds = <String>{};

    final directGrants = await _userPermissions.getList(
      ListQueryParams<UserPermission>(params: {'userId': params.userId}),
    );
    permissionIds.addAll(directGrants.map((g) => g.permissionId));

    final assignments = await _userRoles.getList(
      ListQueryParams<UserRole>(params: {'userId': params.userId}),
    );
    for (final assignment in assignments) {
      final memberships = await _rolePermissions.getList(
        ListQueryParams<RolePermission>(params: {'roleId': assignment.roleId}),
      );
      permissionIds.addAll(memberships.map((m) => m.permissionId));
    }

    final resolved = <Permission>[];
    for (final id in permissionIds) {
      resolved.add(
        await _permissions.get(QueryParams<Permission>(params: {'id': id})),
      );
    }
    return resolved;
  }
}
