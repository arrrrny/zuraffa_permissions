---
detected_at: 2b966f2 # short SHA the profile was detected against
ecosystems: [dart] # one entry per detected stack
default: dart # which one the loop uses when a path is ambiguous
stacks:
  dart:
    cwd: . # working directory every command below runs in (root package)
    runner: "package:test (^1.24.0)"
    single: 'dart test -n "{name}"'
    file: dart test {file}
    suite: dart test
    watch: null # this package:test version has no --watch flag
    coverage: 'dart test --coverage=coverage'
    mutation: 'dart run mutation_test' # mutation_test 1.8.0 installed & verified; pass file paths to scope per-feature
    acceptance: null # no acceptance/e2e tests exist
    property: null # glados not in lock; ecosystem default is `glados`
    approval: null # no snapshot/approval tool in use
    contract: null # no contract tests
    test_glob: "test/**/*_test.dart"
    exemplar: # one per test kind the stack can run
      unit: test/permission_test.dart
    helpers: # test utilities a new test reuses instead of hand-rolling
      - lib/src/data/permission/in_memory_permission_adapter.dart # in-memory fake reused as the test double for PermissionPort
      - test/permission_test.dart # defines getItForTest() (fresh GetIt) and the assertion/matcher style to imitate
verified: [single, file, suite, coverage, mutation] # each was run successfully
suite_baseline: green # 13/13 passed at detection time
suite_seconds: 8 # observed wall time of the full suite (incl. first-run compile)
---

# TDD Stack Profile

## Conventions to match

- Test files live in `test/` and are named `*_test.dart`. There is exactly one
  today: `test/permission_test.dart`. Imitate it for every unit test.
- Assertions use `expect` from `package:test` with its built-in matchers:
  `isTrue`, `hasLength`, `contains`, `throwsA`, `isA`, `having`. No custom
  matchers are registered.
- Grouping maps tests to spec acceptance criteria: `group('... (FR-XXX)', () { test(...) })`.
  Keep the `FR-XXX` tag in the group name so a test is traceable to `spec.md`.
- Doubles: there is **no mocking library** in the project (`mocktail` was removed
  as an unused dependency). The only double pattern is the production
  `InMemoryPermissionAdapter` (in `lib/src/data/permission/in_memory_permission_adapter.dart`)
  used as a fake `PermissionPort`. Follow that in-memory-fake pattern for every
  test; do not add a mocking library.
- DI in tests: build a fresh container with `getItForTest()` (defined at the
  bottom of `test/permission_test.dart`) before calling
  `registerPermissionDependencies`. Never share a `GetIt` instance across tests.
- The one shared test helper is `getItForTest()`; there is no factories module,
  base class, setup file, or fixture server. Hand-rolling a fresh `GetIt` per
  test is the expected idiom, not a smell.

## Notes and constraints

- **Working directory is the root package (`.`).** Every command above runs
  from there. The root package depends on `zuraffa` via `path: ../zuraffa`
  (present) and on `zorphy_annotation` / `json_annotation` with generated
  `*.g.dart` / `*.zorphy.dart` files already committed, so tests run without
  `build_runner`. First run needs `dart pub get` (path deps are resolved
  lazily); `dart test` triggers it automatically. `pubspec.yaml` pins
  `dependency_overrides: analyzer: 14.1.0`.
- **Suite is green and fast** (18 tests, ~8s incl. first compile; subsequent
  runs are a couple of seconds). A per-cycle full run is viable — no fast
  subset required.
- **`dart test -n "{name}"` exits 0 on a non-matching name.** It prints
  "No tests ran." with exit code 0. The loop MUST treat "No tests ran." as a
  non-green (red/blocked) signal, never as a pass — a mistyped name must not
  produce a false green. Always copy the exact test name from the file.
- **Watch mode is unavailable** in this `package:test` version (`--watch` is
  not a recognized flag). A human following along runs `dart test` (or
  `dart test -n "<name>"`) repeatedly; there is no hot-reload runner.
- **Coverage** is produced as raw VM coverage JSON under `coverage/`; convert
  with `dart pub global activate coverage && format_coverage` (or
  `--coverage-path=lcov.info` on the same runner) if a human-readable LCOV
  report is wanted. The loop records coverage presence, not a formatted number.
- **Mutation testing is installed and verified.** `mutation_test 1.8.0` (the
  Dart/Flutter ecosystem default) is now a dev dependency. Baseline scoped run
  over the feature's five behavior-bearing source files produced 25 mutants at
  **100% killed** (quality rating A, 0 timeouts, 0 uncovered, 2:24). Per-feature
  scoped runs pass explicit file paths, e.g.
  `dart run mutation_test lib/src/.../foo.dart`; the bare `dart run mutation_test`
  mutates every `.dart` file under `lib/` (including generated `*.g.dart` /
  `*.zorphy.dart` — scope to avoid noise).
- **Property-based testing is not installed.** `glados` is absent from the
  lock. Invariants become boundary example tests.
- **Flutter sibling packages have a runner but no tests.** `zuraffa_permissions_platform_interface`,
  `_android`, `_ios`, and `_macos` all declare `flutter_test` yet contain no
  `test/` directory and no test files. The runner exists but nothing exercises
  it. Changes there need characterization tests first, and this profile has no
  verified `flutter test` command for them (nothing to run against). They are
  out of scope for the Dart inner loop until tests exist.
- **Platform wiring (post refactor A).** The three federated packages
  (`zuraffa_permissions_android` / `_ios` / `_macos`) call
  `setPlatformPermissionPortFactory(() => MethodChannelPermissionAdapter())`
  from their `registerWith()` (Flutter runs this when the app starts). That
  makes `registerPermissionDependencies(getIt)` default to the real
  `MethodChannelPermissionAdapter` once an app depends on a platform package —
  so every such app gets real OS permissions (FR-001). The main package stays
  pure Dart and defaults to `InMemoryPermissionAdapter` when no platform package
  registered (tests, servers), preserving FR-006 and the `dart test` baseline.
  The contract types (`PermissionPort`, `PermissionStatus`,
  `PermissionRequestResult`) intentionally live in the pure-Dart main package,
  not in `platform_interface`; `platform_interface` depends *down* on the main
  package for them (no cycle).
- **No acceptance / contract / approval layers** exist in this repository.
