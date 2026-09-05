---
feature: 055-v6-permissions-migration
verdict: PASS (publish-gated)
issue: arrrrny/zuraffa#668
epic: arrrrny/zuraffa#214
verified_at: working tree on branch 055-v6-permissions-migration (pre-PR)
toolchain: "Flutter 3.47.2 stable / Dart 3.13.2 / spec-kit specify 1.0.5.dev0 + TDD extension v1.1.2"
suite_main: 37 passed, 0 failed
suite_platform_interface: 17 passed, 0 failed
analyze: "0 issues (main, platform_interface, android, ios, macos)"
format: 0 remaining diffs after `dart format .`
fr_proved: 4
fr_gated: 1
fr_unconditional: 1
---

# TDD Verification: zuraffa_permissions → built on Zuraffa

**Verdict: PASS for the code migration; FR-005 (publish) is
publish-gated.** Every code-level FR is proven by executed commands with
their real output; the only unproven item is the final pub.dev upload,
which is blocked by Google OAuth authorization (a human-in-the-loop step
requiring the `zuzu.dev` uploader's Google account), not by any package
defect. `pub publish --dry-run` reports **valid, no errors** for the
main package.

## Test-first evidence (red → green)

- **RED**: `test/zuraffa_migration_test.dart` (15 tests) written against
  the required migration surface *before* any implementation existed.
  `flutter test` failed to compile with **144 `Error:` diagnostics**
  (`Undefined name 'Permission'`, `'Role'`, `'UserPermission'`,
  `'UserRole'`, `'RolePermission'`, `'CheckPermissionUseCase'`, …).
  Full output: `tdd/red-evidence.txt`. Suite: **0 passed / 1 load
  failure**.
- **GREEN (entities)**: five Zorphy entities declared +
  `dart run build_runner build` (21 outputs). GREEN (layers): 5
  datasource contracts, `InMemoryPermissionStore` + 5 adapters, 5
  `Data*Repository` implementations, 9 use cases, full GetIt wiring.
- **GREEN (suite)**: `flutter test` → **37/37 passed** (22 inherited
  spec-001 tests untouched — FR-006 non-breaking — plus 15 new).
  Platform interface suite: **17/17 passed**.

## FR coverage matrix

| FR | Requirement | Verdict | Evidence (executed) |
|----|------------|---------|---------------------|
| FR-001 | Permission/role types as Zuraffa entities with unique ids | **PROVED** | Zorphy `@Zorphy(generateJson, generateCompareTo)` on `Permission`/`Role`/`UserPermission`/`UserRole`/`RolePermission`; build_runner generated 21 outputs; tests 1–6 pass (ids + JSON round-trip) |
| FR-002 | Persistence ops through Zuraffa datasources/repositories | **PROVED** | 5 datasource contracts + 5 `Data*Repository` (`with Loggable, FailureHandler`) + `InMemoryPermissionStore`; tests 7–14 exercise everything through datasource→repository→use case; `registerPermissionDependencies` wires all onto GetIt |
| FR-003 | Business logic (checks, role assignment, access control) as use cases | **PROVED** | 9 `UseCase` subclasses; tests 7–12: no-grant→false, direct grant→true, role-derived→true, revoke→false, remove-role→false, merged deduped effective permissions |
| FR-004 | Compiles without errors; public API accessible from host app | **PROVED** | `dart analyze` = No issues found (main, platform_interface, android, ios, macos); root import resolves every new symbol (test 15); use cases resolvable from `GetIt` (tests 13–14) |
| FR-005 | Published to pub.dev under `zuzu.dev` | **GATED** | `flutter pub publish --dry-run` (main) → valid, no errors, 230 KB archive, 2 pubspecs (main+example). Real upload attempt `flutter pub publish --force` stopped at Google OAuth authorization gate (no browser/credentials in environment; captured in publish log). `zuzu.dev` publisher exists on pub.dev. Remaining step (owner): `cd packages/zuraffa_permissions && flutter pub publish`, then platform_interface → android/ios/macos |
| FR-006 | Existing consumers upgrade without breaking changes | **PROVED** | `PermissionPort`/`PermissionService`/`PermissionScopeRegistry`/`InMemoryPermissionAdapter` API unchanged; all 22 inherited spec-001 tests pass unmodified; only additive exports |

## Quality gates (all executed)

| Gate | Command | Result |
|------|---------|--------|
| Static analysis | `dart analyze` | No issues found — main package; same for all 4 sibling packages (0/81→0 after fixes) |
| Tests (main) | `flutter test` | 00:00 +37: All tests passed! |
| Tests (platform interface) | `flutter test` | 00:00 +17: All tests passed! |
| Formatting | `dart format .` then `dart format --output=none --set-exit-if-changed .` | 0 changed |
| Diff check | `git diff --stat` | zero formatting diffs remain |
| Publish validation | `flutter pub publish --dry-run` | "Package has 0 errors"; 1 pre-commit warning (dirty git tree), resolved by this commit |

## Known notes

1. **`Role` collision**: zuraffa 6.1.0 exports a DDA middleware
   annotation named `Role`. Libraries in this package that reference the
   domain `Role` import `package:zuraffa/zuraffa.dart hide Role`. The
   task's required entity name (`Role`) is preserved.
2. **Federated layout**: the repo now follows the standard
   `packages/` layout. Rationale: pub 3.13.2 does **not** exclude nested
   packages from the publish archive (verified with a scratch-package
   dry-run), so with the previous layout the main package would have
   embedded the four sibling packages. Reference check:
   `flutter_inappwebview` 6.1.5's published archive contains only its
   own + example pubspec.
3. **dependency_overrides in sibling packages**: they pin the federated
   siblings to the local checkout for local development and are accepted
   by publish validation (verified with a scratch-package dry-run);
   consumers ignore dependency_overrides of their dependencies.
4. **Publish order** (after PR merge): `zuraffa_permissions` 1.0.0
   first, then `zuraffa_permissions_platform_interface`,
   `zuraffa_permissions_android`, `_ios`, `_macos` (each `flutter pub
   publish` from its `packages/<name>` directory, authenticated as a
   `zuzu.dev` uploader).
