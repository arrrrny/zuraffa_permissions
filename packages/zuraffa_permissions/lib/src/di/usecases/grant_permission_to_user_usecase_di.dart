// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/user_permission_repository.dart';
import '../../domain/usecases/user_permission/grant_permission_to_user_usecase.dart';

void registerGrantPermissionToUserUseCase(GetIt getIt) {
  getIt.registerLazySingleton<GrantPermissionToUserUseCase>(
    () => GrantPermissionToUserUseCase(getIt<UserPermissionRepository>()),
  );
}

// END GENERATED
