// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/role_permission_repository.dart';
import '../../domain/usecases/role_permission/grant_permission_to_role_usecase.dart';

void registerGrantPermissionToRoleUseCase(GetIt getIt) {
  getIt.registerLazySingleton<GrantPermissionToRoleUseCase>(
    () => GrantPermissionToRoleUseCase(getIt<RolePermissionRepository>()),
  );
}

// END GENERATED
