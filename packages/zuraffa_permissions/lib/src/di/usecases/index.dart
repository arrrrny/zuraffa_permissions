// GENERATED - DO NOT EDIT
import 'package:zuraffa/zuraffa.dart';

import 'assign_role_to_user_usecase_di.dart';
import 'check_permission_usecase_di.dart';
import 'create_permission_scope_usecase_di.dart';
import 'create_permission_usecase_di.dart';
import 'create_role_usecase_di.dart';
import 'get_permission_scope_list_usecase_di.dart';
import 'get_permission_scope_usecase_di.dart';
import 'grant_permission_to_role_usecase_di.dart';
import 'grant_permission_to_user_usecase_di.dart';
import 'list_user_permissions_usecase_di.dart';
import 'remove_role_from_user_usecase_di.dart';
import 'revoke_permission_from_user_usecase_di.dart';

void registerAllUseCases(GetIt getIt) {
  registerCreatePermissionScopeUseCase(getIt);
  registerGetPermissionScopeListUseCase(getIt);
  registerGetPermissionScopeUseCase(getIt);
  registerCreatePermissionUseCase(getIt);
  registerCreateRoleUseCase(getIt);
  registerGrantPermissionToRoleUseCase(getIt);
  registerGrantPermissionToUserUseCase(getIt);
  registerRevokePermissionFromUserUseCase(getIt);
  registerAssignRoleToUserUseCase(getIt);
  registerRemoveRoleFromUserUseCase(getIt);
  registerCheckPermissionUseCase(getIt);
  registerListUserPermissionsUseCase(getIt);
}

// END GENERATED
