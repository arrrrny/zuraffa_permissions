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

