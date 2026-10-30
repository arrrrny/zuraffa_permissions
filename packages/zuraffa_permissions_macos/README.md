# zuraffa_permissions_macos

The endorsed macOS implementation of [`zuraffa_permissions`](https://pub.dev/packages/zuraffa_permissions),
backed by AVFoundation, Photos, UNUserNotificationCenter,
LocalAuthentication, Contacts, and EventKit.

## macOS surface

- **Notifications** run on UNUserNotificationCenter (macOS 10.14+):
  `check` reports the current authorization status — a decided denial is
  `denied`, a never-decided scope is `undetermined`, and every grant
  (including provisional and ephemeral) is `granted`; `request` prompts
  once and returns the outcome; an already-decided scope never
  re-prompts (FR-005 — only Settings can change the answer).
- **`openSettings()`** deep-links the system Notifications pane
  (`x-apple.systempreferences:com.apple.Notifications-Settings`).
- **Camera and location are unsupported** on the macOS desktop surface:
  `check` and `request` report `denied` WITHOUT ever prompting, and the
  same holds for any unknown scope. No OS dialog may appear for them.

## Usage

This package is [endorsed](https://docs.flutter.dev/packages-and-plugins/developing-packages#endorsed-federated-plugin)
and automatically included when you depend on `zuraffa_permissions` on
macOS. You should not need to depend on it directly.

Note: scope prompts require the matching usage descriptions in your
app's `Info.plist` (e.g. `NSCameraUsageDescription`), and Entitlements
for protected scopes.

See the main [zuraffa_permissions](https://pub.dev/packages/zuraffa_permissions)
package for full documentation.
