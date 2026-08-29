---
feature: 001-permission-port
verdict: PASS_WITH_GAPS
standard: .specify/extensions/tdd/templates/tdd-test-quality-rubric.md # rubric graded against
verified_at: 2b966f2 # short SHA audited
behaviors: 24
proven: 22
likely: 2
test_after: 0
no_test: 0
not_applicable: 0
high_smells: 0
criteria_total: 8
criteria_covered: 8
mutation_score: 100 # scope: 5 feature source files, mutation_test 1.8.0, 25 mutants, quality A
mutants_survived: 0 # 25 mechanical mutants (adapter 18, service 6, scopes 1); all killed
suite: 20 passed, 0 failed, ~8s
---

# TDD Verification: zuraffa_permissions — typed permission port

**Verdict: PASS_WITH_GAPS.** Discipline holds, every FR is covered, no HIGH
smells, and mutation testing is now installed and measured at **100% (25/25
killed, quality rating A)** on the feature's source files. The remaining gap is:
2 of the 24 behaviors (`U23`, `U24`) are uncommitted so git cannot corroborate
their test-first ordering (classified `LIKELY`, not `PROVEN`).

> Audit independence note: this audit was run by the same session that wrote the
> tests. To mitigate the cold-context problem the rubric warns about, the smell
> pass (Phase 3) was delegated to a fresh-context subagent with no prior context.
> The deliberate mutants (Phase 4) were executed by the auditor and are itemized
> below with their restore confirmed by a green suite.

## Test-first evidence

The feature is **brownfield**: the package was already implemented and its suite
(13 tests) was green at the planning baseline `40264b9`. Of the 24 behaviors, 7
were driven red→green inside this feature's TDD workflow (cycles 1–7), and 17 are
inherited baseline tests that were green before the workflow began. The 17
inherited tests were checked for weakening during the feature's diffs and none
were loosened (see "Weakened existing tests" below); 3 of them (`U4`, `U5`, `U18`)
also received deliberate mutants in this audit.

| Behavior | Class  | Evidence |
| -------- | ------ | -------- |
| U1  | PROVEN | cycle 1 red recorded; commit `7d06a4f` (test+source); + deliberate mutant (7th enum) |
| U8  | PROVEN | cycle 2 red recorded; commit `efae09b`; + deliberate mutant (idempotency guard) |
| U9  | PROVEN | cycle 3 red recorded; commit `0116b30`; + deliberate mutant (idempotency guard) |
| U10 | PROVEN | cycle 4 red recorded; commit `b412ff9`; + deliberate mutant (`check` ignores stored) |
| U22 | PROVEN | cycle 5 real red ("factory not registered"); commit `2b966f2` (HEAD) wires usecases |
| U23 | LIKELY | cycle 7 real red (`requestedAt: 0`); **not committed** → git cannot show order |
| U24 | LIKELY | cycle 6 real red (`tracking` absent from `all`); **not committed** → git cannot show order |
| U2, U3, U4, U5, U6, U7, U11, U12, U13, U14, U15, U16, U17, U18, U19, U20, U21 | PROVEN | Inherited baseline tests, green at `40264b9`, not weakened by the feature. `U4`/`U5`/`U18` further validated by deliberate mutants in this audit. |

### Weakened / skipped existing tests

None. The `U23` contract change adapted the 8 existing request-path assertions
(`U3`, `U4`, `U5`, `U6`, `U8`, `U9`, `U17` in the service, plus the adapter/port
signatures) from a raw `PermissionStatus` expectation to `(await …).status`. This
is an access-path change to match a new return type, not a loosened predicate — the
asserted status values are unchanged. No assertion was removed, renamed out of a
filter's reach, marked skipped/pending, or had a threshold lowered.

### tasks.md vs test list

