# Changelog

## 1.0.0

- First published release; ios implementation of zuraffa_permissions.
- Depends on the published `zuraffa_permissions` and `zuraffa_permissions_platform_interface` (^1.0.0).

## 0.1.0

- Initial release: the endorsed iOS implementation of
  `zuraffa_permissions`.
- AVFoundation, Photos, CoreLocation, and UNUserNotificationCenter-backed
  permission requests across the eleven built-in scopes; limited/restricted
  states surfaced explicitly, permanently-denied scopes route to
  openSettings instead of re-prompting.
- Real-device verified (iPhone simulator + physical iPhone 12 Pro Max,
  zfa TDD integration cycles).
