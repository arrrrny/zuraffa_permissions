# example

The `zuraffa_permissions` outcome-matrix demonstrator: a Flutter host app
that exercises every built-in permission scope through the package's public
`PermissionService` API.

- **Matrix tab** — an 11 × 6 scope × status simulator grid backed by the
  package's pure-Dart `InMemoryPermissionAdapter`; tap any cell to place a
  scope in that status, then request it and watch the flow log record the
  transition (check → request → openSettings when permanently denied).
- **Live tab** — the same API against the GetIt-registered stack, i.e. the
  real method-channel platform adapters on Android, iOS, and macOS.

Run it with `flutter run` from this directory.
