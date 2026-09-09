---
feature: 007-example-app-outcome-matrix
verdict: PASS
standard: .specify/extensions/tdd/templates/tdd-test-quality-rubric.md # rubric graded against
verified_at: 17452d5 # short SHA audited (working tree atop carries the Phase 8 remedies, re-verified)
behaviors: 22
proven: 21
likely: 0
test_after: 0
no_test: 0
not_applicable: 1 # U41: inherited characterization baseline, green by definition
high_smells: 0
criteria_total: 4 # AC-001..AC-004 from issue #7 (backed by FR-001..FR-008)
criteria_covered: 4
mutation_score: 100 # scope: the 3 survivor-bearing files (tile, screen, controller) re-run post-remediation, mutation_test 1.8.0, 27 mutants, 0 undetected, quality A
mutants_survived: 15 # initial 7-file scoped run: 76 mutants, 17 undetected; 2 real survivors remediated (kill re-verified), 15 triaged equivalent (style/prose/guards/entry-point)
suite: "example flutter test 22 passed, 0 failed; root dart test 22 passed, 0 failed (regression gate)"
real_device: "not run in this environment (no emulators/toolchains): AC-001's device half is the existing example/integration_test suite's job; flutter build web --release PASS (compile evidence)"
---

# TDD Verification: 007 — example app outcome matrix

**Verdict: PASS.** All 21 testable behaviors are `PROVEN` (cycle-log reds + same-commit
test/source co-changes, corroborated by history), there are no `HIGH` smells (the
one `MED` — same-level A/U redundancy — was remediated by pinning the flow log at
a genuinely different, pure-Dart level), every acceptance criterion from issue #7
reaches an end-to-end test through the real `PermissionApp` entry point, and every
mutation survivor that mapped to a real surface was remediated and its kill
re-verified (27/27 on the survivor-bearing files, quality A).

> Independence note: this audit was run by the same session that wrote the tests
> (greenfield feature, single implementer). Per the verify command's Hard Rule 2,
> every file was re-read cold rather than trusted from memory, and the Phase 3
> smell pass was delegated to a fresh-context subagent (Task 7-a, cold-context,
> which independently confirmed: 0 HIGH, 1 MED, all 19 then-rows resolving, the
> inherited test byte-identical to baseline). The mutation runs and this report
> are the author session's; treat the smell pass as the independent half.

## Test-first evidence

Greenfield feature on a plain-list example app. Cycles 1–3 added each cycle's
tests, observed the behavioral red (recorded in the cycle log with failure
output), then landed test + source in the same commit — the rubric's `PROVEN`
shape. Cycle 4's red was observed by temporarily unwiring the tab (recorded
candidly in the cycle log); the test and source still co-changed in one commit.

| Behavior | Class  | Evidence |
| -------- | ------ | -------- |
| A1  | PROVEN | cycle 1 red (`Found 0 widgets with key [<'matrix-scope-camera'>]`); co-committed test+source |
| A2  | PROVEN | cycle 2 red (`Bad state: No element` on `request-photos` key); co-committed |
| A3, A4 | PROVEN | cycle 3 red (settings key + check-label text found 0); co-committed |
| U27–U30 | PROVEN | cycle 1 red (same run as A1); matrix rows/columns/cells/marker |
| U31–U33 | PROVEN | cycle 2 red (request buttons absent); prompt outcome, default granted, idempotence |
| U34–U39 | PROVEN | cycle 3 red (settings routing + flow log absent) |
| U40 | PROVEN | cycle 4 red observed with the tab unwired (`Found 0 widgets with key [<'live-scope-camera'>]`); deviation candidly recorded in the cycle log |
| U41 | NOT_APPLICABLE | inherited characterization baseline (`widget_test.dart`), byte-identical to `0a13799` — verified by the independent subagent via git diff (empty) |
| U42–U44 | PROVEN (remediation) | brownfield additive: the affordances shipped in earlier cycles, so the new tests passed on first run — 001's precedent; meaning validated mechanically by the mutation re-run, which now kills the survivors these tests target (`check+` key mutant, `in+memory` label mutant; 27/27 post-remediation, quality A) |

### Weakened / skipped existing tests

