# Test list — 055-v6-permissions-migration

Test file: `packages/zuraffa_permissions/test/zuraffa_migration_test.dart`

| # | Test | FR | Status |
|---|------|----|--------|
| 1 | Permission carries a unique identifier and scope link | FR-001 | red→green (cycle 1) |
| 2 | Role is an entity with a unique identifier | FR-001 | red→green (cycle 1) |
| 3 | UserPermission links a user to a granted permission | FR-001 | red→green (cycle 1) |
| 4 | UserRole links a user to an assigned role | FR-001 | red→green (cycle 1) |
| 5 | RolePermission joins a role to one of its permissions | FR-001 | red→green (cycle 1) |
| 6 | Entities round-trip through JSON | FR-001 | red→green (cycle 1) |
| 7 | A user with no grants holds no permission | FR-003 | red→green (cycle 2) |
| 8 | A direct user grant satisfies the check | FR-003 | red→green (cycle 2) |
| 9 | A role assignment grants the role permissions | FR-003 | red→green (cycle 2) |
| 10 | Revoking a direct grant removes the access | FR-003 | red→green (cycle 2) |
| 11 | Removing a role assignment drops role-derived access | FR-003 | red→green (cycle 2) |
| 12 | Effective permissions merge direct + role grants, deduped | FR-003 | red→green (cycle 2) |
| 13 | registerPermissionDependencies exposes the use cases | FR-002/004 | red→green (cycle 3) |
| 14 | Default store datasource is the pure-Dart in-memory one | FR-002/004 | red→green (cycle 3) |
| 15 | Migration surface exported from the package root | FR-004 | red→green (cycle 3) |

Inherited (spec 001) regression suite: `packages/zuraffa_permissions/test/permission_test.dart`
+ `packages/zuraffa_permissions_platform_interface/test/method_channel_port_test.dart` — 39 tests, untouched, all green.
