## [7.2.0] - 2026-10-28

- Mono-version fleet alignment: the whole zuraffa family now ships at the same version as the core.
- `zuraffa` dependency constraint unified to ^7.2.0 across the fleet.
- zuraffa_storage now wraps the maintained `zuraffa_minio` fork instead of the abandoned `minio` package (xml 7 compatible).
- Fleet-wide `dependency_overrides: xml: 7.1.0` policy; README install guides refreshed to the release version.

# Changelog

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

## 1.0.0

First published release of the federated `zuraffa_permissions` plugin: the
app-facing package plus its platform interface and the Android, iOS and macOS
adapters.
