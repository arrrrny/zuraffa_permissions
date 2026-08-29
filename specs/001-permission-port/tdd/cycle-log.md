# Cycle Log: 001-permission-port

Append only. Newest last. Every entry's `red` block is the evidence that the test
existed and failed before the implementation.

## Baseline

- suite: `dart test` -> 13 passed, 0 failed
- commit: `40264b9`
- recorded: cycle 0, before any change
- note: feature is brownfield; the existing suite already passes. The test list
  captures the spec's behaviors and flags the coverage gaps (U1, U8, U9, U10, U22)
  as the remaining work.

## Cycle 1: U1 — PermissionStatus enumerates exactly the six states (FR-002)

- test: `test/permission_test.dart::permission status enum (FR-002) enumerates exactly the six required states` (new)
- red: passed on first run — behavior already implemented (brownfield additive
  coverage). Validated meaning with a deliberate mutant: adding a 7th enum value
  `unknown` made the test fail with `Expected: ... has length of <6> Which: has
  length of <7>`. Mutant reverted; suite green again.
- green: no implementation change required; the enum already exposes the six
  states. Full suite `dart test` -> 14 passed, 0 failed.
- refactor: none needed.
- commit: 7d06a4f

## Cycle 2: U8 — request() on a `limited` scope returns it unchanged (FR-002/FR-005)

- test: `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) a scope currently limited is returned unchanged and not re-prompted (FR-005)` (new)
- red: passed on first run — behavior already implemented (brownfield additive
  coverage). Validated with a deliberate mutant: removing `limited` from the
  adapter's idempotency guard (`current == PermissionStatus.limited`) let the scope
  fall through to the prompt path and return `granted`; the test failed. Mutant
  reverted; suite green again.
- green: no implementation change required. Full suite `dart test` -> 15 passed, 0 failed.
- refactor: none needed.
- commit: efae09b

## Cycle 3: U9 — request() on a `restricted` scope returns it unchanged (FR-002/FR-005)

- test: `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) a scope currently restricted is returned unchanged and not re-prompted (FR-005)` (new)
- red: passed on first run — behavior already implemented (brownfield additive
  coverage). Validated with a deliberate mutant: dropping `restricted` from the
  idempotency guard let the scope fall through to the prompt path; the test failed.
  Mutant reverted; suite green again.
- green: no implementation change required. Full suite `dart test` -> 16 passed, 0 failed.
- refactor: none needed.
- commit: 0116b30

## Cycle 4: U10 — check() returns an explicitly set limited/restricted status (FR-002)

- test: `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) check() returns an explicitly set limited or restricted status (FR-002)` (new)
- red: passed on first run — behavior already implemented (brownfield additive
  coverage). Validated with a deliberate mutant: making `check` always return
  `undetermined` (ignoring stored status) failed the test. Mutant reverted; suite
  green again.
- green: no implementation change required. Full suite `dart test` -> 17 passed, 0 failed.
- refactor: none needed.
- commit: b412ff9

## Cycle 5: U22 — registerPermissionDependencies also wires the permission-scope use cases (FR-007)

- test: `test/permission_test.dart::PermissionService (FR-001/FR-007) registerPermissionDependencies also wires the permission-scope use cases (FR-007)` (new)
- red: `dart test -n "registerPermissionDependencies also wires the permission-scope use cases"`
  -> `getIt<GetPermissionScopeListUseCase>()` threw "Object/factory not registered"
  (the use cases and their repository were never wired by `registerPermissionDependencies`).
- green: `registerPermissionDependencies` now also registers `PermissionScopeRepository`
  (-> `DataPermissionScopeRepository` over the remote data source) and calls
  `setupDependencies(getIt)` to register the three use cases and the data source.
  Full suite `dart test` -> 18 passed, 0 failed.
- refactor: none needed (the missing repository registration was a latent gap in the
  generated `setupDependencies`; fixed in the hand-written DI entry point rather
  than editing the generated file).
- commit: <see below>