All 24 behavior rows in `test-list.md` are `DONE`. Every `DONE` behavior is
referenced by a ticked task in `tasks.md` (`[X]` 1.1, 1.2, 1.3, 1.4, 1.5, 2.1,
2.2, 4.1, 4.2). `U22`'s coverage-gap task (1.5) is ticked; `U23`/`U24` map to the
ticked 2.1/2.2 (decision) and 4.1/4.2 (application) tasks. No task is ticked whose
behavior is not `DONE`, and no `DONE` behavior lacks a ticked task. One open task
remains: `3.1` (run the full suite green) — appropriate, since the final green run
is this audit's own gate.

## Findings

Ordered by severity. No `HIGH` findings; both are `LOW` readability issues raised
by the independent smell-pass subagent.

| # | Severity | Finding | Evidence |
| - | -------- | ------- | -------- |
| 1 | LOW | Test name says "all ten built-ins" but the loop asserts 11 ids and `hasLength(11)`. The name contradicts its own assertion (stale after clarification 2.2 added `tracking`). | `test/permission_test.dart:12` (name) vs `:14-29` (11 ids, `hasLength(11)`). Source comments at `built_in_permission_scopes.dart:3` and `permission_service.dart:17` also still say "the ten built-ins". |
| 2 | LOW (borderline) | `platformGroup isNotNull` is vacuous: `platformGroup` is a non-nullable `String`, so the assertion can never fail. The sibling camera check asserts the concrete value `'media'` (`test/permission_test.dart:30`); this check should assert `'privacy'` for parity and real coverage of the metadata. | `test/permission_test.dart:42`. |

The independent subagent rated #2 as LOW on the grounds that the field is
non-nullable and the test additionally pins `id` and `all` length. It is recorded
as LOW, but the auditor notes it is weak relative to its sibling and recommends the
concrete-value assertion. Neither finding is `HIGH`, so neither affects the verdict.

## Mutation results

### Mechanical run (mutation_test 1.8.0)

`mutation_test` is now installed. A scoped run over the five behavior-bearing
source files produced **25 mutants, 0 undetected (100% score, quality rating A)**
in 2:24, with 0 timeouts and 0 mutants outside test coverage:

| File | Mutants | Undetected |
| ---- | ------- | ---------- |
| `lib/src/data/permission/in_memory_permission_adapter.dart` | 18 | 0 |
| `lib/src/permission_service.dart` | 6 | 0 |
| `lib/src/domain/entities/scopes/built_in_permission_scopes.dart` | 1 | 0 |
| `lib/src/domain/permission/permission_port.dart` | 0 | — |
| `lib/src/domain/entities/enums/permission_status.dart` | 0 | — |

This is a stronger result than the deliberate-mutant fallback below and replaces
it as the authoritative strength evidence for the feature's source files. The
tool's source files were re-grepped afterward and the suite re-run (20 passed) to
confirm no mutant was left in the tree.

### Deliberate-mutant fallback (earlier, tool-absent)

Before the tool was installed, 5 highest-risk behaviors were sampled with
deliberate mutants — one small change each, observed failing, then restored
exactly and confirmed green by a full-suite run.

| Mutant (file:line) | Behavior | Caught by | Survived |
| ------------------ | -------- | --------- | -------- |
| `in_memory_permission_adapter.dart:68` default `granted`→`denied` | U4 | `request defaults to granted when no outcome is prepared` (`:100`) | No |
| `in_memory_permission_adapter.dart:57` removed `permanentlyDenied` guard | U5 | `permanently denied never re-prompts` (`:106`) | No |
| `in_memory_permission_adapter.dart:59-62` dropped `limited`/`restricted` from idempotency guard | U8/U9 | `a scope currently limited is returned unchanged…` (`:128`) | No |
| `permission_service.dart:83-88` bypassed unknown-scope `throw` | U18 | `an unknown scope is a typed, fail-fast error` (`:183`) | No |
| `in_memory_permission_adapter.dart:74` `requestedAt` zeroed | U23 | `request returns a PermissionRequestResult carrying scope, status, and requestedAt` (`:156`) | No |

