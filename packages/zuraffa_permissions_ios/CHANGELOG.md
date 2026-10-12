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