## Cycle 6: U24 — tracking is the 11th built-in scope (FR-003)

- test: `test/permission_test.dart::built-in scopes (FR-003) tracking is the 11th built-in scope, registered zero-config (FR-003)` (new)
- red: `dart test -n "tracking is the 11th"`
  -> `Expected: true  Actual: <false>  tracking must ship built-in`
  (the `tracking` field existed as a stub but was not yet in `BuiltInPermissionScopes.all`,
  so `PermissionScopeRegistry.withBuiltIns()` did not contain it and `all` had length 10)
- green: added `BuiltInPermissionScopes.tracking` (App Tracking Transparency, platformGroup
  `privacy`) and appended it to `all`; updated the four built-in scope-count assertions
  in `test/permission_test.dart` (10->11, 11->12, 11->12, 10->11) that the new scope
  invalidated. Full suite `dart test` -> 19 passed, 0 failed.
- refactor: none needed.
- note: the single-test command matched nothing when given the full name with `(FR-003)`
  because `package:test` parsed the parentheses as a regex group; a plain substring
  (`tracking is the 11th`) matched. Recorded in the profile as the silent-exit caveat.
- commit: not committed (no git mutation requested); changes left in the working tree.

## Cycle 7: U23 — request returns PermissionRequestResult (FR-001)

- test: `test/permission_test.dart::in-memory adapter state machine (FR-006, FR-005) request returns a PermissionRequestResult carrying scope, status, and requestedAt (FR-001)` (new)
- red: `dart test -n "request returns a PermissionRequestResult"`
  -> `Expected: a value greater than <0>  Actual: <0>` (the adapter stub returned
  `requestedAt: 0`; the return type was already `PermissionRequestResult` so the
  test compiled, but the timestamp was the stub value — a real assertion failure)
- green: `InMemoryPermissionAdapter.request` now returns `PermissionRequestResult(
  scope: scope, status: resolved, requestedAt: DateTime.now().millisecondsSinceEpoch)`.
  `PermissionPort.request` and `PermissionService.request` signatures changed from
  `Future<PermissionStatus>` to `Future<PermissionRequestResult>`. The 8 existing
  request-path assertions (U3, U4, U5, U6, U8, U9, U17) were adapted from a raw
  `PermissionStatus` expectation to `(await ...).status`. Full suite `dart test`
  -> 20 passed, 0 failed.
- refactor: none needed; the status-resolution branch is unchanged, only wrapped.
- note: breaking contract change. `check` still returns `PermissionStatus` and
  `openSettings` still returns `bool`, per the resolved FR-001 (clarification 2.1).
- commit: not committed (no git mutation requested); changes left in the working tree.

## Cycle 8: Real-device characterization of the federated native plugin (macOS, Android, iOS)

- test: `example/integration_test/permission_test.dart` (new) — drives the **real**
  native plugin (not the in-memory Dart adapter) on a physical OS and proves the
  MethodChannel round-trips: `biometrics` must resolve to a non-`undetermined`
  status (proves the native plugin answered, not the fallback), `camera` returns a
  valid enum, `storage` resolves via `request` without popping a dialog, `openSettings`
  returns a bool.
- env: 2019 Intel Mac (darwin-x64, macOS 15.7.9); Android emulator `Pixel_10_Pro`
  (Android 17 / API 37); iOS Simulator iPhone 16e (iOS 26.3). Run one runtime at a
  time per the machine constraint (emulator and simulator never up together).
- host: a new `example/` Flutter app wires all five packages
  (`zuraffa_permissions` + `_platform_interface` + `_android` + `_ios` + `_macos`).

### macOS (desktop) — red → green

