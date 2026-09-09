// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/permission_repository.dart';
import '../../domain/repositories/role_permission_repository.dart';
import '../../domain/repositories/user_permission_repository.dart';
import '../../domain/repositories/user_role_repository.dart';
import '../../domain/usecases/access_control/list_user_permissions_usecase.dart';

void registerListUserPermissionsUseCase(GetIt getIt) {
  getIt.registerLazySingleton<ListUserPermissionsUseCase>(
    () => ListUserPermissionsUseCase(
      getIt<UserPermissionRepository>(),
      getIt<UserRoleRepository>(),
      getIt<RolePermissionRepository>(),
      getIt<PermissionRepository>(),
    ),
  );
}

// END GENERATED
