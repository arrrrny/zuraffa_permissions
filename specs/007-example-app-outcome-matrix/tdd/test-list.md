---
feature: 007-example-app-outcome-matrix # spec-kit feature directory name
loop: outside-in # user-visible surface: the example app's screens are the entry point
profile: .specify/memory/tdd-profile.md # stack profile the commands must read
spec_criteria: 4 # AC-001..AC-004 from issue #7; FR-001..FR-008 back them
planned_at: 0a13799 # short SHA the list was derived from
updated_at: 0a13799 # short SHA of the last change (planning; states move per cycle)
suite_baseline: green # root dart test 22/22; example flutter test 1/1
---

# Test List: 007-example-app-outcome-matrix

> Derived from `spec.md` (issue #7) on commit `0a13799`. Greenfield feature: the
> example app today is a plain scope list — no outcome matrix, no way to force the
> six statuses, no permanently-denied → settings demonstration, no transition
> visualization. `loop: outside-in` because the feature's surface is the Flutter
> app itself; the acceptance tests drive the real `PermissionApp` root through the
> real `PermissionService` public API.
>
> **Loop runner note.** The feature lives in the `example/` Flutter package, so the
> loop's commands are the Flutter wrapper of the profile's `dart` runner, run from
> `example/`: single `flutter test --name "<name>"`, file
> `flutter test test/outcome_matrix_test.dart`, suite `flutter test`. The root
> package's `dart test` suite (22 tests) is a regression gate: it must stay green
> untouched. The profile's in-memory-fake convention is preserved: the simulator
> tab's double is the production `InMemoryPermissionAdapter` — no mocking library.

## Outer loop: acceptance behaviors

One per acceptance criterion in `spec.md`. Each stays red until the feature works
end to end through its real entry point (the app root, real taps).

| id  | behavior                                                                                                    | traces  | kind    | state   | test |
| --- | ----------------------------------------------------------------------------------------------------------- | ------- | ------- | ------- | ---- |
| A1  | The example app runs: it boots to the outcome-matrix home listing every built-in scope (compile/run evidence for the other platforms is the cycle log's `flutter build web` + platform scaffolding entries) | AC-001, FR-008 | example | DONE | `example/test/outcome_matrix_test.dart::acceptance (issue #7) the app boots to the outcome-matrix home` ||
| A2  | Every built-in scope is exercisable: each of the eleven scopes can be placed into a status and requested through the real UI | AC-002, FR-001, FR-003, FR-004 | example | DONE | `example/test/outcome_matrix_test.dart::acceptance (issue #7) every built-in scope is exercisable end to end` |
| A3  | The outcome matrix visually displays status transitions: the active cell marker moves and the flow log records each from → to | AC-003, FR-002, FR-006 | example | DONE | `example/test/outcome_matrix_test.dart::acceptance (issue #7) the matrix visually displays status transitions` |
| A4  | The permanentlyDenied path routes to settings: request does not re-prompt, Open Settings is offered, and the launch result is reported | AC-004, FR-005 | example | DONE | `example/test/outcome_matrix_test.dart::acceptance (issue #7) the permanently denied path routes to settings` |

## Inner loop: unit behaviors

Grouped by the component that owns them. Ids continue the repository's `U` series
(001-permission-port used U1–U26); this feature starts at U27.

### `example/lib/src/matrix_controller.dart` + `example/lib/src/matrix_grid.dart`

| id  | behavior                                                                                     | traces      | kind    | state   | test |
| --- | -------------------------------------------------------------------------------------------- | ----------- | ------- | ------- | ---- |
| U27 | The matrix renders a row for every built-in scope — all eleven ids, including the ten the issue names plus `tracking` | FR-001, AC-002 | example | DONE | `example/test/outcome_matrix_test.dart::outcome matrix structure (FR-001/FR-002) renders a matrix row for every built-in scope` |
| U28 | The matrix presents the six `PermissionStatus` values as columns, in enum order | FR-002, AC-003 | example | DONE | `example/test/outcome_matrix_test.dart::outcome matrix structure (FR-001/FR-002) presents the six statuses as columns in enum order` |
| U29 | Tapping a scope × status cell forces that combination: all 66 (11 × 6) combinations update the scope's status chip | FR-003, AC-002 | example | DONE | `example/test/outcome_matrix_test.dart::scope × status cells (FR-003) every cell forces its scope into that status` |
| U30 | The matrix marks the current combination: the active-cell marker sits in the forced status's cell and moves with it | FR-003, AC-003 | example | DONE | `example/test/outcome_matrix_test.dart::scope × status cells (FR-003) the active cell marker tracks the forced status` |

### `example/lib/src/matrix_controller.dart` (request flow)

| id  | behavior                                                                                     | traces      | kind    | state   | test |
| --- | -------------------------------------------------------------------------------------------- | ----------- | ------- | ------- | ---- |
| U31 | Requesting an `undetermined` scope resolves the prepared prompt outcome and records it (sticky) | FR-004, AC-002 | example | DONE | `example/test/outcome_matrix_test.dart::request flow (FR-004) request on an undetermined scope resolves the prepared prompt outcome` |
| U32 | Requesting with no prepared outcome defaults to `granted`                                    | FR-004      | example | DONE | `example/test/outcome_matrix_test.dart::request flow (FR-004) request with no prepared outcome defaults to granted` |
| U33 | Requesting an already-decided scope (`granted`/`denied`/`restricted`/`limited`) returns the status unchanged (idempotent) | FR-004 | example | DONE | `example/test/outcome_matrix_test.dart::request flow (FR-004) request on an already-decided status returns it unchanged` |

### `example/lib/src/outcome_matrix_screen.dart` (settings routing)

| id  | behavior                                                                                     | traces      | kind    | state   | test |
| --- | -------------------------------------------------------------------------------------------- | ----------- | ------- | ------- | ---- |
| U34 | Requesting a `permanentlyDenied` scope does not re-prompt (a prepared outcome is ignored) and the row offers Open Settings | FR-005, AC-004 | example | DONE | `example/test/outcome_matrix_test.dart::permanently denied → settings (FR-005) request on a permanently denied scope does not re-prompt and offers Open Settings` |
| U35 | Open Settings is offered only while the scope is `permanentlyDenied`                         | FR-005      | example | DONE | `example/test/outcome_matrix_test.dart::permanently denied → settings (FR-005) Open Settings appears only for permanently denied scopes` |
| U36 | Tapping Open Settings launches settings and reports the result (`launched` / `unavailable`)   | FR-005, AC-004 | example | DONE | `example/test/outcome_matrix_test.dart::permanently denied → settings (FR-005) tapping Open Settings reports the launch result` |

### `example/lib/src/flow_log_view.dart` + controller events

| id  | behavior                                                                                     | traces      | kind    | state   | test |
| --- | -------------------------------------------------------------------------------------------- | ----------- | ------- | ------- | ---- |
| U37 | The flow log records a check entry for every scope when the app boots                        | FR-006, AC-003 | example | DONE | `example/test/outcome_matrix_test.dart::flow log (FR-006) the flow log records the boot-time check of every scope` |
| U38 | The flow log records forced statuses and requests with their from → to transitions           | FR-006, AC-003 | example | DONE | `example/test/outcome_matrix_test.dart::flow log (FR-006) the flow log records set and request transitions` |
| U39 | The flow log records the openSettings event with its launch result                           | FR-006, AC-004 | example | DONE | `example/test/outcome_matrix_test.dart::flow log (FR-006) the flow log records the openSettings launch result` |

### `example/lib/src/live_permission_panel.dart` (federated wiring)

| id  | behavior                                                                                     | traces      | kind    | state   | test |
| --- | -------------------------------------------------------------------------------------------- | ----------- | ------- | ------- | ---- |
| U40 | The live tab renders the live service's scopes with check/request actions (the GetIt wiring itself is covered by the inherited baseline test U41) | FR-007 | example | PENDING | `example/test/outcome_matrix_test.dart::live tab (FR-007) the live tab renders the live service's scopes with check and request actions` |
| U41 | Existing baseline: `registerPermissionDependencies` wires the stack onto GetIt and the app renders (unchanged, inherited) | FR-007 | example | BASELINE | `example/test/widget_test.dart::permission app renders and wires the service` |

## Invariants and edge cases still to place

None open. The settings-unavailable edge (`settingsLaunchable = false`) is pinned
inside U36; the no-re-prompt boundary (permanentlyDenied vs merely denied) is the
U34/U35 pair.

## Out of scope

- Platform-adapter packages' own unit tests: out of scope for the example feature
  (profile records they ship none; integration tests cover them on devices).
- Real-OS outcome forcing: impossible on demand by design — that is why the
  simulator tab exists; the live tab demonstrates the real flow.
- `web`/`windows`/`linux` federated adapter packages: do not exist; the pure-Dart
  fallback is the documented behavior. Verified as build/scaffold evidence in the
  cycle log, not as a widget behavior.
- Performance/load: no requirement, no test.

## Verification commands

Copied verbatim from `.specify/memory/tdd-profile.md` at planning time (root
package), plus the example-package wrapper this feature's loop actually runs —
the profile records the stack's runner as `package:test`, which `flutter test`
wraps for the Flutter `example/` package:

- Root suite (regression gate): `dart test`
- Example single test: `flutter test --name "{name}"`
- Example one file: `flutter test {file}`
- Example full suite: `flutter test`
- Coverage: `flutter test --coverage`
- Mutation (root package, changed files): `dart run mutation_test` — not
  applicable to the Flutter example package without a `flutter test` runner
  config; the verify phase uses deliberate mutants for the example sources
  (rubric's fallback path).
