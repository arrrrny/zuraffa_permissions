# Changelog

## 1.0.0

- **Built on Zuraffa**: the package now builds on the published `zuraffa`
  framework (^6.1.0) instead of a local path checkout (issue #668, part of
  EPIC #214).
- **Permission & role domain objects** (FR-001): `Permission`, `Role`,
  `UserPermission`, `UserRole` and `RolePermission` are Zuraffa (Zorphy)
  entities with unique or composite identifiers and JSON round-trip support.
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
- **Publish-ready** (FR-005): version 1.0.0, MIT LICENSE, repository/topics
  metadata for publication under the `zuzu.dev` publisher.
- Existing consumers keep the unchanged `PermissionPort` / `PermissionService`
  / scope registry API — no breaking changes (FR-006).

## 0.1.0

- Initial release: typed permission requests for the Zuraffa ecosystem.
- `PermissionStatus` with exactly six states; eleven zero-config built-in
  scopes (camera, microphone, photos, location family, notifications,
  contacts, tracking, and more) plus custom scope registration with a
  duplicate guard.
- Idempotent `request()` semantics: already-decided scopes return their
  status unchanged, and permanently denied never re-prompts.
- `PermissionService` facade over the `PermissionPort` seam, with typed
  fail-fast errors for unknown scopes.
- `registerPermissionDependencies` GetIt composition root: port, service,
  and permission-scope use cases wired as lazy singletons; accepts an
  injected custom adapter or factory-supplied port.
- Pure-Dart `InMemoryPermissionAdapter` for tests and previews.
- Built with the zfa TDD discipline: 26 behaviors PROVEN, mechanical
  mutation sweep 25/25 killed (quality A), real-device verified on macOS,
  Android, and iOS.
- Platform implementations ship in federated packages
  (`zuraffa_permissions_android`, `_ios`, `_macos`) over
  `zuraffa_permissions_platform_interface`.