None. `git diff 0a13799..HEAD -- example/test/widget_test.dart` is empty
(verified independently). The root package's 22-test suite is untouched and
green throughout (regression gate run in every cycle's gate step).

### tasks.md vs test list

All 22 behavior rows `DONE`/`BASELINE` and referenced by ticked tasks
(Phases 1–6, 8). Phase 7 (this audit) ticked on completion of this report.

## Findings

All findings were either remediated in Phase 8 or triaged as accepted. No `HIGH`
finding remains open.

| # | Severity | Finding | Resolution |
| - | -------- | ------- | ---------- |
| 1 | MED (smell pass) | Same-level A/U redundancy: the acceptance tests and unit tests are all widget tests at one level; A4/U39, A4/U36, A4/U34 overlap exactly (one bug fails 2–4 tests saying the same thing). | Remediated (R3): U44 pins the flow-log record at the pure-Dart controller level (a genuinely different loop), so the log behavior is no longer pinned only at the widget level. The remaining widget-level overlap between the end-to-end journey (A4) and its units is the rubric's sanctioned double-loop shape and stays. |
| 2 | MED (mutation) | Survivor `scope_flow_tile.dart` `key: ValueKey('check+${scope.id}')`: the per-scope Check action was implemented (cycle 2) but asserted by nothing. | Remediated (R1): U42 exercises the Check action (external status change → tap Check → chip + log). Kill re-verified. |
| 3 | LOW (mutation) | Survivor `outcome_matrix_screen.dart` `'simulator: in+memory adapter'`: the mode-chip label was unasserted. | Remediated (R2): U43 pins the label. Kill re-verified. |
| 4 | LOW (accepted) | 15 remaining survivors, all triaged equivalent-in-context: 5 style-only (cell/badge tints, border radii — the marker/dot and badge text are what carry the asserted surface), 5 prose strings (live-tab explanatory text), 3 `if (!mounted) return;` defensive guards (dispose races unreachable in these tests), 2 `main()` entry-point calls (widget tests never invoke `main()`; the `registerPermissionDependencies` call is behavior-proven by U41, `runApp` by every pump). | Accepted with rationale; documented here and in the mutation table below. |

## Mutation results

Tool: `mutation_test` 1.8.0 (dev-dependency of the example package for this
audit), builtin rule set, test command `flutter test
test/outcome_matrix_test.dart` run from `example/` via an XML config (recorded
in the cycle log; the report directory is untracked).

Initial scoped run — the 7 files the feature added/rewrote:

| File | Mutants | Undetected |
| ---- | ------- | ---------- |
| `example/lib/src/matrix_controller.dart` | 8 | 0 |
| `example/lib/src/flow_log_view.dart` | 2 | 0 |
| `example/lib/src/scope_flow_tile.dart` | 10 | 1 → remediated |
| `example/lib/main.dart` | 2 | 2 (entry-point, triaged) |
| `example/lib/src/matrix_grid.dart` | 25 | 3 (style, triaged) |
| `example/lib/src/outcome_matrix_screen.dart` | 9 | 1 → remediated |
| `example/lib/src/live_permission_panel.dart` | 20 | 10 (3 guards + 5 prose + 2 style, triaged) |
| **Total** | **76** | **17** (2 remediated + 15 equivalents) |

Post-remediation re-run over the three survivor-bearing files (tile, screen,
controller): **27 mutants, 0 undetected (100%, quality A)** — findings 2 and 3
are closed mechanically, and U44's controller-level pin corroborates the
controller's event record. No survivor remains inside any `DONE` behavior's
asserted surface.

## Traceability

| Criterion | Tests | End to end (real entry point) |
| --------- | ----- | ----------------------------- |
| AC-001 (compiles and runs on all supported platforms) | A1 (+ build evidence) | Yes — boots via `PermissionApp` in widget tests; `flutter build web --release` PASS; android/ios/macos scaffolding unchanged, web/windows/linux added |
| AC-002 (all scopes exercisable) | A2, U27, U29, U31–U33, U42 | Yes — every one of the 11 built-ins forced + requested through the real UI and port |
| AC-003 (matrix displays status transitions) | A3, U28, U30, U37–U39, U44 | Yes — active-cell marker + flow log, driven end to end and pinned at controller level |
| AC-004 (permanentlyDenied routes to settings) | A4, U34–U36 | Yes — no re-prompt, Open Settings offered only when permanently denied, launch result reported |

FR coverage: FR-001 (A2, U27), FR-002 (U28), FR-003 (U29, U30), FR-004 (U31–U33,
U42), FR-005 (U34–U36), FR-006 (U37–U39, U44), FR-007 (U40, U41, U43),
FR-008 (build/scaffold evidence in the cycle log — a build-time criterion, not a
widget behavior). Untested criteria: none. Tests tracing to nothing: none
(independent subagent mechanically confirmed all 22 rows resolve to real,
running tests by runner-reported name).

## What was not audited

- **On-device behavior of the live tab** (and the 4 federated packages behind
  it): no emulators/devices in this environment; the existing
  `example/integration_test` device suite remains the on-device evidence.
- **windows/linux desktop compilation**: no clang/cmake/ninja toolchain here;
  scaffolding committed, compile unproven in this run.
- **The 15 triaged-equivalent survivors' surfaces** (tints, prose, guards,
  `main()`): judged equivalent, not exhaustively argued.
- **Performance/long-run behavior** (e.g. flow log growth unbounded in a long
  session): no criterion, no test, not assessed.
- **Coverage as a formatted number**: not run for the example package (widget
  tests; the mutation runs are the strength evidence).
