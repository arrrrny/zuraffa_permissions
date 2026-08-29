# Feature Specification: zuraffa_permissions — typed permission port

**Feature Branch**: `001-permission-port`
**Created**: 2026-08-23
**Status**: Approved (analysis pick: Tier 1 #1, the ecosystem's foundational package)

## Summary

A pure-Dart `zuraffa_permissions` package: the permission layer of the Zuraffa ecosystem. A `PermissionPort` (check/request/openSettings) over typed `PermissionScope` entities with a `PermissionStatus` enum, a built-in scope registry (camera, photos, notifications, locationWhenInUse, locationAlways, microphone, storage, biometrics, contacts, calendar, tracking), an in-memory default adapter (pure-Dart testable), and `registerPermissionDependencies` DI wiring. Platform adapters (Android/iOS/…) arrive later as federated siblings, mirroring zikzak_inappwebview's structure — this package is the contract they implement.

## Requirements

- **FR-001**: `PermissionPort` MUST expose `check(scope)` returning `PermissionStatus`, `request(scope)` returning `PermissionRequestResult` (scope + status + requestedAt), and `openSettings()` returning `bool`.
- **FR-002**: `PermissionStatus` MUST cover: `granted`, `denied`, `permanentlyDenied`, `undetermined`, `restricted`, `limited`.
- **FR-003**: Eleven built-in scopes MUST ship zero-config (camera, photos, notifications, locationWhenInUse, locationAlways, microphone, storage, biometrics, contacts, calendar, tracking).
- **FR-004**: Custom scopes MUST register through `PermissionScopeRegistry` (duplicate guard).
- **FR-005**: Requesting a permanently-denied scope MUST NOT auto-prompt; it reports the status so the caller can decide to route to settings.
- **FR-006**: The default adapter MUST be pure Dart (in-memory state machine) so the whole package tests without a platform.
- **FR-007**: DI registration MUST wire port + adapter + usecases onto GetIt.
- **FR-008**: All entities generated via the zfa CLI (Zorphy).

## Out of scope (v1)

- Platform adapters (federated siblings: zuraffa_permissions_android/ios/…).
- Rationale UI display (the scope carries the string; the app decides).
- Batch requests (v2; sequential request() covers v1 flows).
