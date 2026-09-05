# Feature Specification: method-channel-port — the federated bridge contract

**Feature Branch**: `001-method-channel-port`
**Created**: 2026-09-02
**Status**: Approved (brownfield: the stack ships untested with `dcf1661`; this
feature brings it fully under the TDD discipline)

## Summary

The `zuraffa_permissions_platform_interface` package is the bridge half of the
federated permission stack: the stable wire vocabulary (`PermissionWireStatus`),
the platform contract every federated plugin registers onto
(`ZuraffaPermissionsPlatform` + its safe `DefaultZuraffaPermissionsPlatform`
fallback), the MethodChannel client (`MethodChannelZuraffaPermissions`), and the
pure-Dart `PermissionPort` bridge (`MethodChannelPermissionAdapter`) apps wire
through `registerPermissionDependencies`. The stack currently ships with zero
tests (the core package's 22-test suite does not reach it). This feature writes
the complete behavioral suite — red-first, per the repo's TDD workflow — so the
bridge contract is pinned before any federated plugin evolves against it.

## Requirements

- **FR-001**: `PermissionWireStatus` MUST expose exactly the six stable wire
  strings (`granted`, `denied`, `permanentlyDenied`, `undetermined`,
  `restricted`, `limited`) that travel the channel.
- **FR-002**: `ZuraffaPermissionsPlatform.instance` MUST default to
  `DefaultZuraffaPermissionsPlatform` before any registration, and platform
  packages MUST register native implementations by assigning `instance`
  (token-verified by `PlatformInterface.verifyToken`).
- **FR-003**: `DefaultZuraffaPermissionsPlatform` MUST be a safe fallback:
  `checkPermissions`/`requestPermissions` report every requested scope as
  `undetermined`, and `openSettings` returns `false` (cannot launch) — so the
  interface is safe to depend on before a platform package loads.
- **FR-004**: `MethodChannelZuraffaPermissions` MUST speak the channel protocol:
  invoke `checkPermissions`/`requestPermissions` on the shared
  `zuraffa_permissions` channel with the scope list, normalize the
  `Map<Object?, Object?>` reply onto `Map<String, String>` (stringifying keys
  and values), treat a null reply as an empty map, and return `openSettings`'s
  bool with null degrading to `false`.
- **FR-005**: `MethodChannelPermissionAdapter.check` MUST map wire statuses onto
  the typed `PermissionStatus` enum, and MUST degrade unknown or missing wire
  values to `undetermined` (forward-compatible: a newer native SDK introducing a
  status never crashes older apps).
- **FR-006**: `MethodChannelPermissionAdapter.request` MUST return a
  `PermissionRequestResult` carrying the requested scope, the mapped status, and
  a `requestedAt` epoch-milliseconds timestamp; `openSettings` MUST delegate to
  the platform and return its verdict.
- **FR-007**: `MethodChannelPermissionAdapter` MUST route through the registered
  `ZuraffaPermissionsPlatform.instance` by default, and MUST honor a
  constructor-supplied platform override (the injection seam tests use).

## Out of scope (v1)

- The native halves (Kotlin/Swift) of the federated plugins — exercised by the
  example app's integration tests on real devices, not by this suite.
- Batching multiple scopes in one `check`/`request` call (the port contract is
  single-scope per call in v1).
- Platform-channel codec hardening (custom `MessageCodec`); the standard codec's
  `Map<Object?, Object?>` reply shape is the contract.
