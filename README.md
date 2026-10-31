# zuraffa_permissions — monorepo

Typed permission requests (check / request / openSettings) for the
Zuraffa ecosystem, behind a pure-Dart `PermissionPort` with federated
platform adapters. Built on the [Zuraffa](https://pub.dev/packages/zuraffa)
framework.

## Packages

| Package | Description |
| --- | --- |
| [`packages/zuraffa_permissions`](packages/zuraffa_permissions/) | App-facing package: `PermissionPort`, `PermissionService`, RBAC entities + use cases |
| [`packages/zuraffa_permissions_platform_interface`](packages/zuraffa_permissions_platform_interface/) | MethodChannel protocol + `PermissionPort` bridge |
| [`packages/zuraffa_permissions_android`](packages/zuraffa_permissions_android/) | Android implementation (ActivityCompat) |
| [`packages/zuraffa_permissions_ios`](packages/zuraffa_permissions_ios/) | iOS implementation (AVFoundation, Photos, UNUserNotificationCenter, CoreLocation) |
| [`packages/zuraffa_permissions_macos`](packages/zuraffa_permissions_macos/) | macOS implementation (AppKit, NSWorkspace, UNUserNotificationCenter) |

Publish from each package directory (`packages/<name>`); the federated
siblings depend on each other via hosted dependencies.

## Install

```yaml
dependencies:
  zuraffa_permissions: ^7.3.2
```

That is the base dependency an app adds. There is no plugin endorsement in
this pure-Dart package: add the platform adapter(s) you need explicitly
(the platform interface comes along transitively):

```yaml
dependencies:
  zuraffa_permissions: ^7.3.2
  zuraffa_permissions_android: ^7.3.2 # plus _ios / _macos as needed
```

## Platform support

| Platform | Adapter | Backing APIs |
| --- | --- | --- |
| Android | `zuraffa_permissions_android` | `ActivityCompat` runtime prompts |
| iOS | `zuraffa_permissions_ios` | AVFoundation, Photos, UIKit, LocalAuthentication, Contacts, EventKit |
| macOS | `zuraffa_permissions_macos` | AppKit, AVFoundation (microphone), Photos, UserNotifications, LocalAuthentication, Contacts, EventKit |
| Web / Windows / Linux | pure-Dart fallback in the app package | `InMemoryPermissionAdapter` default — no OS prompts; statuses stay `undetermined` (tests and previews) |

The eleven built-in scopes (camera, photos, notifications,
locationWhenInUse, locationAlways, microphone, storage, biometrics,
contacts, calendar, tracking) are zero-config; custom scopes register
through `PermissionScopeRegistry`.

macOS surface notes (verified in #14): the notification scope runs on
UNUserNotificationCenter — `check` reports the current authorization
status (a decided denial is `denied`, a provisional/ephemeral grant is
`granted`), `request` prompts once and returns the outcome, and
`openSettings()` deep-links the system Notifications pane
(`x-apple.systempreferences:com.apple.Notifications-Settings`). Camera
and location are unsupported on the macOS desktop surface: `check` and
`request` report `denied` WITHOUT ever prompting, as does any unknown
scope.

## Fleet status & adoption note

**Status: healthy but unconsumed.** Every member analyzes clean, its tests
run in CI, and publish dry-runs pass at the current fleet version — but no
app consumes the API today: the package was removed from zik_zak's pubspec
on 2026-10-11 (it had been declared but never imported).

Re-adoption into zik_zak is justified when:

- an app needs typed permission requests (or the RBAC layer) again and
  actually imports the API;
- the re-adoption constrains the family at the then-current fleet version
  (`^<fleet version>` — never an older constraint);
- CI is green for every member at that version.

## Releases (mono version policy)

All five members share ONE version. A release ships only through the fleet
mono bump (`../zuraffa/scripts/update_fleet.sh <version>`) — never a
single-member bump, never publishing out of family. In the same change the
install guide above moves to the new version and the family `zuraffa`
constraint moves to `^<version>`. `scripts/check_fleet_versions.sh`
enforces all of it in CI; the publish pipeline itself lives in
[`PUBLISH.md`](PUBLISH.md).

## CI

[`.github/workflows/test.yml`](.github/workflows/test.yml) runs, for every
federated member at the current fleet version: resolve against published
packages, analyze, tests (concurrency capped at 2) and a
`pub publish --dry-run` — plus the fleet parity check and the example
app's headless tests (`packages/zuraffa_permissions/example`, the
outcome-matrix demonstrator from
[`specs/007-example-app-outcome-matrix`](specs/007-example-app-outcome-matrix/)).
The example's `integration_test/` variants need a device or simulator and
are not part of CI. The top-level `example/` directory holds only platform
shells and no runnable app.

See [`specs/`](specs/) for the spec-driven development records.
