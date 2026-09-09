# zuraffa_permissions_macos

The endorsed macOS implementation of [`zuraffa_permissions`](https://pub.dev/packages/zuraffa_permissions),
backed by AVFoundation, Photos, CoreLocation, and
UNUserNotificationCenter.

## Usage

This package is [endorsed](https://docs.flutter.dev/packages-and-plugins/developing-packages#endorsed-federated-plugin)
and automatically included when you depend on `zuraffa_permissions` on
macOS. You should not need to depend on it directly.

Note: scope prompts require the matching usage descriptions in your
app's `Info.plist` (e.g. `NSCameraUsageDescription`), and Entitlements
for protected scopes.

See the main [zuraffa_permissions](https://pub.dev/packages/zuraffa_permissions)
package for full documentation.
