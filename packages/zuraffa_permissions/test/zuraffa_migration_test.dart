import 'package:test/test.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt, UseCase;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';
import 'package:zuraffa_permissions/src/data/repositories/data_permission_repository.dart';
import 'package:zuraffa_permissions/src/data/repositories/data_role_permission_repository.dart';
import 'package:zuraffa_permissions/src/data/repositories/data_role_repository.dart';
import 'package:zuraffa_permissions/src/data/repositories/data_user_permission_repository.dart';
import 'package:zuraffa_permissions/src/data/repositories/data_user_role_repository.dart';

/// Spec `055-v6-permissions-migration` (issue #668, EPIC #214) — the
/// package is built on the **published** Zuraffa framework: permission
/// and role domain objects are Zuraffa entities (FR-001), every
/// persistence op flows through Zuraffa datasources/repositories
/// (FR-002), and all business logic — permission checks, role
/// assignment, access control — runs through Zuraffa use cases
/// (FR-003) that host apps resolve from GetIt (FR-004).
void main() {
  group('FR-001: permission domain objects are Zuraffa entities', () {
    test('Permission carries a unique identifier and scope link', () {
      final permission = Permission(
        id: 'perm.camera.read',
        name: 'Read camera',
        description: 'Allows reading from the camera.',
        scopeId: 'camera',
      );
      expect(permission.id, 'perm.camera.read');
      expect(permission.scopeId, 'camera');
      expect(permission.name, 'Read camera');
    });

    test('Role is an entity with a unique identifier', () {
      final role = Role(
        id: 'role.content-editor',
        name: 'Content editor',
        description: 'May edit content.',
      );
      expect(role.id, 'role.content-editor');
      expect(role.name, 'Content editor');
    });

    test('UserPermission links a user to a granted permission', () {
      final grant = UserPermission(
        userId: 'user-1',
        permissionId: 'perm.camera.read',
        grantedAt: 1700000000000,
      );
      expect(grant.userId, 'user-1');
      expect(grant.permissionId, 'perm.camera.read');
    });

    test('UserRole links a user to an assigned role', () {
      final assignment = UserRole(
        userId: 'user-1',
        roleId: 'role.content-editor',
        assignedAt: 1700000000000,
      );
      expect(assignment.userId, 'user-1');
      expect(assignment.roleId, 'role.content-editor');
    });

    test('RolePermission joins a role to one of its permissions', () {
      final join = RolePermission(
        roleId: 'role.content-editor',
        permissionId: 'perm.article.publish',
      );
      expect(join.roleId, 'role.content-editor');
      expect(join.permissionId, 'perm.article.publish');
    });

    test('entities round-trip through JSON', () {
      final role = Role(
        id: 'role.admin',
        name: 'Admin',
        description: 'Administrator.',
      );
      final restored = Role.fromJson(role.toJson());
      expect(restored.id, role.id);
      expect(restored.name, role.name);

      final permission = Permission(
        id: 'perm.a',
        name: 'A',
        description: 'desc',
        scopeId: 'camera',
      );
      final restoredPermission = Permission.fromJson(permission.toJson());
      expect(restoredPermission.id, permission.id);
      expect(restoredPermission.scopeId, permission.scopeId);
    });
  });

  group('FR-003: access control runs through Zuraffa use cases', () {
    late InMemoryPermissionStore store;
    late CheckPermissionUseCase checkPermission;
    late AssignRoleToUserUseCase assignRole;
    late RemoveRoleFromUserUseCase removeRole;
    late GrantPermissionToUserUseCase grantPermission;
    late RevokePermissionFromUserUseCase revokePermission;
    late ListUserPermissionsUseCase listUserPermissions;
    late CreatePermissionUseCase createPermission;
    late CreateRoleUseCase createRole;
    late GrantPermissionToRoleUseCase grantPermissionToRole;

    setUp(() async {
      store = InMemoryPermissionStore();
      final permissionRepo = DataPermissionRepository(
        InMemoryPermissionDataSource(store),
      );
      final roleRepo = DataRoleRepository(InMemoryRoleDataSource(store));
      final userPermissionRepo = DataUserPermissionRepository(
        InMemoryUserPermissionDataSource(store),
      );
      final userRoleRepo = DataUserRoleRepository(
        InMemoryUserRoleDataSource(store),
      );
      final rolePermissionRepo = DataRolePermissionRepository(
        InMemoryRolePermissionDataSource(store),
      );

      createPermission = CreatePermissionUseCase(permissionRepo);
      createRole = CreateRoleUseCase(roleRepo);
      grantPermissionToRole = GrantPermissionToRoleUseCase(rolePermissionRepo);
      checkPermission = CheckPermissionUseCase(
        userPermissionRepo,
        userRoleRepo,
        rolePermissionRepo,
      );
      assignRole = AssignRoleToUserUseCase(userRoleRepo);
      removeRole = RemoveRoleFromUserUseCase(userRoleRepo);
      grantPermission = GrantPermissionToUserUseCase(userPermissionRepo);
      revokePermission = RevokePermissionFromUserUseCase(userPermissionRepo);
      listUserPermissions = ListUserPermissionsUseCase(
        userPermissionRepo,
        userRoleRepo,
        rolePermissionRepo,
        permissionRepo,
      );

      await createPermission.execute(
        Permission(
          id: 'perm.camera.read',
          name: 'Read camera',
          description: '',
          scopeId: 'camera',
        ),
        null,
      );
      await createPermission.execute(
        Permission(
          id: 'perm.article.publish',
          name: 'Publish article',
          description: '',
          scopeId: 'storage',
        ),
        null,
      );
      await createRole.execute(
        Role(id: 'role.publisher', name: 'Publisher', description: ''),
        null,
      );
      await grantPermissionToRole.execute(
        RolePermission(
          roleId: 'role.publisher',
          permissionId: 'perm.article.publish',
        ),
        null,
      );
    });

    test('a user with no grants holds no permission', () async {
      final allowed = await checkPermission.execute(
        const CheckPermissionParams(
          userId: 'user-1',
          permissionId: 'perm.camera.read',
        ),
        null,
      );
      expect(allowed, isFalse);
    });

    test('a direct user grant satisfies the check (FR-003)', () async {
      await grantPermission.execute(
        UserPermission(
          userId: 'user-1',
          permissionId: 'perm.camera.read',
          grantedAt: 1700000000000,
        ),
        null,
      );
      final allowed = await checkPermission.execute(
        const CheckPermissionParams(
          userId: 'user-1',
          permissionId: 'perm.camera.read',
        ),
        null,
      );
      expect(allowed, isTrue);
    });

    test('a role assignment grants the role permissions (FR-003)', () async {
      await assignRole.execute(
        UserRole(
          userId: 'user-2',
          roleId: 'role.publisher',
          assignedAt: 1700000000000,
        ),
        null,
      );
      final allowed = await checkPermission.execute(
        const CheckPermissionParams(
          userId: 'user-2',
          permissionId: 'perm.article.publish',
        ),
        null,
      );
      expect(
        allowed,
        isTrue,
        reason: 'role membership implies its permissions',
      );
    });

    test('revoking a direct grant removes the access', () async {
      await grantPermission.execute(
        UserPermission(
          userId: 'user-3',
          permissionId: 'perm.camera.read',
          grantedAt: 1700000000000,
        ),
        null,
      );
      await revokePermission.execute(
        const RevokePermissionParams(
          userId: 'user-3',
          permissionId: 'perm.camera.read',
        ),
        null,
      );
      final allowed = await checkPermission.execute(
        const CheckPermissionParams(
          userId: 'user-3',
          permissionId: 'perm.camera.read',
        ),
        null,
      );
      expect(allowed, isFalse);
    });

    test('removing a role assignment drops role-derived access', () async {
      await assignRole.execute(
        UserRole(
          userId: 'user-4',
          roleId: 'role.publisher',
          assignedAt: 1700000000000,
        ),
        null,
      );
      await removeRole.execute(
        const RemoveRoleParams(userId: 'user-4', roleId: 'role.publisher'),
        null,
      );
      final allowed = await checkPermission.execute(
        const CheckPermissionParams(
          userId: 'user-4',
          permissionId: 'perm.article.publish',
        ),
        null,
      );
      expect(allowed, isFalse);
    });

    test(
      'effective permissions merge direct grants and role grants, deduped',
      () async {
        await grantPermission.execute(
          UserPermission(
            userId: 'user-5',
            permissionId: 'perm.camera.read',
            grantedAt: 1700000000000,
          ),
          null,
        );
        await assignRole.execute(
          UserRole(
            userId: 'user-5',
            roleId: 'role.publisher',
            assignedAt: 1700000000000,
          ),
          null,
        );
        await grantPermission.execute(
          UserPermission(
            userId: 'user-5',
            permissionId: 'perm.article.publish',
            grantedAt: 1700000000001,
          ),
          null,
        );
        final permissions = await listUserPermissions.execute(
          const ListUserPermissionsParams(userId: 'user-5'),
          null,
        );
        final ids = permissions.map((p) => p.id).toSet();
        expect(ids, {
          'perm.camera.read',
          'perm.article.publish',
        }, reason: 'direct + role-derived grants merge without duplicates');
        expect(permissions, hasLength(ids.length));
      },
    );
  });

  group('FR-002/FR-004: persistence through datasources wired onto GetIt', () {
    test('registerPermissionDependencies exposes the use cases', () {
      final getIt = GetIt.instance..reset();
      registerPermissionDependencies(getIt);

      expect(getIt.isRegistered<CheckPermissionUseCase>(), isTrue);
      expect(getIt.isRegistered<AssignRoleToUserUseCase>(), isTrue);
      expect(getIt.isRegistered<ListUserPermissionsUseCase>(), isTrue);
      expect(getIt.isRegistered<PermissionRepository>(), isTrue);
      expect(getIt.isRegistered<RoleRepository>(), isTrue);

      final check = getIt<CheckPermissionUseCase>();
      expect(check, isA<UseCase<bool, CheckPermissionParams>>());
      getIt.reset();
    });

    test('the default store datasource is the pure-Dart in-memory one', () {
      final getIt = GetIt.instance..reset();
      registerPermissionDependencies(getIt);
      expect(getIt<InMemoryPermissionStore>(), isNotNull);
      expect(getIt<CheckPermissionUseCase>(), isNotNull);
      getIt.reset();
    });

    test(
      'the migration surface is exported from the package root (FR-004)',
      () {
        // FR-004: the public API is fully accessible from a host Zuraffa app
        // with a single package import — every new type resolves here.
        expect(Permission, isNotNull);
        expect(Role, isNotNull);
        expect(UserPermission, isNotNull);
        expect(UserRole, isNotNull);
        expect(RolePermission, isNotNull);
        expect(InMemoryPermissionStore, isNotNull);
        expect(CheckPermissionUseCase, isNotNull);
        expect(CheckPermissionParams, isNotNull);
        expect(AssignRoleToUserUseCase, isNotNull);
        expect(RevokePermissionFromUserUseCase, isNotNull);
      },
    );
  });
}
