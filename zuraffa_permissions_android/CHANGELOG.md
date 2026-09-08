## 0.1.0

- Initial release: the endorsed Android implementation of
  `zuraffa_permissions`.
- ActivityCompat-based permission requests across the eleven built-in
  scopes; permanently-denied scopes route to openSettings instead of
  re-prompting.
- Real-device verified (Android emulator + device matrix, zfa TDD
  integration cycles).
