# Changelog

## 1.0.0

- First published release; android implementation of zuraffa_permissions.
- Depends on the published `zuraffa_permissions` and `zuraffa_permissions_platform_interface` (^1.0.0).

## 0.1.0

- Initial release: the endorsed Android implementation of
  `zuraffa_permissions`.
- ActivityCompat-based permission requests across the eleven built-in
  scopes; permanently-denied scopes route to openSettings instead of
  re-prompting.
- Real-device verified (Android emulator + device matrix, zfa TDD
  integration cycles).
