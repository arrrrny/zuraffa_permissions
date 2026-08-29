---
feature: 001-permission-port
verdict: PASS
standard: .specify/extensions/tdd/templates/tdd-test-quality-rubric.md # rubric graded against
verified_at: dcf1661 # short SHA audited (working tree atop carries the Phase 6 remedies, re-verified)
behaviors: 26
proven: 26
likely: 0
test_after: 0
no_test: 0
not_applicable: 0
high_smells: 0
criteria_total: 8
criteria_covered: 8
mutation_score: 100 # scope: 7 feature source files, mutation_test (verified 1.8.0), 25 mutants, quality A, 0 timeouts
mutants_survived: 0 # 0 mechanical mutants survived; all killed
suite: 22 passed, 0 failed, 2.8s
real_device: "macos,android,ios: PASS (example/integration_test/permission_test.dart, cycle 8 + location coverage cycle 9); location request grant flow PASS on physical iPhone 12 Pro Max (cycle 10)"
---

# TDD Verification: zuraffa_permissions — typed permission port

**Verdict: PASS.** Every one of the 26 behaviors is `PROVEN`, there are no `HIGH`
smells, all 8 FRs are covered end-to-end through the package's real public API,
and mechanical mutation testing on the feature's source files is **100% killed
(25/25, quality A)** with no survivor inside any `DONE` behavior. The two
behaviors previously carried as `LIKELY` (`U23`, `U24`) are reclassified `PROVEN`
(see evidence table) because git shows their test and source changing together in
`dcf1661` and the cycle log records the red for each — the exact shape the rubric
treats as `PROVEN`. The four `MED` + two `LOW` findings from the prior audit were
remedied (tasks 5.1, 5.2, 6.1–6.4) and the suite + mutation were re-run green.

> Independence note: the smoke pass (Phase 3) was delegated to a fresh-context
> subagent; the mutation run (Phase 4) was executed by the auditor and the tree
> re-verified green afterward. This is the re-audit that closes the prior
> `PASS_WITH_GAPS`.

## Test-first evidence

Brownfield feature: implemented and green (13-test suite) at planning baseline
`40264b9`. 7 behaviors were driven red→green inside the feature's TDD workflow
(cycles 1–7); 17 are inherited baseline tests; `U25`/`U26` (factory port
selection) shipped as a coherent test+source feature commit (`45524ba`).

