// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/role_permission_repository.dart';
import '../../domain/repositories/user_permission_repository.dart';
import '../../domain/repositories/user_role_repository.dart';
import '../../domain/usecases/access_control/check_permission_usecase.dart';

void registerCheckPermissionUseCase(GetIt getIt) {
  getIt.registerLazySingleton<CheckPermissionUseCase>(
    () => CheckPermissionUseCase(
      getIt<UserPermissionRepository>(),
      getIt<UserRoleRepository>(),
      getIt<RolePermissionRepository>(),
    ),
  );
}

// END GENERATED
