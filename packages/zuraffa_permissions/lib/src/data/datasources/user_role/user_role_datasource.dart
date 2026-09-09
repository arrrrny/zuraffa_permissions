// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/user_role/user_role.dart';

abstract class UserRoleDataSource with Loggable, FailureHandler {
  Future<UserRole> get(QueryParams<UserRole> params);
  Future<List<UserRole>> getList(ListQueryParams<UserRole> params);
  Future<UserRole> create(UserRole userRole);
  Future<void> delete(QueryParams<UserRole> params);
}

// END GENERATED
