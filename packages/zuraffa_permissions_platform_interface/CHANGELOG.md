# Changelog

## 1.0.0

- First published release; MethodChannel protocol + PermissionPort bridge.
- Depends on the published `zuraffa_permissions` (^1.0.0).

## 0.1.0

- Initial release: the platform interface contract for
  `zuraffa_permissions`.
- `PermissionPlatformInterface` (`plugin_platform_interface` token) with
  the factory default and `MethodChannelZuraffaPermissions` driver.
- `MethodChannelPermissionAdapter`: the `PermissionPort` implementation
  bridging the typed Dart contract onto the native MethodChannel
  protocol (request/check/openSettings per scope).
- Endorsed platform implementations
  (`zuraffa_permissions_android`/`_ios`/`_macos`) conform to this
  contract; the suite pins the channel protocol.
- Built with the zfa TDD discipline: the method-channel bridge is fully
  TDD-covered (17/17 behaviors PROVEN, 17/17 mutants killed).
