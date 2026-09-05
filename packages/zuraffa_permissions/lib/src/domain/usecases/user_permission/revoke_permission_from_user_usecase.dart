import 'package:zuraffa/zuraffa.dart';

import '../../entities/user_permission/user_permission.dart';
import '../../repositories/user_permission_repository.dart';

/// Access control query (FR-003): which user + permission grant to
/// revoke.
class RevokePermissionParams {
  const RevokePermissionParams({
    required this.userId,
    required this.permissionId,
  });

  final String userId;
  final String permissionId;
}

/// Access control (FR-003): revokes a direct permission grant from a
/// user. Pure use case over the permission store; no statics, no
/// Flutter.
class RevokePermissionFromUserUseCase
    extends UseCase<void, RevokePermissionParams> {
  RevokePermissionFromUserUseCase(this._repository);

  final UserPermissionRepository _repository;

  @override
  Future<void> execute(
    RevokePermissionParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    return _repository.delete(
      QueryParams<UserPermission>(
        params: {'userId': params.userId, 'permissionId': params.permissionId},
      ),
    );
  }
}
