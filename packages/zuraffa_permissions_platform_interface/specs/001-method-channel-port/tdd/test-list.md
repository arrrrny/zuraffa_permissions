---
feature: 001-method-channel-port
loop: inside-out # bridge library; the public API is the test surface
profile: .specify/memory/tdd-profile.md # flutter stack profile (flutter test)
spec_criteria: 7 # the 7 FRs (FR-001..FR-007) act as the criteria
planned_at: 7411534 # short SHA the list was derived from (master)
updated_at: 7411534
suite_baseline: green # 0 tests at planning; baseline = dependency solve + analyze clean after the init misfire fix
---

# Test List: 001-method-channel-port

> Derived from `spec.md`. The feature is **brownfield**: the bridge stack is
> implemented (shipped with `dcf1661`) but has ZERO tests — every behavior below
> is additive coverage, written test-first per the repo's TDD workflow. Because
> the implementation already exists, each cycle's honest-red is validated the
> way spec `001-permission-port`'s cycles were: where a test passes on first
> run, a deliberate mutant is injected into the subject, the test is observed
> failing, and the mutant is reverted (recorded in the cycle log).

## Outer loop: acceptance behaviors

None. `inside-out` library — the public API (`PermissionWireStatus`,
`ZuraffaPermissionsPlatform`, `MethodChannelZuraffaPermissions`,
`MethodChannelPermissionAdapter`) is the test surface; there is no user-visible
outer loop.

## Inner loop: unit behaviors

Grouped by the component from the implementation that owns them.

### `lib/src/permission_platform_interface.dart` (FR-001, FR-002, FR-003)

| id  | behavior                                                                                                   | traces | kind    | state   | test |
| --- | ---------------------------------------------------------------------------------------------------------- | ------ | ------- | ------- | ---- |
| U1  | `PermissionWireStatus` exposes exactly the six stable wire strings the channel protocol exchanges           | FR-001 | example | PENDING | `test/method_channel_port_test.dart` |
| U2  | `ZuraffaPermissionsPlatform.instance` defaults to `DefaultZuraffaPermissionsPlatform` before registration   | FR-002 | example | PENDING | `test/method_channel_port_test.dart` |
| U3  | assigning `instance` registers a custom implementation; subsequent reads observe it (token-verified seam)   | FR-002 | example | PENDING | `test/method_channel_port_test.dart` |
| U4  | the default fallback's `checkPermissions` reports every requested scope as `undetermined`                    | FR-003 | example | PENDING | `test/method_channel_port_test.dart` |
| U5  | the default fallback's `requestPermissions` reports every requested scope as `undetermined`                  | FR-003 | example | PENDING | `test/method_channel_port_test.dart` |
| U6  | the default fallback's `openSettings` returns `false` — it cannot launch anything                            | FR-003 | example | PENDING | `test/method_channel_port_test.dart` |

### `lib/src/method_channel_zuraffa_permissions.dart` (FR-004)

| id  | behavior                                                                                                   | traces | kind    | state   | test |
| --- | ---------------------------------------------------------------------------------------------------------- | ------ | ------- | ------- | ---- |
| U7  | `checkPermissions` invokes channel `zuraffa_permissions` / method `checkPermissions` with the scope list and returns the replied statuses | FR-004 | example | PENDING | `test/method_channel_port_test.dart` |
| U8  | `requestPermissions` invokes method `requestPermissions` with the scope list and returns the replied statuses | FR-004 | example | PENDING | `test/method_channel_port_test.dart` |
| U9  | a null platform reply normalizes to an empty map — missing scopes degrade, no crash                          | FR-004 | example | PENDING | `test/method_channel_port_test.dart` |
| U10 | non-string keys and values in the reply are stringified onto `Map<String, String>`                           | FR-004 | example | PENDING | `test/method_channel_port_test.dart` |
| U11 | `openSettings` returns the channel's bool verdict; a null reply degrades to `false`                          | FR-004 | example | PENDING | `test/method_channel_port_test.dart` |

### `lib/src/method_channel_permission_adapter.dart` (FR-005, FR-006, FR-007)

| id  | behavior                                                                                                   | traces | kind    | state   | test |
| --- | ---------------------------------------------------------------------------------------------------------- | ------ | ------- | ------- | ---- |
| U12 | `check` maps every known wire status onto the typed enum (granted/denied/permanentlyDenied/restricted/limited) | FR-005 | example | PENDING | `test/method_channel_port_test.dart` |
| U13 | `check` degrades unknown and missing wire values to `undetermined` (forward-compatible)                      | FR-005 | example | PENDING | `test/method_channel_port_test.dart` |
| U14 | `request` returns a `PermissionRequestResult` carrying the scope, the mapped status, and a real requestedAt timestamp | FR-006 | example | PENDING | `test/method_channel_port_test.dart` |
| U15 | `openSettings` delegates to the platform and returns its verdict                                             | FR-006 | example | PENDING | `test/method_channel_port_test.dart` |
| U16 | a constructor-supplied platform overrides the registered instance (the injection seam)                       | FR-007 | example | PENDING | `test/method_channel_port_test.dart` |
| U17 | without an override the adapter routes through the registered `ZuraffaPermissionsPlatform.instance`          | FR-007 | example | PENDING | `test/method_channel_port_test.dart` |
