// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../data/datasources/permission/permission_datasource.dart';
import '../../data/datasources/role/role_datasource.dart';
import '../../data/datasources/role_permission/role_permission_datasource.dart';
import '../../data/datasources/user_permission/user_permission_datasource.dart';
import '../../data/datasources/user_role/user_role_datasource.dart';
import '../../data/repositories/data_permission_repository.dart';
import '../../data/repositories/data_role_permission_repository.dart';
import '../../data/repositories/data_role_repository.dart';
import '../../data/repositories/data_user_permission_repository.dart';
import '../../data/repositories/data_user_role_repository.dart';
import '../../domain/repositories/permission_repository.dart';
import '../../domain/repositories/role_permission_repository.dart';
import '../../domain/repositories/role_repository.dart';
import '../../domain/repositories/user_permission_repository.dart';
import '../../domain/repositories/user_role_repository.dart';

void registerPermissionRepositories(GetIt getIt) {
  getIt.registerLazySingleton<PermissionRepository>(
    () => DataPermissionRepository(getIt<PermissionDataSource>()),
  );
  getIt.registerLazySingleton<RoleRepository>(
    () => DataRoleRepository(getIt<RoleDataSource>()),
  );
  getIt.registerLazySingleton<UserPermissionRepository>(
    () => DataUserPermissionRepository(getIt<UserPermissionDataSource>()),
  );
  getIt.registerLazySingleton<UserRoleRepository>(
    () => DataUserRoleRepository(getIt<UserRoleDataSource>()),
  );
  getIt.registerLazySingleton<RolePermissionRepository>(
    () => DataRolePermissionRepository(getIt<RolePermissionDataSource>()),
  );
}

// END GENERATED
