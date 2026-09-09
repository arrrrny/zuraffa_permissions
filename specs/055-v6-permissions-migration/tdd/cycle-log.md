# TDD cycle log — 055-v6-permissions-migration

## Cycle 0 — baseline (pre-red)

- Cloned repo; branch `055-v6-permissions-migration`.
- Removed `dependency_overrides:` (analyzer pin) from pubspec; replaced
  `zuraffa: path: ../zuraffa` with `zuraffa: ^6.1.0` (published).
- `flutter pub get` — resolved against pub.dev (zuraffa 6.1.0,
  zorphy_annotation 2.3.1). `./example` resolved too.
- Baseline: `dart analyze` = 6 info lints in `example/` only;
  `flutter test` = **22/22 PASS** (inherited spec-001 suite).
- Toolchain: Flutter 3.47.2 / Dart 3.13.2 stable. spec-kit
  (`specify` 1.0.5.dev0) + TDD extension v1.1.2 already installed in
  `.specify/` (not clobbered; `specify extension list` → "✓ TDD
  Extension (v1.1.2)").

## Cycle 1 — RED

- Wrote `test/zuraffa_migration_test.dart` (15 tests) against the
  required migration surface: `Permission`, `Role`, `UserPermission`,
  `UserRole`, `RolePermission` entities (JSON round-trip), access
  control use cases, DI wiring, root exports.
- `flutter test test/zuraffa_migration_test.dart` → **FAILS to compile**:
  144 `Error:` diagnostics (`Undefined name 'Permission'`, `'Role'`,
  `'CheckPermissionUseCase'`, …). Suite: 0 passed, 1 failed (load).
- Evidence: `specs/055-v6-permissions-migration/tdd/red-evidence.txt`.

## Cycle 2 — GREEN (entities + data + use cases)

- Five Zorphy entities (`@Zorphy(generateJson, generateCompareTo)`) +
  `dart run build_runner build` → 21 outputs (`.zorphy.dart`, `.g.dart`).
- Five datasource contracts, `InMemoryPermissionStore` + five in-memory
  datasource adapters, five `Data*Repository` implementations.
- Nine use cases (create permission/role, grant/revoke user permission,
  grant role permission, assign/remove role, check permission, list user
  permissions) with `CheckPermissionParams` / `RevokePermissionParams` /
  `RemoveRoleParams` / `ListUserPermissionsParams`.
- DI: `di/datasources/in_memory_permission_store_di.dart`,
  `di/repositories/permission_repositories_di.dart`, 9 use-case DI files,
  `di/index.dart` now registers datasources → repositories → use cases.
- Root exports extended (FR-004).
- Name-collision fix: zuraffa 6.1.0 exports its own `Role`
  (DDA middleware annotation) — libraries referencing this package's
  `Role` import `package:zuraffa/zuraffa.dart hide Role`.
- `dart analyze lib test` → No issues found.

## Cycle 3 — GREEN (full suite)

- `flutter test` → **37/37 PASS** (22 inherited + 15 new). Later
  re-verified after restructure + formatting: 37/37 main, 17/17 platform
  interface.

## Refactor

- Repository restructured to the standard federated layout (`packages/`)
  so the published main package does not embed sibling sources (pub
  3.13.2 does not exclude nested packages — verified empirically).
- `dart format .` → 17 files reformatted; `dart format
  --output=none --set-exit-if-changed .` → 0 changed afterwards.

## Publish preparation (FR-005)

- All five packages: version 1.0.0, `publish_to: none` removed, MIT
  LICENSE + CHANGELOG added, `repository`/`issue_tracker`/`topics` set.
- Cross-package deps switched to hosted `^1.0.0`; local development
  resolves through `dependency_overrides` (accepted by publish
  validation — verified empirically).
- `flutter pub publish --dry-run` (main): **valid, no errors**; archive
  230 KB with exactly 2 pubspecs (main + example). Sole warning = dirty
  git tree pre-commit.
