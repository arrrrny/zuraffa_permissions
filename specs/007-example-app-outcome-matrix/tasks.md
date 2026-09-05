# Tasks: 007-example-app-outcome-matrix

> TDD plan derived from `spec.md` (issue #7) on commit `0a13799`. Behavior ids in
> `[Axx]`/`[Uxx]` reference `tdd/test-list.md`. Greenfield feature: the example app
> is a plain scope list today; every behavior below is new work, red → green per
> cycle. Constitution `PRINCIPLE_III` (Test-First, NON-NEGOTIABLE) applies: no
> behavior is declared done without an observed-failing test first.
>
> Test tasks carry the behavior id; the loop ticks them as the test goes red →
> green. Each cycle's commit carries test + source together with the cycle log's
> red evidence recorded before the source change lands.

## Phase 0 — Planning (this commit)

- [X] 0.1 [P] Write `spec.md` (FR-001..FR-008, AC-001..AC-004), `tdd/test-list.md`
      (A1–A4, U27–U41), and open `tdd/cycle-log.md` with the baseline entry.

## Phase 1 — Compile seam + acceptance shell

- [X] 1.1 [P] Add the compile seam so the new tests can fail behaviorally instead
      of at compile time: `PermissionApp({matrixService, liveService})`, an empty
      `OutcomeMatrixScreen` scaffold (AppBar title `zuraffa_permissions` preserved
      so the inherited baseline test U41 stays green), and a `MatrixController`
      skeleton. Suite stays green after this step.
- [ ] 1.2 [P] - [X] 1.2 [P] [A1] [U27] [U28] [U29] [U30] Write the shell/matrix tests; observe
      red; implement the matrix grid (rows = scopes, columns = the six statuses,
      force cells, active-cell marker) + controller state. Green.

## Phase 2 — Request flow

- [X] 2.1 [P] [U31] [U32] [U33] [A2] Write the request-flow tests; observe red
      (no request actions); implement `controller.request` + the per-scope
      exerciser rows. Green.

## Phase 3 — Permanently denied → settings + flow log

- [ ] 3.1 [P] [U34] [U35] [U36] [A4] [U37] [U38] [U39] [A3] Write the
      settings-routing and flow-log tests; observe red; implement the Open Settings
      routing, launch-result reporting, and the flow log view. Green.

## Phase 4 — Live tab (federated adapters)

- [ ] 4.1 [P] [U40] Write the live-tab test; observe red; implement
      `LivePermissionPanel` over the injected/GetIt-resolved service. Green.

## Phase 5 — Platforms (FR-008, AC-001 non-widget half)

- [ ] 5.1 [P] Add `web`/`windows`/`linux` scaffolding to `example/`
      (`flutter create --platforms=web,windows,linux .`), keep android/ios/macos
      untouched, and record `flutter build web --release` as the compile evidence.
      Fix the example's undeclared direct imports (`zuraffa`, `get_it`) so
      `flutter analyze` is clean.

## Phase 6 — Gates

- [ ] 6.1 [P] `flutter analyze` (root + example) — no new issues; `dart test`
      (root) green; `flutter test` (example) green; `dart format .` zero remaining
      diffs; report actual counts.

## Phase 7 — TDD verify

- [ ] 7.1 [P] Cold-context audit per `.specify/extensions/tdd/commands/speckit.tdd.verify.md`
      (smell pass delegated to a fresh-context subagent; deliberate mutants for the
      example sources); write `tdd/verification.md` with the verdict; remediate if
      needed; commit.
