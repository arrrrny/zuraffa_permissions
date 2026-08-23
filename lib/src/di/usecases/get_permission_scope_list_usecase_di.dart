// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import '../../domain/repositories/permission_scope_repository.dart';
import '../../domain/usecases/permission_scope/get_permission_scope_list_usecase.dart';

void registerGetPermissionScopeListUseCase(GetIt getIt) {
  getIt.registerLazySingleton<GetPermissionScopeListUseCase>(
    () => GetPermissionScopeListUseCase(getIt<PermissionScopeRepository>()),
  );
}

// END GENERATED