- red: `flutter test -d macos` failed to build. Distinct native issues surfaced:
  1. `pod install` → `No podspec found for zuraffa_permissions_macos`. Root cause:
     the macOS podspec file was `zuraffa_permissions.podspec` while its `s.name` is
     `zuraffa_permissions_macos`; CocoaPods requires the filename to equal `s.name`.
     Renamed `macos/zuraffa_permissions.podspec` → `zuraffa_permissions_macos.podspec`
     (and the iOS twin `ios/zuraffa_permissions.podspec` → `zuraffa_permissions_ios.podspec`).
  2. macOS Swift source `import Flutter` unresolved — macOS imports `FlutterMacOS`,
     not `Flutter`. Type names are otherwise identical, so only the import line changed.
  3. `registrar.messenger()` — on macOS `FlutterPluginRegistrar.messenger` is a
     **property**, not a method. Changed to `registrar.messenger`.
  4. `UNUserNotificationCenter` not in scope — added `import UserNotifications`
     (AppKit does not transitively expose it on macOS the way UIKit does on iOS).
  5. `EKAuthorizationStatus.limited` does not exist — that value is photos-only.
     Rewrote `calendarStatus` with an `if #available(macOS 14.0, *)` split.
- pre-cycle fix: `zuraffa_permissions_macos/pubspec.yaml` declared `platforms: ios:`
  instead of `macos:`; corrected so the macOS plugin actually registers on macOS.
- green: `flutter test -d macos` → `All tests passed!` Native plugin live, channel round-trips.

### Android (Pixel emulator) — green (with migration warning)

- green: `flutter test -d emulator-5554` → `All tests passed!`
- note (not a failure): build warns the Android plugin still applies the legacy
  Kotlin Gradle Plugin (KGP). Future Flutter versions will fail to build until the
  plugin migrates to Built-in Kotlin. Recorded as a follow-up, not a test break.

### iOS (simulator) — red → green

- red: `flutter test -d <iPhone 16e>` failed to build —
  `EKAuthorizationStatus has no member 'limited'` at
  `ios/Classes/SwiftZuraffaPermissionsPlugin.swift:325`. Same photos-vs-calendar
  mistake as macOS; fixed `calendarStatus` with an `if #available(iOS 17.0, *)` split.
- green: `flutter test -d <iPhone 16e>` → `All tests passed!`

### Known benign warnings (do not block any run)

- "plugins do not support Swift Package Manager" (macOS + iOS): the plugins ship a
  CocoaPods podspec and no `Package.swift`; works today, becomes an error in a future
  Flutter. Future work: add a `Package.swift` (SPM) for both Apple plugins.
- KGP warning on Android (above).
- "switch must be exhaustive" on the calendar `#available` split — Swift analyzer
  quirk; the switch is exhaustive via `@unknown default`.
- "Failed to foreground app; open returned 1" on macOS — test-runner only.

### Incident (contained)

- A stray `flutter create .` was run from the **repo root** instead of `example/`,
  scaffolding a spurious Flutter app at the plugin root (`lib/main.dart`, `macos/`,
  `test/widget_test.dart`, `.metadata`, `.idea/`). Removed all of them; no tracked
  source was clobbered (`lib/src`, `lib/zuraffa_permissions.dart`,
  `test/permission_test.dart` intact). The macOS `Podfile` was then supplied from
  Flutter's template and `pod install` run in `example/macos`.

### Result

- All three real runtimes GREEN. Closes the verification.md "not audited" gap for the
  four federated packages (native plugin behavior is now characterized on every target).
- recorded: 2026-08-29. Not committed (no git mutation requested).

## Cycle 9: Location scope coverage on real runtimes (locationWhenInUse)

- test: `example/integration_test/permission_test.dart` — added a non-blocking
  `await service.check('locationWhenInUse')` assertion beside `camera`: the result must
  be one of `PermissionStatus.values`. `locationWhenInUse` is a built-in scope with
  platformGroup `location`; `check` (not `request`) is used deliberately so no native
  permission dialog pops on any runtime. This proves the MethodChannel carries the
  location platform group end-to-end, which Cycle 8 left unexercised.
