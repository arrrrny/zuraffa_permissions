// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart' hide Role;

import '../../../domain/entities/role/role.dart';

abstract class RoleDataSource with Loggable, FailureHandler {
  Future<Role> get(QueryParams<Role> params);
  Future<List<Role>> getList(ListQueryParams<Role> params);
  Future<Role> create(Role role);
}

// END GENERATED
