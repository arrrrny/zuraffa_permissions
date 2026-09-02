# Cycle Log: 001-method-channel-port

Append only. Newest last. Every entry's `red` block is the evidence that the test
existed and failed before the behavior was counted. The feature is brownfield —
the bridge stack shipped untested with `dcf1661` — so every cycle below is
additive coverage whose honest red is established with a deliberate mutant
injected into the subject, observed failing via the profile's single command
(`flutter test test/method_channel_port_test.dart --plain-name "<id>:"`), then
reverted (the exact protocol spec `001-permission-port`'s cycles 1–5 used).
Machine-readable matrix: `tdd/mutant-run.md` (17/17 KILLED, 0 SURVIVED).

## Baseline

- suite: `flutter test` -> no test dir (the stack shipped with zero tests)
- dependency state: `zfa tdd init` had broken pub solve (`test: ^1.0.0` added
  alongside `flutter_test`) and generated a non-compiling `lib/app.dart`
  (imports `package:zuraffa_flutter`, not a dependency). Fixed first — see the
  repo's misfire issues; the fix commit precedes this feature's commit.
- after fix: `flutter pub get` resolves, `flutter analyze` clean, commit `7411534` tree
- recorded: cycle 0, before any change

## Cycle 1: U1 — PermissionWireStatus exposes exactly the six stable wire strings (FR-001)

- test: `test/method_channel_port_test.dart::wire vocabulary (FR-001) U1` (new)
- red: passed on first run — brownfield additive coverage. Deliberate mutant:
  `PermissionWireStatus.granted` renamed to `'GRANTED'` — the six-string set no
  longer equals the documented vocabulary and the test failed. Reverted.
- green: no implementation change required. Suite `flutter test` -> 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit (test+evidence co-change)

## Cycle 2: U2 — instance defaults to the safe fallback before any registration (FR-002)

- test: `test/method_channel_port_test.dart::platform instance registry (FR-002) U2` (new)
- red: passed on first run. Deliberate mutant: the static field's initializer
  removed (`static late ... _instance;`) — the pristine read fails with
  LateInitializationError, mutant KILLED. NOTE: the first draft of this test
  assigned the instance itself before asserting, which let the mutant SURVIVE;
  the test was rewritten to read the shipped default directly (the mutant
  protocol doing its job — a vacuous assertion caught before it landed).
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 3: U3 — assigning instance registers a custom implementation reads observe (FR-002)

- test: `test/method_channel_port_test.dart::platform instance registry (FR-002) U3` (new)
- red: passed on first run. Deliberate mutant: the instance setter's assignment
  dropped (token still verified, registration silently ignored) — the
  `identical(...)` assertion failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 4: U4 — fallback checkPermissions reports every scope undetermined (FR-003)

- test: `test/method_channel_port_test.dart::default fallback semantics (FR-003) U4` (new)
- red: passed on first run. Deliberate mutant: the fallback's
  `checkPermissions` reports `'granted'` instead of `'undetermined'` — failed.
  Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 5: U5 — fallback requestPermissions reports every scope undetermined (FR-003)

- test: `test/method_channel_port_test.dart::default fallback semantics (FR-003) U5` (new)
- red: passed on first run. Deliberate mutant: the fallback's
  `requestPermissions` reports `'granted'` — failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 6: U6 — fallback openSettings returns false (FR-003)

- test: `test/method_channel_port_test.dart::default fallback semantics (FR-003) U6` (new)
- red: passed on first run. Deliberate mutant: fallback `openSettings` returns
  `true` (claims it can launch) — failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 7: U7 — checkPermissions invokes the shared channel with the scope list (FR-004)

- test: `test/method_channel_port_test.dart::method-channel client (FR-004) U7` (new)
- red: passed on first run. Deliberate mutant: the client invokes method
  `'checkPermission'` (wrong protocol name) — the captured MethodCall's method
  assertion failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 8: U8 — requestPermissions invokes method requestPermissions (FR-004)

- test: `test/method_channel_port_test.dart::method-channel client (FR-004) U8` (new)
- red: passed on first run. Deliberate mutant: method name mutated to
  `'requestPermission'` — failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 9: U9 — a null platform reply normalizes to an empty map (FR-004)

- test: `test/method_channel_port_test.dart::method-channel client (FR-004) U9` (new)
- red: passed on first run. Deliberate mutant: the `raw == null` guard removed —
  the null reply crashed with a null-check error instead of degrading to `{}`.
  Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 10: U10 — non-string reply keys/values are stringified (FR-004)

- test: `test/method_channel_port_test.dart::method-channel client (FR-004) U10` (new)
- red: passed on first run. Deliberate mutant: the `'${k}': '${v}'` stringify
  normalization replaced with hard `as String` casts — the int-keyed reply
  crashed instead of normalizing. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 11: U11 — openSettings returns the channel bool; null degrades to false (FR-004)

- test: `test/method_channel_port_test.dart::method-channel client (FR-004) U11` (new)
- red: passed on first run. Deliberate mutant: `?? false` removed — the null
  verdict surfaced as null instead of `false`. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 12: U12 — check maps every known wire status onto the typed enum (FR-005)

- test: `test/method_channel_port_test.dart::adapter wire-to-enum bridge U12` (new)
- red: passed on first run. Deliberate mutant: wire `'denied'` mapped onto
  `PermissionStatus.granted` — failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 13: U13 — unknown/missing wire values degrade to undetermined (FR-005)

- test: `test/method_channel_port_test.dart::adapter wire-to-enum bridge U13` (new)
- red: passed on first run. Deliberate mutant: the mapping's `default` branch
  returns `granted` (no forward-compat degradation) — both the unknown-wire and
  the missing-scope assertions failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 14: U14 — request returns scope + mapped status + a real requestedAt (FR-006)

- test: `test/method_channel_port_test.dart::adapter wire-to-enum bridge U14` (new)
- red: passed on first run. Deliberate mutant: `requestedAt: 0` (the exact
  regression spec `001-permission-port` cycle 7 caught on the in-memory path) —
  failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 15: U15 — openSettings delegates to the platform verdict (FR-006)

- test: `test/method_channel_port_test.dart::adapter wire-to-enum bridge U15` (new)
- red: passed on first run. Deliberate mutant: the adapter stops delegating and
  always returns `false` — the launched-side assertion failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 16: U16 — a constructor-supplied platform overrides the registered instance (FR-007)

- test: `test/method_channel_port_test.dart::adapter wire-to-enum bridge U16` (new)
- red: passed on first run. Deliberate mutant: the constructor ignores the
  injected platform (routes everything through the registered instance) — the
  injected-granted assertion failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Cycle 17: U17 — without an override the adapter routes through the registered instance (FR-007)

- test: `test/method_channel_port_test.dart::adapter wire-to-enum bridge U17` (new)
- red: passed on first run. Deliberate mutant: the no-override path fabricates a
  fresh `DefaultZuraffaPermissionsPlatform()` instead of consulting the
  registered instance — the registered-limited assertion failed. Reverted.
- green: no implementation change required. Suite 17 passed.
- refactor: none needed.
- commit: this feature's TDD commit

## Summary

- suite: `flutter test` -> 17 passed, 0 failed (subpackage);
  root package `dart test` -> 22 passed, 0 failed (no cross-package damage)
- deliberate mutants: 17 injected, 17 killed, 0 survived (`tdd/mutant-run.md`)
- misfires during the feature: recorded as repo issues (see PR body) — the
  `zfa tdd init` baseline breakage (dependency conflict + non-compiling
  scaffold) was fixed before cycle 0; no cycle misfired.
