import 'package:zuraffa/zuraffa.dart' hide Role;

import '../../../domain/entities/permission/permission.dart';
import '../../../domain/entities/role/role.dart';
import '../../../domain/entities/role_permission/role_permission.dart';
import '../../../domain/entities/user_permission/user_permission.dart';
import '../../../domain/entities/user_role/user_role.dart';
import '../permission/permission_datasource.dart';
import '../role/role_datasource.dart';
import '../role_permission/role_permission_datasource.dart';
import '../user_permission/user_permission_datasource.dart';
import '../user_role/user_role_datasource.dart';

/// Pure-Dart in-memory permission store (FR-002): the shared state
/// behind the five in-memory datasource adapters, so the whole access
/// control layer — and every host app's permission logic — runs and
/// tests without a platform.
///
/// Used as the default store wired by `registerPermissionDependencies`;
/// swap in backed implementations of the same datasource contracts for
/// production persistence.
class InMemoryPermissionStore {
  final Map<String, Permission> permissions = {};
  final Map<String, Role> roles = {};
  final Map<String, UserPermission> userPermissions = {};
  final Map<String, UserRole> userRoles = {};
  final Map<String, RolePermission> rolePermissions = {};

  /// Removes every stored permission, role, grant, assignment and
  /// membership (useful between tests).
  void clear() {
    permissions.clear();
    roles.clear();
    userPermissions.clear();
    userRoles.clear();
    rolePermissions.clear();
  }
}

/// Shared helpers for the in-memory datasource adapters.
class InMemoryStoreOps {
  static ZuraffaPlatformException notFound(String what) =>
      ZuraffaPlatformException(
        code: 'not_found',
        message: 'No $what matches the query.',
      );

  static ZuraffaPlatformException duplicate(String what) =>
      ZuraffaPlatformException(
        code: 'duplicate_id',
        message: '$what already exists.',
      );

  static String require(Map<String, dynamic>? params, String key) {
    final value = params?[key];
    if (value is String && value.isNotEmpty) return value;
    throw ZuraffaPlatformException(
      code: 'invalid_query',
      message: 'Query is missing the required "$key" parameter.',
    );
  }

  static String keyOf(Map<String, dynamic>? params, List<String> keys) =>
      keys.map((k) => require(params, k)).join('::');

  /// Filters [source] by every entry of [params] matched against
  /// [fields], then applies [limit]/[offset].
  static List<T> filter<T>(
    Iterable<T> source,
    Map<String, dynamic>? params,
    Map<String, dynamic> Function(T) fields, {
    int? limit,
    int? offset,
  }) {
    var result = source.where((item) {
      final map = fields(item);
      for (final entry in (params ?? const {}).entries) {
        if (map[entry.key] != entry.value) return false;
      }
      return true;
    }).toList();
    if (offset != null && offset > 0) {
      result = result.skip(offset).toList();
    }
    if (limit != null && limit >= 0) {
      result = result.take(limit).toList();
    }
    return result;
  }
}

/// In-memory [PermissionDataSource]: permissions keyed by id.
class InMemoryPermissionDataSource
    with Loggable, FailureHandler
    implements PermissionDataSource {
  InMemoryPermissionStore store;

  InMemoryPermissionDataSource(this.store);

  @override
  Future<Permission> get(QueryParams<Permission> params) async {
    final id = InMemoryStoreOps.require(params.params, 'id');
    final permission = store.permissions[id];
    if (permission == null) throw InMemoryStoreOps.notFound('permission');
    return permission;
  }

  @override
  Future<List<Permission>> getList(ListQueryParams<Permission> params) async {
    return InMemoryStoreOps.filter<Permission>(
      store.permissions.values,
      params.params,
      (p) => {'id': p.id, 'name': p.name, 'scopeId': p.scopeId},
      limit: params.limit,
      offset: params.offset,
    );
  }

  @override
  Future<Permission> create(Permission permission) async {
    if (store.permissions.containsKey(permission.id)) {
      throw InMemoryStoreOps.duplicate('A permission "${permission.id}"');
    }
    store.permissions[permission.id] = permission;
    return permission;
  }
}

/// In-memory [RoleDataSource]: roles keyed by id.
class InMemoryRoleDataSource
    with Loggable, FailureHandler
    implements RoleDataSource {
  InMemoryPermissionStore store;

  InMemoryRoleDataSource(this.store);

  @override
  Future<Role> get(QueryParams<Role> params) async {
    final id = InMemoryStoreOps.require(params.params, 'id');
    final role = store.roles[id];
    if (role == null) throw InMemoryStoreOps.notFound('role');
    return role;
  }

  @override
  Future<List<Role>> getList(ListQueryParams<Role> params) async {
    return InMemoryStoreOps.filter<Role>(
      store.roles.values,
      params.params,
      (r) => {'id': r.id, 'name': r.name},
      limit: params.limit,
      offset: params.offset,
    );
  }

  @override
  Future<Role> create(Role role) async {
    if (store.roles.containsKey(role.id)) {
      throw InMemoryStoreOps.duplicate('A role "${role.id}"');
    }
    store.roles[role.id] = role;
    return role;
  }
}

