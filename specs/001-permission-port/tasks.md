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
- [X] 1.3 [P] [U9] Add a test: `request()` on a scope currently `restricted`
      returns it unchanged (no re-prompt) — FR-005/FR-002.
- [X] 1.4 [P] [U10] Add a test: `check()` returns the explicitly set `limited` /
      `restricted` status — FR-002.
- [X] 1.5 [P] [U22] Add a test: `registerPermissionDependencies` also registers the
      permission-scope usecases (get/list/create) so they resolve from GetIt —
      FR-007.

## Phase 2 — Resolve spec/impl clarifications before asserting

- [X] 2.1 [P] Confirm FR-001: decided — `check` → `PermissionStatus`, `request` →
      `PermissionRequestResult` (scope + status + requestedAt), `openSettings` →
      `bool`. Captured as behavior `U23`.
- [X] 2.2 [P] Confirm the built-in set: decided — `tracking` is the 11th built-in
      scope (FR-003 + Summary updated). Captured as behavior `U24`.

## Phase 3 — Gate

- [ ] 3.1 Run `dart test` and confirm the full suite is green (18 existing + the new
      change tests) before considering the feature complete. (Inside-out library, so
      there is no separate outer-loop acceptance test to gate on.)

## Phase 4 — Apply the two resolved spec changes (tests first)

- [X] 4.1 [P] [U24] Add `tracking` as the 11th built-in `PermissionScope` in
      `BuiltInPermissionScopes` (and its `all` list); update the built-in count
      assertions in the tests from ten to eleven — FR-003.
- [X] 4.2 [P] [U23] Change `PermissionPort.request` (and `InMemoryPermissionAdapter`
      / `PermissionService`) to return `PermissionRequestResult` (scope + status +
      requestedAt); adapt the existing request-path tests (U3, U4, U5, U6, U8, U9,
      U17) to assert the new return type instead of raw `PermissionStatus` — FR-001.

## Phase 5 — TDD remediation (from /speckit.tdd.verify, PASS_WITH_GAPS)

Non-blocking quality improvements surfaced by the audit. The feature is complete;
these raise two tests to the standard their siblings already meet.

- [ ] 5.1 [P] Fix the misleading test name "all ten built-ins are registered with
      zero configuration" (it actually asserts 11 ids and `hasLength(11)`). Rename
      to reflect the eleven built-ins, and align the stale "the ten built-ins"
      comments at `built_in_permission_scopes.dart:3` and `permission_service.dart:17`.
      Proof: `dart test -n "all eleven built-ins are registered with zero configuration"`
      passes and `grep -rn "ten built-ins"` finds no stale references. (Finding #1)
- [ ] 5.2 [P] Strengthen `test/permission_test.dart:42` from
      `BuiltInPermissionScopes.tracking.platformGroup isNotNull` to the concrete
      `equals('privacy')`, matching the camera check at line 30. Proof:
      `dart test -n "tracking is the 11th built-in scope, registered zero-config"`
      passes. (Finding #2, borderline vacuous assertion)
