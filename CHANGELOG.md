## 0.1.0

- Initial release: typed permission requests for the Zuraffa ecosystem.
- `PermissionStatus` with exactly six states; eleven zero-config built-in
  scopes (camera, microphone, photos, location family, notifications,
  contacts, tracking, and more) plus custom scope registration with a
  duplicate guard.
- Idempotent `request()` semantics: already-decided scopes return their
  status unchanged, and permanently denied never re-prompts.
- `PermissionService` facade over the `PermissionPort` seam, with typed
  fail-fast errors for unknown scopes.
- `registerPermissionDependencies` GetIt composition root: port, service,
  and permission-scope use cases wired as lazy singletons; accepts an
  injected custom adapter or factory-supplied port.
- Pure-Dart `InMemoryPermissionAdapter` for tests and previews.
- Built with the zfa TDD discipline: 26 behaviors PROVEN, mechanical
  mutation sweep 25/25 killed (quality A), real-device verified on macOS,
  Android, and iOS.
- Platform implementations ship in federated packages
  (`zuraffa_permissions_android`, `_ios`, `_macos`) over
  `zuraffa_permissions_platform_interface`.
