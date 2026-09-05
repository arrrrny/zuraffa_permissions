# Feature Specification: 007 — example app outcome matrix

**Feature Branch**: `007-example-app-outcome-matrix`
**Created**: 2026-09-05
**Status**: Approved (GitHub issue #7 — "create an example app that demonstrate all possible outcome matrix")
**Source issue**: arrrrny/zuraffa_permissions#7

## Summary

A rewrite of `example/` as the outcome-matrix demonstrator for `zuraffa_permissions`.
The app exercises the full permission flow (check → request → openSettings when
permanentlyDenied) across every built-in scope and every `PermissionStatus`, and
visualises the scope × status outcome matrix. A simulator tab drives the pure-Dart
`InMemoryPermissionAdapter` (the package's own test seam) so **every** scope × status
combination — including the ones a real OS would never hand you on demand — can be
forced, requested, and observed; a live tab wires the same UI onto the GetIt-registered
`PermissionService`, so the federated platform adapters (android/ios/macos method
channel, pure-Dart fallback elsewhere) exercise the real OS flow on a device.

## Requirements

- **FR-001 (scope list)**: The example app MUST list all built-in permission scopes
  (the ten named in the issue — camera, photos, notifications, locationWhenInUse,
  locationAlways, microphone, storage, biometrics, contacts, calendar — plus the
  eleventh built-in `tracking`, i.e. `BuiltInPermissionScopes.all`).
- **FR-002 (status surface)**: The app MUST show each scope's current status and MUST
  present the six `PermissionStatus` values (granted, denied, permanentlyDenied,
  undetermined, restricted, limited) as the columns of the outcome matrix.
- **FR-003 (matrix forcing)**: Every scope × status cell MUST be exercisable: tapping
  a cell puts that scope into that status through the in-memory adapter seam, so all
  66 (11 × 6) combinations are demonstrable, and the matrix visually marks the
  current combination.
- **FR-004 (request flow)**: The app MUST allow requesting each scope through the real
  `PermissionService.request` port: undetermined resolves the prompt outcome and
  records it; already-decided statuses (granted/denied/restricted/limited) return
  unchanged (idempotent request).
- **FR-005 (permanently denied routing)**: When a scope is `permanentlyDenied`, the
  app MUST demonstrate the FR-005 flow of the package: `request` returns the status
  without re-prompting, the UI offers **Open Settings**, and `openSettings()`
  launches with its result reported.
- **FR-006 (transition visibility)**: The app MUST display the outcome matrix's
  status transitions: a chronological flow log records every check / forced status /
  request / openSettings event with its from → to statuses.
- **FR-007 (federated adapters)**: The app MUST run against the federated platform
  adapters: the live tab resolves the `PermissionService` registered by
  `registerPermissionDependencies` (method-channel adapters where the platform
  packages register; the pure-Dart in-memory fallback elsewhere), and the example
  depends on the federated siblings (platform_interface, android, ios, macos).
- **FR-008 (platforms)**: The example MUST target the supported platforms — existing
  android/ios/macos scaffolding plus web/windows/linux scaffolding — and compile
  wherever a toolchain is available.

## Acceptance criteria (from issue #7)

- **AC-001**: Example app compiles and runs on all supported platforms.
- **AC-002**: All 10 scopes (the issue's set; the code ships 11 built-ins) are
  exercisable in the app.
- **AC-003**: Outcome matrix visually displays status transitions.
- **AC-004**: PermanentlyDenied path routes to settings correctly.

## Out of scope

- New behavior in the `zuraffa_permissions` packages themselves (example-only change;
  the package suite must stay green and untouched).
- New platform adapter packages for web/windows/linux (no such federated siblings
  exist; the pure-Dart fallback is the documented behavior on those platforms).
- Device/OS-specific integration-test passes in this environment (no emulators); the
  existing `example/integration_test` device suite remains the on-device evidence.
