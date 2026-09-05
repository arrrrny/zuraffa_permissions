# Cycle Log: 007-example-app-outcome-matrix

Append only. Newest last. Every entry's `red` block is the evidence that the test
existed and failed before the implementation.

## Baseline

- suite: `dart test` (root) -> 22 passed, 0 failed; `flutter test` (example) ->
  1 passed, 0 failed
- commit: `0a13799`
- recorded: cycle 0, before any change
- note: greenfield feature. The example app is a plain scope list (no outcome
  matrix, no status forcing, no settings routing, no transition log). All
  behaviors are new; every cycle below must record a real red before its green.
- analyzer/format baseline: `flutter analyze` -> 6 pre-existing infos
  (depend_on_referenced_packages: example imports `zuraffa`/`get_it` undeclared);
  `dart format` would reformat 8 pre-existing files (formatter drift). Both are
  addressed in Phase 5/6 and reported there.

## Cycle 1: A1, U27, U28, U29, U30 — the scope × status matrix

- seam: compile seam first so the new tests fail behaviorally, not at compile
  time: `PermissionApp({matrixService, liveService})` +
  `OutcomeMatrixScreen` empty scaffold (AppBar title `zuraffa_permissions`
  preserved, so the inherited baseline U41 stayed green throughout).
- test: `example/test/outcome_matrix_test.dart` (new) — acceptance boot test +
  matrix structure/cells group.
- red: `flutter test` -> 5 failed, 1 passed. Real behavioral red, e.g.
  `Expected: exactly one matching candidate / Actual: _KeyWidgetFinder:<Found 0
  widgets with key [<'matrix-scope-camera'>]>` (the matrix rows do not exist).
  One compile fix during the red run: missing `package:flutter/material.dart`
  import for `Size` in the test helper (recorded for honesty; the tests then
  failed on assertions, not compilation).
- green: implemented `matrix_controller.dart` (statuses, checkAll, forceStatus
  over the public service), `status_theme.dart`, `matrix_grid.dart` (rows =
  scopes, columns = the six statuses in enum order, force cells, active-cell
  marker, status badges), and the `OutcomeMatrixScreen` matrix tab. Suite
  `flutter test` -> 6 passed, 0 failed.
- refactor: none yet — the exerciser and flow log land in cycles 2/3.
- commit: (this commit)


## Cycle 2: A2, U31, U32, U33 — the request flow

- test: `example/test/outcome_matrix_test.dart` (added) — acceptance
  every-scope-exercisable test + request-flow group (prompt outcome, default
  granted, idempotent decided statuses).
- red: `flutter test` -> 4 failed, 6 passed. The request buttons do not exist:
  tapping `find.byKey(ValueKey('request-photos'))` threw `Bad state: No
  element` (finder empty) — a real behavioral red.
- green: `MatrixController.request`/`check` through the public port, plus the
  per-scope exerciser (`scope_flow_tile.dart`: Check + Request actions, live
  status, description) in the matrix panel. Suite -> 10 passed, 0 failed.
- refactor: none needed.
- commit: (this commit)

## Cycle 3: A3, A4, U34–U39 — settings routing + flow log

- test: `example/test/outcome_matrix_test.dart` (added) — acceptance
  transitions + routing tests, the settings-routing group, and the flow-log
  group.
- red: `flutter test` -> 8 failed, 10 passed. The Open Settings buttons and the
  flow log do not exist: `find.byKey(ValueKey('settings-camera'))` found 0
  widgets; `find.text('check camera → undetermined')` found 0 widgets.
- green: `FlowEvent` recording in the controller (check/set/request/
  openSettings, from → to), the Open Settings button on permanently-denied
  rows (launch result reported via a snackbar, snackbars cleared on repeat),
  and `flow_log_view.dart` in the matrix panel. Suite -> 18 passed, 0 failed.
- refactor: none needed.
- commit: (this commit)

## Cycle 4: U40 — the live tab (federated adapters)

