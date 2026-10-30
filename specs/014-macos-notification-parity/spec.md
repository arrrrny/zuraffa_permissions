---
feature: 014-macos-notification-parity
issue: 14
status: implemented
---

# Spec: macOS notification scope + zik_zak adoption parity (zik_zak spec 1206)

## Summary

Verify and complete the notification scope on the macOS adapter
(UNUserNotificationCenter), land `openSettings()` on the system
Notifications pane, pin the unsupported-scope silent-deny rule, and
record the status-taxonomy review that lets zik_zak retire its bespoke
`com.zikzak.app/permissions` channel with zero behavior change
(zik_zak spec 1206, FR-1/FR-3, US1–US2, SC-4).

## Context

zik_zak re-adopts this package as its permission layer (three scopes:
camera, notification, location across iOS/Android/macOS). Its macOS
surface today runs a bespoke method channel because this package's
notification coverage was unverified. The app's current behavior —
`lib/src/data/providers/permission/macos_permission_provider.dart` and
its native `MacOSPermissionPlugin.swift` — is the parity contract.

## Requirements

- **FR-1 (notification scope, macOS)**: `check` reports the current
  UNUserNotificationCenter authorization status — `.denied` → `denied`
  (never `undetermined`), `.notDetermined` → `undetermined`,
  `.authorized`/`.provisional`/`.ephemeral` → `granted`. `request`
  prompts once via `requestAuthorization` and returns the outcome; an
  already-decided scope resolves immediately without a dialog (FR-005).
- **FR-2 (openSettings parity)**: `openSettings()` on macOS deep-links
  `x-apple.systempreferences:com.apple.Notifications-Settings` — the
  exact pane the app routes to today — and returns whether the launch
  succeeded.
- **FR-3 (unsupported-scope silent deny)**: on macOS, camera and
  location are unsupported scopes: `check` and `request` report
  `denied` without prompting; unknown scopes follow the same rule
  (denied, never `undetermined`, never a prompt). The app relies on
  macOS never raising a camera/location dialog.
- **FR-4 (taxonomy parity, review)**: every status the app maps on all
  three platforms is expressible through the port's
  `PermissionStatus` + `PermissionRequestResult`; the no-reprompt
  contract after `permanentlyDenied` (FR-005) is kept.

## Taxonomy review (recorded)

Source statuses by platform (from the app's providers) and their
expression through the port:

| Platform | Source status (app maps from) | Port expression |
| --- | --- | --- |
| iOS/Android (`permission_handler`) | granted | `PermissionStatus.granted` |
| iOS/Android | denied | `PermissionStatus.denied` |
| iOS/Android | restricted | `PermissionStatus.restricted` |
| iOS/Android | limited | `PermissionStatus.limited` |
| iOS/Android | permanentlyDenied | `PermissionStatus.permanentlyDenied` |
| iOS/Android | provisional | folded to `granted` at the app's own boundary; the port reports it as `granted` (platform-reported grant) |
| macOS (bespoke channel) | authorized/provisional/ephemeral → "granted" | `granted` |
| macOS | notDetermined → "denied" (display) | `undetermined` (faithful; the app folds it for display if it wants the old label) |
| macOS | denied → "denied" | `denied` |
| macOS | non-notification scopes → hard-deny | `denied` (FR-3, no prompt) |
| macOS | unknown native status → "denied" | `denied` (FR-3 default arm) |

Every app-mappable status is expressible through the port's six-value
vocabulary (`granted`, `denied`, `permanentlyDenied`, `undetermined`,
`restricted`, `limited`), which travels verbatim as the
`PermissionWireStatus` strings on the MethodChannel on all three
platforms, and `PermissionRequestResult` (scope, status, requestedAt)
carries each of them. `request` on `permanentlyDenied` returns without
prompting (FR-005) — the contract the app's settings-routing flow is
built on. Recorded as a test:
`packages/zuraffa_permissions/test/taxonomy_parity_test.dart`.

## Acceptance criteria (SC-4) mapping

- macOS notification scope supported: check/request/openSettings(→
  Notifications pane), tested —
  `packages/zuraffa_permissions_macos/test/macos_notification_parity_test.dart`.
- Unsupported-scope-denies-silently pinned by a test (macOS
  camera/location) — same suite, "unsupported scopes deny silently".
- Taxonomy review recorded — this document +
  `taxonomy_parity_test.dart`.
- zik_zak retires `com.zikzak.app/permissions` with zero behavior
  change — the notification flow (request-on-toggle, dialog iff not
  decided, settings routing to the Notifications pane) and the
  hard-deny surface match the app's channel behavior exactly; the only
  visible refinement is `check` reporting `undetermined` for a
  never-decided notification scope (faithful status per FR-1, which the
  app folds at its boundary).

## Assumptions

- zik_zak spec 1206 is not committed yet ("pending commit"); the issue
  body plus the app's provider/plugin sources (read from
  `arrrrny/zik_zak@master`) were used as the contract. US2's acceptance
  scenarios could not be read directly.
- No `speckit-specify` extension is installed in this checkout (only
  bug/chore/gh-triage/git/gym/spec-stats/tdd); this spec was written
  directly from the issue instead of via the specify workflow.
- "Unsupported scopes" on macOS follows the app's product decision
  (zik_zak spec 011: camera and location "are not applicable to the
  macOS desktop experience"): camera and location deny silently;
  microphone/photos/contacts/calendar/biometrics keep their existing
  macOS support.
