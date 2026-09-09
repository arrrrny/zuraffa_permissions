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
| [`packages/zuraffa_permissions_macos`](packages/zuraffa_permissions_macos/) | macOS implementation (AppKit, NSWorkspace) |

Publish from each package directory (`packages/<name>`); the federated
siblings depend on each other via hosted dependencies.

See [`specs/`](specs/) for the spec-driven development records.