| Behavior | Class  | Evidence |
| -------- | ------ | -------- |
| U1  | PROVEN | cycle 1 red (deliberate mutant: 7th enum → fail); commit `7d06a4f` (test+source) |
| U8  | PROVEN | cycle 2 red (deliberate mutant: idempotency guard); commit `efae09b` |
| U9  | PROVEN | cycle 3 red (deliberate mutant: idempotency guard); commit `0116b30` |
| U10 | PROVEN | cycle 4 red (deliberate mutant: `check` ignores stored); commit `b412ff9` |
| U22 | PROVEN | cycle 5 real red ("factory not registered"); commit `2b966f2` |
| U23 | PROVEN | cycle 7 real red (`requestedAt: 0`); landed co-changed with source in `dcf1661` (same commit as source + cycle-log red ⇒ PROVEN per the rubric's same-commit rule) |
| U24 | PROVEN | cycle 6 real red (`tracking` absent from `all`); landed co-changed with source in `dcf1661` (same commit as source + cycle-log red ⇒ PROVEN) |
| U2–U7, U11–U21 | PROVEN | Inherited baseline, green at `40264b9`, not weakened by the feature; corroborated by 100% mutation kills |
| U25, U26 | PROVEN | Coherent feature commit `45524ba` (test+source together), green, not weakened; corroborated by 100% mutation kills |

### Weakened / skipped existing tests

None. The `U23` contract change adapted the 8 existing request-path assertions to
the new `PermissionRequestResult` return type (access-path change, not a loosened
predicate). The Phase 6 remedies (5.1, 5.2, 6.1–6.4) strengthened assertions and
removed a redundant double without weakening any predicate. No assertion was
removed, renamed out of a filter's reach, skipped, or had a threshold lowered.

### tasks.md vs test list

All 26 behavior rows `DONE` and all referenced by ticked tasks. Remediation tasks
`5.1`, `5.2`, `6.1`–`6.4` are now resolved (see below) and ticked. Open gate `3.1`
is satisfied by this audit's green run.

## Findings

**All findings from the prior audit are resolved.** No `HIGH`, `MED`, or `LOW`
finding remains open.

| # | Severity (prior) | Resolution | Evidence |
| - | ---------------- | ---------- | -------- |
| 1 | MED (factory-wiring value proxy) | Resolved (6.1): the test now asserts `identical(getIt<PermissionPort>(), fake)` to pin the resolved port instance, not just a canned value. | `test/permission_test.dart` (factory-wiring test) |
| 2 | MED (`_FakePermissionPort` foreign style / bypassed utility) | Resolved (6.2): the hand-rolled `_FakePermissionPort` is removed; the factory-wiring tests reuse `InMemoryPermissionAdapter()..grant(kCamera')`, the profile's only double. | `test/permission_test.dart` |
| 3 | MED (assertion roulette) | Resolved (6.3): `reason:` added to every `expect` in the multi-assert built-ins and request-result tests so a failure names the broken behavior. | `test/permission_test.dart` |
| 4 | MED (magic scope-id strings) | Resolved (6.4): named `const` scope-id identifiers (`kCamera`, …) introduced and used at every call site; a typo now fails at compile time. | `test/permission_test.dart` |
| 5 | LOW (stale "ten built-ins" name) | Resolved (5.1): test renamed to "all eleven built-ins …"; source comments at `built_in_permission_scopes.dart:3` and `permission_service.dart:17` updated to "eleven". | `test/permission_test.dart`, `lib/src/.../built_in_permission_scopes.dart`, `lib/src/permission_service.dart` |
| 6 | LOW (vacuous `isNotNull`) | Resolved (5.2): `tracking.platformGroup` now asserts the concrete `equals('privacy')`, matching the camera check. | `test/permission_test.dart:42` |

## Mutation results

### Mechanical run (mutation_test 1.8.0) — re-verified after remedies

Scoped to the **7** behavior-bearing source files. Result: **25 mutants, 0
undetected (100% score, quality rating A)** in 1:35, 0 timeouts, 0 mutants
outside test coverage. Re-run after the Phase 6 test edits confirmed the suite
still kills every mutant (the remedies changed test assertions, not source, so the
mutant set is unchanged).

| File | Mutants | Undetected |
| ---- | ------- | ---------- |
| `lib/src/data/permission/in_memory_permission_adapter.dart` | 18 | 0 |
| `lib/src/permission_service.dart` | 4 | 0 |
| `lib/src/domain/entities/scopes/built_in_permission_scopes.dart` | 1 | 0 |
| `lib/src/domain/repositories/permission_scope_repository.dart` | 1 | 0 |
| `lib/src/data/repositories/data_permission_scope_repository.dart` | 1 | 0 |
| `lib/src/domain/permission/permission_port.dart` | 0 | — |
| `lib/src/domain/entities/enums/permission_status.dart` | 0 | — |

No survivor inside any `DONE` behavior. The suite was re-run green (22 passed)
after the run to confirm no mutant was left in the tree.

## Traceability

| Criterion | Tests | Real entry point |
| --------- | ----- | ---------------- |
| FR-001 (Port shapes) | U23, U7, U17, U18, U19, U25, U26 | `PermissionPort`/`PermissionService`/`registerPermissionDependencies` public API |
| FR-002 (enum six states) | U1, U10, U8, U9 | `PermissionStatus` enum + adapter `check` |
| FR-003 (eleven zero-config scopes) | U11, U12, U13, U24 | `PermissionScopeRegistry.withBuiltIns()` + `BuiltInPermissionScopes.all` |
| FR-004 (custom scopes + duplicate guard) | U14, U15 | `PermissionScopeRegistry.register` |
| FR-005 (permanently-denied no re-prompt) | U5, U8, U9 | `InMemoryPermissionAdapter.request` |
| FR-006 (pure-Dart in-memory adapter) | U2, U3, U4 | `InMemoryPermissionAdapter` |
| FR-007 (DI wires GetIt) | U20, U21, U22 | `registerPermissionDependencies` + `getItForTest()` |
| FR-008 (entities via zfa CLI / Zorphy) | — | Build/codegen concern; generated `*.g.dart`/`*.zorphy.dart` compile. Not asserted by `package:test`. |

Untested criteria: none at runtime except **FR-008** (by spec design). Tests
tracing to nothing: none. All 8 FRs reach at least one test through the real
public API (inside-out library; `acceptance: null`).

## Domain entities coverage

Every entity the feature owns is exercised: `PermissionStatus` (U1),
`PermissionScope` (U11, U14, U19), `BuiltInPermissionScopes` (U11, U13, U24),
`PermissionScopeRegistry` (U11–U16), `PermissionRequestResult` (U23),
`PermissionPort` (U2–U10), `PermissionService` (U17–U22),
`InMemoryPermissionAdapter` (U2–U10, U23). FR-008 (Zorphy-generated) is covered
at build time only.

## Real-device verification (federated native plugin)

Characterized on real OS via `example/integration_test/permission_test.dart`
(Cycle 8: macOS 15.7.9, Android `Pixel_10_Pro` API 37, iOS Simulator iPhone 16e
— all GREEN) and the physical-iPhone request flow (Cycle 10: cabled iPhone 12 Pro
Max iOS 18.7.1, `request('locationWhenInUse')` grant → `granted`; required
`NSLocationWhenInUseUsageDescription` + a plugin poll-window widening to ~30s on
both Apple plugins). FR-001 through the real MethodChannel is exercised on every
target.

## What was not audited

- **The 4 federated Flutter packages** (`platform_interface`, `_android`, `_ios`,
  `_macos`): characterized on real devices via the `example/` integration test, not
  by package-local unit tests (they declare `flutter_test` but ship no test files).
- **FR-008 at runtime**: compilation of generated code only, by spec design.
- **Mutation scope**: the 7 behavior-bearing source files (25 mutants), not the
  whole `lib/` tree (generated files excluded). A whole-repo run is a CI job.
- **Performance / load behavior**: no criterion, no test, not assessed.
- **Coverage as a formatted number**: produced as raw VM JSON under `coverage/`;
  used only to confirm files executed.
