import 'package:zuraffa/zuraffa.dart';

import '../../entities/user_role/user_role.dart';
import '../../repositories/user_role_repository.dart';

/// Role assignment query (FR-003): which user + role assignment to
/// remove.
class RemoveRoleParams {
  const RemoveRoleParams({required this.userId, required this.roleId});

  final String userId;
  final String roleId;
}

/// Role assignment (FR-003): removes a role from a user. Pure use case
/// over the permission store; no statics, no Flutter.
class RemoveRoleFromUserUseCase extends UseCase<void, RemoveRoleParams> {
  RemoveRoleFromUserUseCase(this._repository);

  final UserRoleRepository _repository;

  @override
  Future<void> execute(
    RemoveRoleParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    return _repository.delete(
      QueryParams<UserRole>(
        params: {'userId': params.userId, 'roleId': params.roleId},
      ),
    );
  }
}
