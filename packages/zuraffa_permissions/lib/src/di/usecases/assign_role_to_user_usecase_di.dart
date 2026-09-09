// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/user_role_repository.dart';
import '../../domain/usecases/user_role/assign_role_to_user_usecase.dart';

void registerAssignRoleToUserUseCase(GetIt getIt) {
  getIt.registerLazySingleton<AssignRoleToUserUseCase>(
    () => AssignRoleToUserUseCase(getIt<UserRoleRepository>()),
  );
}

// END GENERATED