/// In-memory [UserPermissionDataSource]: direct user grants keyed by
/// the (userId, permissionId) pair.
class InMemoryUserPermissionDataSource
    with Loggable, FailureHandler
    implements UserPermissionDataSource {
  InMemoryPermissionStore store;

  InMemoryUserPermissionDataSource(this.store);

  @override
  Future<UserPermission> get(QueryParams<UserPermission> params) async {
    final key = InMemoryStoreOps.keyOf(params.params, [
      'userId',
      'permissionId',
    ]);
    final grant = store.userPermissions[key];
    if (grant == null) throw InMemoryStoreOps.notFound('user permission');
    return grant;
  }

  @override
  Future<List<UserPermission>> getList(
    ListQueryParams<UserPermission> params,
  ) async {
    return InMemoryStoreOps.filter<UserPermission>(
      store.userPermissions.values,
      params.params,
      (g) => {'userId': g.userId, 'permissionId': g.permissionId},
      limit: params.limit,
      offset: params.offset,
    );
  }

  @override
  Future<UserPermission> create(UserPermission userPermission) async {
    final key = '${userPermission.userId}::${userPermission.permissionId}';
    if (store.userPermissions.containsKey(key)) {
      throw ZuraffaPlatformException(
        code: 'duplicate_grant',
        message:
            'User "${userPermission.userId}" already holds '
            '"${userPermission.permissionId}".',
      );
    }
    store.userPermissions[key] = userPermission;
    return userPermission;
  }

  @override
  Future<void> delete(QueryParams<UserPermission> params) async {
    final key = InMemoryStoreOps.keyOf(params.params, [
      'userId',
      'permissionId',
    ]);
    if (store.userPermissions.remove(key) == null) {
      throw InMemoryStoreOps.notFound('user permission');
    }
  }
}

/// In-memory [UserRoleDataSource]: role assignments keyed by the
/// (userId, roleId) pair.
class InMemoryUserRoleDataSource
    with Loggable, FailureHandler
    implements UserRoleDataSource {
  InMemoryPermissionStore store;

  InMemoryUserRoleDataSource(this.store);

  @override
  Future<UserRole> get(QueryParams<UserRole> params) async {
    final key = InMemoryStoreOps.keyOf(params.params, ['userId', 'roleId']);
    final assignment = store.userRoles[key];
    if (assignment == null) throw InMemoryStoreOps.notFound('user role');
    return assignment;
  }

  @override
  Future<List<UserRole>> getList(ListQueryParams<UserRole> params) async {
    return InMemoryStoreOps.filter<UserRole>(
      store.userRoles.values,
      params.params,
      (a) => {'userId': a.userId, 'roleId': a.roleId},
      limit: params.limit,
      offset: params.offset,
    );
  }

  @override
  Future<UserRole> create(UserRole userRole) async {
    final key = '${userRole.userId}::${userRole.roleId}';
    if (store.userRoles.containsKey(key)) {
      throw ZuraffaPlatformException(
        code: 'duplicate_assignment',
        message:
            'User "${userRole.userId}" already holds role '
            '"${userRole.roleId}".',
      );
    }
    store.userRoles[key] = userRole;
    return userRole;
  }

  @override
  Future<void> delete(QueryParams<UserRole> params) async {
    final key = InMemoryStoreOps.keyOf(params.params, ['userId', 'roleId']);
    if (store.userRoles.remove(key) == null) {
      throw InMemoryStoreOps.notFound('user role');
    }
  }
}

/// In-memory [RolePermissionDataSource]: role → permission membership
/// keyed by the (roleId, permissionId) pair.
class InMemoryRolePermissionDataSource
    with Loggable, FailureHandler
    implements RolePermissionDataSource {
  InMemoryPermissionStore store;

  InMemoryRolePermissionDataSource(this.store);

  @override
  Future<RolePermission> get(QueryParams<RolePermission> params) async {
    final key = InMemoryStoreOps.keyOf(params.params, [
      'roleId',
      'permissionId',
    ]);
    final membership = store.rolePermissions[key];
    if (membership == null) throw InMemoryStoreOps.notFound('role permission');
    return membership;
  }

  @override
  Future<List<RolePermission>> getList(
    ListQueryParams<RolePermission> params,
  ) async {
    return InMemoryStoreOps.filter<RolePermission>(
      store.rolePermissions.values,
      params.params,
      (m) => {'roleId': m.roleId, 'permissionId': m.permissionId},
      limit: params.limit,
      offset: params.offset,
    );
  }

  @override
  Future<RolePermission> create(RolePermission rolePermission) async {
    final key = '${rolePermission.roleId}::${rolePermission.permissionId}';
    if (store.rolePermissions.containsKey(key)) {
      throw ZuraffaPlatformException(
        code: 'duplicate_membership',
        message:
            'Role "${rolePermission.roleId}" already holds '
            '"${rolePermission.permissionId}".',
      );
    }
    store.rolePermissions[key] = rolePermission;
    return rolePermission;
  }

  @override
  Future<void> delete(QueryParams<RolePermission> params) async {
    final key = InMemoryStoreOps.keyOf(params.params, [
      'roleId',
      'permissionId',
    ]);
    if (store.rolePermissions.remove(key) == null) {
      throw InMemoryStoreOps.notFound('role permission');
    }
  }
}