Prior-session mutants recorded in `cycle-log.md` (U1 seventh enum value, U8/U9
guards, U10 `check` ignoring stored status) are likewise all caught. **0 mutants
survived.** Coverage was produced (`dart test --coverage=coverage`) but read as
raw VM JSON only; a formatted LCOV number was not required for this audit and is
not reported as a score.

## Traceability

| Criterion | Tests | Real entry point |
| --------- | ----- | ---------------- |
| FR-001 (Port shapes) | U23, U7, U17, U18, U19 | `PermissionPort`/`PermissionService` public API (inside-out) |
| FR-002 (enum six states) | U1, U10, U8, U9 | `PermissionStatus` enum + adapter `check` |
| FR-003 (eleven zero-config scopes) | U11, U13, U24 | `PermissionScopeRegistry.withBuiltIns()` + `BuiltInPermissionScopes.all` |
| FR-004 (custom scopes + duplicate guard) | U14, U15 | `PermissionScopeRegistry.register` |
| FR-005 (permanently-denied no re-prompt) | U5, U8, U9 | `InMemoryPermissionAdapter.request` |
| FR-006 (pure-Dart in-memory adapter) | U2, U3, U4 | `InMemoryPermissionAdapter` |
| FR-007 (DI wires GetIt) | U20, U21, U22 | `registerPermissionDependencies` + `getItForTest()` |
| FR-008 (entities via zfa CLI / Zorphy) | — | Build/codegen concern; generated `*.g.dart`/`*.zorphy.dart` compile. Not asserted by `package:test` (see Out of scope in `test-list.md`). |

Untested criteria: none at runtime except **FR-008**, which the spec frames as a
codegen/build step rather than a runtime behavior; the generated entity files exist
and compile. Tests tracing to nothing: none. All 8 FRs reach at least one test
through the package's real public API (this is an `inside-out` library with no
separate acceptance layer — `acceptance: null` in the profile).

## Domain entities coverage

The user asked to confirm all domain entities are exercised. Every entity the
feature owns is touched by a test:

- `PermissionStatus` (enum, 6 states) — U1.
- `PermissionScope` (id/name/description/platformGroup) — U11, U14, U19.
- `BuiltInPermissionScopes` (registry of 11, incl. `tracking`) — U11, U13, U24.
- `PermissionScopeRegistry` (register/lookup/contains/duplicate guard) — U11–U16.
- `PermissionRequestResult` (scope/status/requestedAt) — U23.
- `PermissionPort` (check/request/openSettings) — U2–U10.
- `PermissionService` (routing, unknown-scope fail-fast, DI) — U17–U22.
- `InMemoryPermissionAdapter` (pure-Dart state machine) — U2–U10, U23.

FR-008 entities (Zorphy-generated) are covered at build time only.

## What was not audited

- **The 4 federated Flutter packages** (`zuraffa_permissions_platform_interface`,
  `_android`, `_ios`, `_macos`): they declare `flutter_test` but contain no test
  files, so there is nothing to run against and no verified `flutter test` command.
  Out of scope for this Dart inner loop; they need characterization tests before
  any change.
- **FR-008 at runtime**: asserted only by compilation of generated code, not by a
  `package:test` test, by design of the spec.
- **Mutation scope**: the mechanical run was scoped to the 5 behavior-bearing
  source files (25 mutants), not the whole `lib/` tree (generated `*.g.dart` /
  `*.zorphy.dart` files were excluded to avoid noise). A whole-repo run is a CI
  job, not an audit step.
- **`U23`/`U24` git ordering**: both are uncommitted (working-tree only), so the
  audit relies on the cycle-log red entries rather than commit order; they are
  classified `LIKELY`.
- **Performance / load behavior**: no criterion, no test, not assessed.
- **Coverage as a formatted number**: produced as raw VM JSON under `coverage/` but
  not converted to LCOV for a percentage score; used only to confirm files executed.
