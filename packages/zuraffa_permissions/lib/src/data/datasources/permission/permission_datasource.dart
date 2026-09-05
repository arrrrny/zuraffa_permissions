// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/permission/permission.dart';

abstract class PermissionDataSource with Loggable, FailureHandler {
  Future<Permission> get(QueryParams<Permission> params);
  Future<List<Permission>> getList(ListQueryParams<Permission> params);
  Future<Permission> create(Permission permission);
}

// END GENERATED
