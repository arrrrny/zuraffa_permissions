// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/permission_scope_repository.dart';
import '../../domain/usecases/permission_scope/create_permission_scope_usecase.dart';

void registerCreatePermissionScopeUseCase(GetIt getIt) {
  getIt.registerLazySingleton<CreatePermissionScopeUseCase>(
    () => CreatePermissionScopeUseCase(getIt<PermissionScopeRepository>()),
  );
}

// END GENERATED
