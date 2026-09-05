// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/user_permission_repository.dart';
import '../../domain/usecases/user_permission/revoke_permission_from_user_usecase.dart';

void registerRevokePermissionFromUserUseCase(GetIt getIt) {
  getIt.registerLazySingleton<RevokePermissionFromUserUseCase>(
    () => RevokePermissionFromUserUseCase(getIt<UserPermissionRepository>()),
  );
}

// END GENERATED
