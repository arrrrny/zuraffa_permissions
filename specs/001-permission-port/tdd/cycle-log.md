# Cycle Log: 001-permission-port

Append only. Newest last. Every entry's `red` block is the evidence that the test
existed and failed before the implementation.

## Baseline

- suite: `dart test` -> 13 passed, 0 failed
- commit: `40264b9`
- recorded: cycle 0, before any change
- note: feature is brownfield; the existing suite already passes. The test list
  captures the spec's behaviors and flags the coverage gaps (U1, U8, U9, U10, U22)
  as the remaining work.

## Cycle 1: U1 — PermissionStatus enumerates exactly the six states (FR-002)

- test: `test/permission_test.dart::permission status enum (FR-002) enumerates exactly the six required states` (new)
- red: passed on first run — behavior already implemented (brownfield additive
  coverage). Validated meaning with a deliberate mutant: adding a 7th enum value
  `unknown` made the test fail with `Expected: ... has length of <6> Which: has
  length of <7>`. Mutant reverted; suite green again.
- green: no implementation change required; the enum already exposes the six
  states. Full suite `dart test` -> 14 passed, 0 failed.
- refactor: none needed.
- commit: 7d06a4f

## Cycle 2: U8 — request() on a `limited` scope returns it unchanged (FR-002/FR-005)

- test: `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) a scope currently limited is returned unchanged and not re-prompted (FR-005)` (new)
- red: passed on first run — behavior already implemented (brownfield additive
  coverage). Validated with a deliberate mutant: removing `limited` from the
  adapter's idempotency guard (`current == PermissionStatus.limited`) let the scope
  fall through to the prompt path and return `granted`; the test failed. Mutant
  reverted; suite green again.
- green: no implementation change required. Full suite `dart test` -> 15 passed, 0 failed.
- refactor: none needed.
- commit: efae09b

## Cycle 3: U9 — request() on a `restricted` scope returns it unchanged (FR-002/FR-005)

- test: `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) a scope currently restricted is returned unchanged and not re-prompted (FR-005)` (new)
- red: passed on first run — behavior already implemented (brownfield additive
  coverage). Validated with a deliberate mutant: dropping `restricted` from the
  idempotency guard let the scope fall through to the prompt path; the test failed.
  Mutant reverted; suite green again.
- green: no implementation change required. Full suite `dart test` -> 16 passed, 0 failed.
- refactor: none needed.
- commit: <see below>

