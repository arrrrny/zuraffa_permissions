// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/user_role_repository.dart';
import '../../domain/usecases/user_role/remove_role_from_user_usecase.dart';

void registerRemoveRoleFromUserUseCase(GetIt getIt) {
  getIt.registerLazySingleton<RemoveRoleFromUserUseCase>(
    () => RemoveRoleFromUserUseCase(getIt<UserRoleRepository>()),
  );
}

// END GENERATED
