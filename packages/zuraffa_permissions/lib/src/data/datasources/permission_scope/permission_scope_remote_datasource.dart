// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/permission_scope/permission_scope.dart';
import 'permission_scope_datasource.dart';

class PermissionScopeRemoteDataSource
    with Loggable, FailureHandler
    implements PermissionScopeDataSource {
  @override
  Future<PermissionScope> get(QueryParams<PermissionScope> params) async {
    throw UnimplementedError('Implement remote get');
  }

  @override
  Future<List<PermissionScope>> getList(
    ListQueryParams<PermissionScope> params,
  ) async {
    throw UnimplementedError('Implement remote getList');
  }

  @override
  Future<PermissionScope> create(PermissionScope permissionScope) async {
    throw UnimplementedError('Implement remote create');
  }
}

// END GENERATED
