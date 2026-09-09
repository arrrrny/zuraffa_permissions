// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/role_repository.dart';
import '../../domain/usecases/role/create_role_usecase.dart';

void registerCreateRoleUseCase(GetIt getIt) {
  getIt.registerLazySingleton<CreateRoleUseCase>(
    () => CreateRoleUseCase(getIt<RoleRepository>()),
  );
}

// END GENERATED
