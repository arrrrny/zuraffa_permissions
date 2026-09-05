// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../data/datasources/permission/permission_datasource.dart';
import '../../data/datasources/permission_store/in_memory_permission_store.dart';
import '../../data/datasources/role/role_datasource.dart';
import '../../data/datasources/role_permission/role_permission_datasource.dart';
import '../../data/datasources/user_permission/user_permission_datasource.dart';
import '../../data/datasources/user_role/user_role_datasource.dart';

void registerInMemoryPermissionStore(GetIt getIt) {
  getIt.registerLazySingleton<InMemoryPermissionStore>(
    () => InMemoryPermissionStore(),
  );
  getIt.registerLazySingleton<PermissionDataSource>(
    () => InMemoryPermissionDataSource(getIt<InMemoryPermissionStore>()),
  );
  getIt.registerLazySingleton<RoleDataSource>(
    () => InMemoryRoleDataSource(getIt<InMemoryPermissionStore>()),
  );
  getIt.registerLazySingleton<UserPermissionDataSource>(
    () => InMemoryUserPermissionDataSource(getIt<InMemoryPermissionStore>()),
  );
  getIt.registerLazySingleton<UserRoleDataSource>(
    () => InMemoryUserRoleDataSource(getIt<InMemoryPermissionStore>()),
  );
  getIt.registerLazySingleton<RolePermissionDataSource>(
    () => InMemoryRolePermissionDataSource(getIt<InMemoryPermissionStore>()),
  );
}

// END GENERATED
