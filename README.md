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