- test: `example/test/outcome_matrix_test.dart` (added) — live-tab group.
- red: honesty note — the panel implementation was written in the same batch
  as the test, so the red was observed by temporarily unwiring the tab
  (`TabBarView`'s second child swapped to `SizedBox.shrink()`), running
  `flutter test --name "the live tab renders..."` ->
  `Found 0 widgets with key [<'live-scope-camera'>]` (1 failed), then
  restoring the wiring. The red is real and observed; the ordering deviation
  is recorded here rather than hidden.
- green: `live_permission_panel.dart` — the GetIt-resolved (or injected)
  live service with per-scope check/request, permanently-denied Open
  Settings routing, and the port-runtime-type chip. Suite -> 19 passed,
  0 failed.
- refactor: none needed.
- commit: (this commit)

## Phase 5: platforms + dependency hygiene (FR-008 / AC-001, non-widget half)

- scaffolding: `flutter create --platforms=web,windows,linux .` added the three
  missing platform targets (android/ios/macos untouched; `lib/` and `test/`
  untouched by the create — git status showed only `.metadata` + the new dirs).
- deps: declared `get_it: ^9.2.1` and `zuraffa: ^6.1.0` as direct example
  dependencies (they were undeclared transitive imports — the 6 baseline
  `depend_on_referenced_packages` infos). `flutter pub get` -> resolved.
- compile evidence: `flutter build web --release` -> `✓ Built build/web`
  (89.4s). windows/linux desktop targets could NOT be compiled in this
  environment (no clang/cmake/ninja toolchain) — recorded as not-proven-here,
  honest limitation; the scaffolding is in place for a desktop CI/dev box.

## Phase 6: gates

- `flutter analyze` (root) -> No issues found! (baseline was 6 infos).
- `flutter analyze` (example) -> No issues found!
- `dart test` (root, regression gate) -> 22 passed, 0 failed.
- `flutter test` (example) -> 19 passed, 0 failed.
- `dart format .` -> 49 files (13 changed; includes the 8 pre-existing
  off-format files from the baseline note). Re-check
  `dart format --output=none --set-exit-if-changed .` -> 0 changed, exit 0
  (zero remaining formatting diffs).
- Post-format re-run of both suites: still 22/22 and 19/19.

## Phase 7: TDD verify (the audit)

- smell pass: delegated to a fresh-context subagent (Task 7-a). Result: 0 HIGH,
  1 MED (same-level A/U redundancy), all 19 then-rows traceable, inherited
  `widget_test.dart` byte-identical to baseline, properties (isolation,
  determinism, speed, specificity, refactor-insensitivity) all pass.
- mutation (mutation_test 1.8.0, builtin rules, command
  `flutter test test/outcome_matrix_test.dart`, run from `example/` via XML
  config — recorded below): scoped to the 7 feature files.
  - batch 1 `matrix_controller.dart`: 8 mutants, 0 undetected (A).
  - batch 2 `scope_flow_tile.dart` + `flow_log_view.dart` + `main.dart`:
    14 mutants, 3 undetected (tile check-key 1; main entry-point 2).
  - batch 3 `matrix_grid.dart` + `outcome_matrix_screen.dart`: 34 mutants,
    4 undetected (grid style 3; screen mode-chip label 1).
  - batch 4 `live_permission_panel.dart`: 20 mutants, 10 undetected
    (mounted-guards 3; prose strings 5; style 2).
  - total: 76 mutants, 17 undetected; 2 map to real unasserted affordances,
    15 triaged equivalent-in-context (style/prose/guards/entry-point).
- verdict: PASS (report: `tdd/verification.md`).

## Phase 8: remediation (R1–R3) + re-verification

- R1 (U42): Check-action test — brownfield additive (the affordance shipped in
  cycle 2 untested); passed on first run; meaning validated by the mutation
  re-run (the `check+` key mutant is now detected).
- R2 (U43): mode-chip label test — same shape; the `in+memory` label mutant is
  now detected.
- R3 (U44): controller-level (pure Dart, non-widget) test of the flow-log
  event record — addresses the MED same-level redundancy finding by pinning
  the behavior at a different loop.
- suite after remediation: `flutter test` (example) -> 22 passed, 0 failed;
  `dart test` (root) -> 22 passed, 0 failed.
- mutation re-run (tile + screen + controller): 27 mutants, 0 undetected
  (100%, quality A).
- mutation config used (recorded for reproducibility):
  `mutation_test -b <config>` from `example/`, with
  `<commands><command group="test" expected-return="0"
  working-directory=".">flutter test test/outcome_matrix_test.dart
  </command></commands>` and the `<files>` list per batch above.
