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
