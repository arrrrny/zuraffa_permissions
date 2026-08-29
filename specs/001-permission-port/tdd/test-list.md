---
feature: 001-permission-port # spec-kit feature directory name
loop: inside-out # pure Dart library, no user-visible surface of its own
profile: .specify/memory/tdd-profile.md # stack profile the commands must read
spec_criteria: 8 # spec.md has no AC-ids; the 8 FRs (FR-001..FR-008) act as the criteria
planned_at: 40264b9 # short SHA the list was derived from
updated_at: 2b966f2 # short SHA of the last change (clarifications 2.1/2.2 resolved)
suite_baseline: green # 18 passed, 0 failed at planning time
---

# Test List: 001-permission-port

> Derived from `spec.md` on commit `40264b9`, refreshed on `2b966f2` after the two
> open clarifications (formerly in "edge cases still to place") were resolved by the
> user. The feature is **brownfield**: the package is already implemented and its
> existing suite (`test/permission_test.dart`, 18 tests) passes. This list records
> every behavior the spec demands, marks what the existing tests already cover as
> `DONE`, and lists the two **spec-change behaviors** introduced by the resolution
> (`U23`, `U24`) as `PENDING`. `plan.md` is absent, so components below were placed
> onto the real source files rather than a plan. `loop: inside-out` because this is a
> library with no user-visible surface (no HTTP/CLI/screen); there is no outer
> acceptance loop to open.

## Resolved clarifications (was "edge cases still to place")

- **2.1 / FR-001 return shape** — DECIDED: `check` returns `PermissionStatus`,
  `request` returns `PermissionRequestResult` (scope + status + requestedAt),
  `openSettings` returns `bool`. This is the new contract; captured as `U23`. The
  existing request-path tests (U3, U4, U5, U6, U8, U9, U17) currently assert the raw
  `PermissionStatus` return and are adapted to the new return type inside `U23`'s
  cycle. Their ids/states are preserved; the assertions are updated, not weakened.
- **2.2 / built-in set** — DECIDED: `tracking` is the 11th built-in scope. FR-003
  and the Summary now name eleven scopes. Captured as `U24`; the count assertions in
  `U11`/`U13` move from ten to eleven.

## Outer loop: acceptance behaviors

None. This is an `inside-out` library — its "entry point" is the public API
(`PermissionPort`, `PermissionService`, `registerPermissionDependencies`), which
the unit behaviors below exercise directly. The spec carries no acceptance
criteria with user-visible results, only functional requirements (FR-001..FR-008),
so each FR is traced by the unit behaviors instead of an `A` row.

## Inner loop: unit behaviors

Grouped by the component from the implementation that owns them.

### `lib/src/domain/entities/enums/permission_status.dart` (FR-002)

| id  | behavior                                                                          | traces | kind    | state    | test |
| --- | --------------------------------------------------------------------------------- | ------ | ------- | ------- | ---- |
| U1  | `PermissionStatus` enumerates exactly the six states: granted, denied, permanentlyDenied, undetermined, restricted, limited | FR-002 | example | DONE    | `test/permission_test.dart::permission status enum (FR-002) enumerates exactly the six required states` |

### `lib/src/domain/permission/permission_port.dart` + `lib/src/data/permission/in_memory_permission_adapter.dart` (FR-001, FR-005, FR-006)

| id  | behavior                                                                                        | traces     | kind    | state  | test                                                                                  |
| --- | ----------------------------------------------------------------------------------------------- | ---------- | ------- | ------ | ------------------------------------------------------------------------------------- |
| U2  | A fresh adapter reports every scope as `undetermined` via `check`                               | FR-006     | example | DONE   | `test/permission_test.dart::every scope starts undetermined`                           |
| U3  | `request` on an `undetermined` scope resolves the prepared prompt outcome and records it (sticky) | FR-005, FR-006 | example | DONE   | `test/permission_test.dart::request on an undetermined scope resolves the prepared prompt outcome and records it` |
| U4  | `request` defaults to `granted` when no outcome is prepared                                     | FR-006     | example | DONE   | `test/permission_test.dart::request defaults to granted when no outcome is prepared`  |
| U5  | Requesting a `permanentlyDenied` scope returns the status without re-prompting                  | FR-005     | example | DONE   | `test/permission_test.dart::permanently denied never re-prompts (FR-005)`              |
| U6  | Already-decided scopes return their status unchanged on `request` (idempotent)                  | FR-005     | example | DONE   | `test/permission_test.dart::already-decided scopes return their status unchanged (idempotent requests)` |
| U7  | `openSettings` reports whether settings could be launched                                        | FR-001     | example | DONE   | `test/permission_test.dart::openSettings reports launchability`                        |
| U8  | `request` on a scope currently `limited` returns it unchanged (no re-prompt)                    | FR-002, FR-005 | example | DONE    | `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) a scope currently limited is returned unchanged and not re-prompted (FR-005)` |
| U9  | `request` on a scope currently `restricted` returns it unchanged (no re-prompt)                 | FR-002, FR-005 | example | DONE    | `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) a scope currently restricted is returned unchanged and not re-prompted (FR-005)` |
| U10 | `check` returns the explicitly set `limited` / `restricted` status                             | FR-002     | example | DONE    | `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) check() returns an explicitly set limited or restricted status (FR-002)` |
| U23 | `request` returns a `PermissionRequestResult` carrying the `scope`, the resolved `status`, and the `requestedAt` timestamp | FR-001 | example | DONE   | `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) request returns a PermissionRequestResult carrying scope, status, and requestedAt (FR-001)` |