- red: N/A as a code failure — the native plugins already handled the `location` group
  on all three platforms (confirmed by reading `SwiftZuraffaPermissionsPlugin.swift`
  (iOS `locationStatus`, macOS `locationStatus`) and `ZuraffaPermissionsPlugin.kt`
  (`"locationWhenInUse" -> ACCESS_COARSE/FINE_LOCATION`)). This is additive coverage,
  like the brownfield U1–U4 cycles, not a new behavior.
- green: `dart` host change only — no native source edited. Re-ran the full integration
  test on all three runtimes, one at a time:
  - macOS (desktop): `flutter test -d macos` → `All tests passed!` (incl. location).
  - Android (Pixel_10_Pro, `emulator-5554`): first attempt was run from the **repo root**
    by mistake (`flutter test integration_test/…` with no `cd example`), which reported
    `cannot run without a dependency on "package:integration_test"` because the root
    package has no such dev_dependency. Fixed by running from `example/` (after a `flutter
    pub get`); `flutter test -d emulator-5554` → `All tests passed!` (incl. location).
    Emulator was shut down before the iOS leg; simulator was already down for the Android leg.
  - iOS (iPhone 16e, `38AC6290-…`): `flutter test -d <udid>` → `All tests passed!`
    (incl. location). No `NSLocationWhenInUseUsageDescription` key is needed because the
    test only calls `authorizationStatus()` (a `check`), which does not prompt; the key is
    only required for `request…Authorization`, which the test never invokes.
- note: example `iOS/Runner/Info.plist` still lacks a location usage key; harmless for a
  `check`-only test, but add `NSLocationWhenInUseUsageDescription` if a future test calls
  `request('locationWhenInUse')` (it would crash without the key).
- recorded: 2026-08-29. Not committed (no git mutation requested).

## Cycle 10: Location **request** grant flow on a physical iPhone

- test: `example/integration_test/location_request_test.dart` (new, focused) — drives the
  real native plugin on a physical iPhone and calls `request('locationWhenInUse')`, which
  pops the system "Allow location while using the app" dialog. Asserts the result is a
  `PermissionRequestResult` with `scope == 'locationWhenInUse'` and
  `status != undetermined` (the signal the grant flow actually round-tripped). Kept separate
  from `permission_test.dart` so the automated macOS/Android/simulator runs stay dialog-free.
- env: physical iPhone 12 Pro Max (iOS 18.7.1), cabled, Developer Mode ON, team
  `2D3QTPZG5J` (Automatic signing). Run one runtime at a time; no simulator/emulator up.
- pre-req (code): added `NSLocationWhenInUseUsageDescription` to `example/ios/Runner/Info.plist`
  — without it, `requestWhenInUseAuthorization` aborts the app on a real device. (Closes the
  Cycle 9 follow-up note.)
- red (run 1): `flutter test -d 00008101-…` built + launched, the dialog appeared and the
  user tapped Allow, but `request` returned `undetermined` and the assertion failed. Root
  cause: the iOS plugin's `requestLocation` polled only `attempts >= 60` (60 × 0.15s ≈ 9s);
  the human tap landed after the window closed, so the future resolved `undetermined`. A 9s
  window for a permission dialog is a genuine plugin weakness — a slow real user would get a
  wrong `undetermined`.
- green (plugin fix): widened the location-request poll window on **both** Apple plugins
  (`SwiftZuraffaPermissionsPlugin.swift` iOS, `SwiftZuraffaPermissionsPlugin.swift` macOS)
  from `attempts >= 60` to `attempts >= 200` (≈30s). Re-ran: the permission was already
  granted from run 1, so `request` resolved to `granted` immediately (no dialog) and the test
  passed — `All tests passed!`
- env caveat (debug attach): the first attempt also failed earlier with "Dart VM Service was
  not discovered after 60 seconds". Once the user confirmed Developer Mode was on and the Mac
  authorized **Xcode** under System Settings → Privacy & Security → Automation, the debug
  session attached and the test executed. Recorded so the next physical-device run skips the
  false start.
- recorded: 2026-08-29. Not committed (no git mutation requested).

