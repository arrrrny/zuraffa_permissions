// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/permission_scope/permission_scope.dart';

abstract class PermissionScopeDataSource with Loggable, FailureHandler {
  Future<PermissionScope> get(QueryParams<PermissionScope> params);
  Future<List<PermissionScope>> getList(
    ListQueryParams<PermissionScope> params,
  );
  Future<PermissionScope> create(PermissionScope permissionScope);
}

// END GENERATED
