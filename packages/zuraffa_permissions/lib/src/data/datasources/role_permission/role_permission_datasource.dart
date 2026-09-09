// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/role_permission/role_permission.dart';

abstract class RolePermissionDataSource with Loggable, FailureHandler {
  Future<RolePermission> get(QueryParams<RolePermission> params);
  Future<List<RolePermission>> getList(ListQueryParams<RolePermission> params);
  Future<RolePermission> create(RolePermission rolePermission);
  Future<void> delete(QueryParams<RolePermission> params);
}

// END GENERATED
