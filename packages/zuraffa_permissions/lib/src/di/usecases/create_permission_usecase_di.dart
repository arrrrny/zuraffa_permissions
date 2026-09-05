// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/permission_repository.dart';
import '../../domain/usecases/permission/create_permission_usecase.dart';

void registerCreatePermissionUseCase(GetIt getIt) {
  getIt.registerLazySingleton<CreatePermissionUseCase>(
    () => CreatePermissionUseCase(getIt<PermissionRepository>()),
  );
}

// END GENERATED