### `lib/src/domain/entities/scopes/built_in_permission_scopes.dart` (FR-003)

| id   | behavior                                                                     | traces | kind    | state  | test                                                                                |
| ---- | ---------------------------------------------------------------------------- | ------ | ------- | ------ | ----------------------------------------------------------------------------------- |
| U11  | `BuiltInPermissionScopes.all` contains exactly the eleven built-ins (incl. `tracking`), zero-config | FR-003 | example | DONE   | `test/permission_test.dart::all ten built-ins are registered with zero configuration` |
| U12  | Each built-in carries stable id/name/description/platformGroup metadata       | FR-003 | example | DONE   | `test/permission_test.dart::all ten built-ins are registered with zero configuration` |
| U24  | `tracking` is the 11th built-in scope, registered zero-config                 | FR-003 | example | DONE   | `test/permission_test.dart::built-in scopes (FR-003) tracking is the 11th built-in scope, registered zero-config (FR-003)` |

### `lib/src/domain/repositories/permission_scope_repository.dart` + `lib/src/data/repositories/data_permission_scope_repository.dart` (FR-003, FR-004)

| id   | behavior                                                                                  | traces | kind    | state  | test                                                                                |
| ---- | ----------------------------------------------------------------------------------------- | ------ | ------- | ------ | ----------------------------------------------------------------------------------- |
| U13  | `PermissionScopeRegistry.withBuiltIns()` contains all eleven built-ins (incl. `tracking`) | FR-003 | example | DONE   | `test/permission_test.dart::all ten built-ins are registered with zero configuration` |
| U14  | Custom scopes register through the same seam                                            | FR-004 | example | DONE   | `test/permission_test.dart::custom scopes register through the same seam (FR-004)`   |
| U15  | Duplicate registration throws a typed `ZuraffaSessionException` (code `duplicate_scope`) | FR-004 | example | DONE   | `test/permission_test.dart::custom scopes register through the same seam (FR-004)`   |
| U16  | `lookup(id)` returns the registered scope                                                | FR-003 | example | DONE   | `test/permission_test.dart::all ten built-ins are registered with zero configuration` |

### `lib/src/permission_service.dart` (FR-001, FR-007)

| id   | behavior                                                                                       | traces     | kind    | state    | test                                                                                  |
| ---- | ---------------------------------------------------------------------------------------------- | ---------- | ------- | ------- | ------------------------------------------------------------------------------------- |
| U17  | `PermissionService.request`/`check` route through the port for registered scopes              | FR-001     | example | DONE    | `test/permission_test.dart::request routes through the port for registered scopes`     |
| U18  | Requesting an unknown scope throws a typed `ZuraffaSessionException` (code `unknown_scope`)    | FR-001     | example | DONE    | `test/permission_test.dart::an unknown scope is a typed, fail-fast error`             |
| U19  | `service.scopes` surfaces built-in and custom metadata                                         | FR-001, FR-004 | example | DONE    | `test/permission_test.dart::scopes surface built-in and custom metadata`               |
| U20  | `registerPermissionDependencies` wires port + registry + service onto GetIt                    | FR-007     | example | DONE    | `test/permission_test.dart::registerPermissionDependencies wires the stack onto GetIt`  |
| U21  | DI honors an injected custom adapter                                                          | FR-007     | example | DONE    | `test/permission_test.dart::DI honors an injected custom adapter`                      |
| U22  | `registerPermissionDependencies` also registers the permission-scope usecases (get/list/create) so they resolve from GetIt | FR-007 | example | DONE    | `test/permission_test.dart::PermissionService (FR-001/FR-007) registerPermissionDependencies also wires the permission-scope use cases (FR-007)` |
| U25  | `registerPermissionDependencies` resolves the port from the factory a platform package installed via `setPlatformPermissionPortFactory` (falls back to `InMemoryPermissionAdapter` when none is registered) | FR-001 | example | DONE | `test/permission_test.dart::default port selection (FR-001 wiring) registerPermissionDependencies uses the factory-supplied port` |
| U26  | An explicitly injected port still takes precedence over the factory-supplied default | FR-001 | example | DONE | `test/permission_test.dart::default port selection (FR-001 wiring) an injected port still wins over the factory` |

## Invariants and edge cases still to place

None open. The two former items (FR-001 return shape, built-in set) are resolved
above and captured as `U23` / `U24`.

## Out of scope

- Platform adapters (`zuraffa_permissions_android/ios/macos`): separate packages,
  no tests yet — out of scope for this package's loop.
- Rationale UI display: the scope carries the string; the app decides. (spec)
- Batch requests: v2. (spec)
- FR-008 (entities generated via the zfa CLI / Zorphy): a build/codegen concern,
  not a runtime behavior asserted by `package:test`. The generated `.g.dart` /
  `.zorphy.dart` files exist and compile; no unit test is meaningful here.
- Reading a real OS settings screen: requires a platform; out of scope for the
  pure-Dart adapter (covered by `openSettings` returning a launch flag).

## Verification commands

Copied verbatim from `.specify/memory/tdd-profile.md` at planning time, so this
file is readable on its own:

- Single test: `dart test -n "{name}"`
- Run one file: `dart test {file}`
- Full suite: `dart test`
- Coverage: `dart test --coverage=coverage`
