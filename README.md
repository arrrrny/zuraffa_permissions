# zuraffa_permissions

Typed permission requests for the Zuraffa ecosystem — the foundation layer every capability package (notifications, file_picker, auth, …) builds on.

## Usage

```dart
final permissions = PermissionService();

final status = await permissions.request(PermissionScopeNames.camera);
if (status == PermissionStatus.permanentlyDenied) {
  await permissions.openSettings();
}
```

## Design

- **PermissionPort** — the technology-agnostic contract (`check`/`request`/`openSettings`); platform adapters (zuraffa_permissions_android/ios/…) implement it as federated siblings.
- **10 built-in scopes** — camera, photos, notifications, locationWhenInUse/Always, microphone, storage, biometrics, contacts, calendar — zero-config; custom scopes register through `PermissionScopeRegistry`.
- **PermissionStatus** — granted / denied / permanentlyDenied / undetermined / restricted / limited. Requesting a permanently-denied scope never re-prompts; the caller routes to settings.
- **InMemoryPermissionAdapter** — pure-Dart default so permission logic tests without a platform.
- Entities generated via the zfa CLI (Zorphy); `registerPermissionDependencies` wires port + registry + service onto GetIt.

## Federated platform packages

The repository ships the real platform implementations as federated sub-packages (the zikzak_inappwebview pattern):

```text
zuraffa_permissions/
├── zuraffa_permissions_platform_interface/   # MethodChannel protocol + PermissionPort bridge
├── zuraffa_permissions_android/              # Kotlin — ActivityCompat, rationale-based permanent-denial detection
├── zuraffa_permissions_ios/                 # Swift — AVFoundation, Photos (.limited), UNUserNotificationCenter, CoreLocation, Contacts, EventKit, LocalAuthentication
└── zuraffa_permissions_macos/               # Swift — same frameworks via AppKit; NSWorkspace settings
```

### Wiring the native stack

The pure-Dart `PermissionPort` contract is unchanged. Apps register the real platform stack through the shared DI seam:

```dart
import 'package:zuraffa_permissions_platform_interface/zuraffa_permissions_platform_interface.dart';

registerPermissionDependencies(
  getIt,
  port: MethodChannelPermissionAdapter(),  // routes to the native plugin
);
```

Wire statuses travel the channel as stable strings (`granted`/`denied`/`permanentlyDenied`/`undetermined`/`restricted`/`limited`); the adapter maps them onto the typed `PermissionStatus` enum with unknown values degrading to `undetermined` (forward-compatible).

Platform notes:
- **Android**: the permanently-denied detection uses the `shouldShowRequestPermissionRationale` heuristic (rationale=false after a prior request ⇒ settings-only). Storage scopes resolve to granted on Android 11+ scoped storage; notifications need no runtime permission before API 33.
- **iOS/macOS**: photos report the `.limited` state as `limited`; location uses bounded-poll resolution for `requestWhenInUseAuthorization` (no completion API); `locationAlways` distinguishes always from when-in-use as `limited`.
