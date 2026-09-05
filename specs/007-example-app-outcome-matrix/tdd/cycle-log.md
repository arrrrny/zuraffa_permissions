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
