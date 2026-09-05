// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/user_permission/user_permission.dart';

abstract class UserPermissionDataSource with Loggable, FailureHandler {
  Future<UserPermission> get(QueryParams<UserPermission> params);
  Future<List<UserPermission>> getList(ListQueryParams<UserPermission> params);
  Future<UserPermission> create(UserPermission userPermission);
  Future<void> delete(QueryParams<UserPermission> params);
}

// END GENERATED
