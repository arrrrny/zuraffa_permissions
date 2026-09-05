# Changelog

## 1.0.0

- **Built on Zuraffa**: the package now builds on the published `zuraffa`
  framework (^6.1.0) instead of a local path checkout (issue #668, part of
  EPIC #214).
- **Permission & role domain objects** (FR-001): `Permission`, `Role`,
  `UserPermission`, `UserRole` and `RolePermission` are Zuraffa (Zorphy)
  entities with unique identifiers and JSON round-trip support.
- **Persistence through Zuraffa layers** (FR-002): datasource contracts +
  `Data*Repository` implementations for the five new aggregates, with a
  pure-Dart `InMemoryPermissionStore` default so access control tests
  without a platform.
- **Business logic through Zuraffa use cases** (FR-003): `CheckPermissionUseCase`,
  `ListUserPermissionsUseCase`, `AssignRoleToUserUseCase`,
  `RemoveRoleFromUserUseCase`, `GrantPermissionToUserUseCase`,
  `RevokePermissionFromUserUseCase`, `GrantPermissionToRoleUseCase`,
  `CreatePermissionUseCase`, `CreateRoleUseCase` — all resolved from GetIt
  via `registerPermissionDependencies` (FR-004).
- **Published to pub.dev** under the `zuzu.dev` publisher (FR-005).
- Existing consumers keep the unchanged `PermissionPort` / `PermissionService`
  / scope registry API — no breaking changes (FR-006).
