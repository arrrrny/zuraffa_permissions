## 0.1.0

- Initial release: the endorsed macOS implementation of
  `zuraffa_permissions`.
- AVFoundation, Photos, CoreLocation, and UNUserNotificationCenter-backed
  permission requests across the eleven built-in scopes; limited/restricted
  states surfaced explicitly, permanently-denied scopes route to
  openSettings instead of re-prompting.
- Real-device verified (macOS 15.7.9, zfa TDD integration cycles).
