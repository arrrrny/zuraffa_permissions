// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/permission_scope_repository.dart';
import '../../domain/usecases/permission_scope/get_permission_scope_usecase.dart';

void registerGetPermissionScopeUseCase(GetIt getIt) {
  getIt.registerLazySingleton<GetPermissionScopeUseCase>(
    () => GetPermissionScopeUseCase(getIt<PermissionScopeRepository>()),
  );
}

// END GENERATED
