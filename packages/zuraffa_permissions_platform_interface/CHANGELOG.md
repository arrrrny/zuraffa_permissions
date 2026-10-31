## 7.3.2 - 2026-10-31

Mono-version fleet alignment to 7.3.2: outbound send port lands in zuraffa_intents (shareText/shareFiles behind ShareIntentService); the whole family ships at one version.

# Changelog

## 7.3.0 - 2026-10-28

- Mono-version fleet alignment: the whole zuraffa family ships at 7.3.0 together with the core.
- `zuraffa` dependency constraints unified to ^7.3.0; cross-family constraints move with the release.
- Fleet-wide `dependency_overrides: xml: 7.1.0`; README install guides refreshed to 7.3.0.

## 1.0.1

### Changed

- **iOS and macOS plugins migrated to Swift Package Manager (SPM)**
  ([issue #6](https://github.com/arrrrny/zuraffa_permissions/issues/6)). The
  two Apple adapters now ship a `Package.swift` and are consumed as SPM
  products instead of CocoaPods pods, and the contract tests assert the SPM
  product name. The example's iOS deployment target moves to 15.6, which the
  zuraffa SPM packages require.

### Added

- Publish pipeline adopted from the zikzak_inappwebview flow: `scripts/prepare_for_publish.sh`,
  `scripts/publish.sh`, `scripts/push_to_master.sh` and `PUBLISH.md`.

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
