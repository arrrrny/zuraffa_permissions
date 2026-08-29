# Tasks: 001-permission-port

> TDD plan derived from `spec.md` on commit `40264b9`. Behavior ids in `[Uxx]`
> reference `tdd/test-list.md`. The core feature is already implemented and its
> existing tests pass (13/13, green baseline). The tasks below close the coverage
> gaps the plan identified. The implementation already supports each gap, so each
> is a "write the missing test" task rather than a behavior change. Test tasks
> carry the behavior id; the loop ticks them as the test goes red→green.
>
> Constitution `PRINCIPLE_III` (Test-First, NON-NEGOTIABLE) applies: no behavior is
> declared done without an observed-failing test first.

## Phase 1 — Close coverage gaps (tests first)

- [X] 1.1 [P] [U1] Add a test asserting `PermissionStatus` enumerates exactly the
      six states (granted, denied, permanentlyDenied, undetermined, restricted,
      limited) — FR-002.
- [X] 1.2 [P] [U8] Add a test: `request()` on a scope currently `limited` returns
      it unchanged (no re-prompt) — FR-005/FR-002.
- [ ] 1.3 [P] [U9] Add a test: `request()` on a scope currently `restricted`
      returns it unchanged (no re-prompt) — FR-005/FR-002.
- [ ] 1.4 [P] [U10] Add a test: `check()` returns the explicitly set `limited` /
      `restricted` status — FR-002.
- [ ] 1.5 [P] [U22] Add a test: `registerPermissionDependencies` also registers the
      permission-scope usecases (get/list/create) so they resolve from GetIt —
      FR-007.

## Phase 2 — Resolve spec/impl clarifications before asserting

- [ ] 2.1 [P] Confirm FR-001: must `PermissionPort` return "Result-shaped" outcomes,
      or is raw `PermissionStatus` (current behavior) correct? Decide before
      adding/keeping an assertion.
- [ ] 2.2 [P] Confirm the built-in set: the spec summary lists a `tracking` scope
      not present in FR-003's ten. Decide the intended built-ins.

## Phase 3 — Gate

- [ ] 3.1 Run `dart test` and confirm the full suite is green (13 existing + the new
      gap tests) before considering the feature complete. (Inside-out library, so
      there is no separate outer-loop acceptance test to gate on.)
