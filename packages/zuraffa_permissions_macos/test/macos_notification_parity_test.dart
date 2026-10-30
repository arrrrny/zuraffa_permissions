import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// macOS adapter parity contract (issue #14 — zik_zak adoption, spec 1206
/// FR-1/FR-3). The shared pool host has no macOS test harness, so the
/// native rules are pinned at source level — the same read-the-source
/// reach the SPM contract suite (swift_package_manager_test.dart) uses.
///
/// Pinned here, verbatim from the adopting app's behavior (zik_zak
/// `MacosPermissionProvider` + its native `MacOSPermissionPlugin`):
/// - the notification scope runs on UNUserNotificationCenter; `check`
///   reports the current authorization status (denied is denied — never
///   undetermined) and `request` prompts once and returns the outcome,
///   with the provisionally-granted case surfacing as granted;
/// - `openSettings` deep-links the system Notifications pane
///   (`x-apple.systempreferences:com.apple.Notifications-Settings`);
/// - unsupported scopes — camera and location on the macOS desktop
///   surface, and anything unknown — report denied WITHOUT prompting:
///   no OS dialog may ever appear for them.
void main() {
  const pluginPath = 'macos/zuraffa_permissions_macos/Sources/'
      'zuraffa_permissions_macos/SwiftZuraffaPermissionsPlugin.swift';

  /// The source of one `private func <name>` body, sliced from its
  /// declaration to the next declaration (close enough for contract
  /// assertions; the file is single-class, uniformly indented). Line
  /// comments are stripped so assertions match code, not prose.
  String bodyOf(String source, String name) {
    final marker = 'private func $name';
    final start = source.indexOf(marker);
    expect(start, isNonNegative, reason: '$marker must exist in the plugin');
    final next = source.indexOf('private func ', start + marker.length);
    final body = source.substring(start, next == -1 ? source.length : next);
    return body.replaceAll(RegExp(r'//[^\n]*'), '');
  }

  test('plugin source exists in the SPM layout', () {
    expect(File(pluginPath).existsSync(), isTrue,
        reason: 'expected $pluginPath to exist');
  });

  group('notification scope (UNUserNotificationCenter)', () {
    test('check reports the current authorization status', () {
      final source = File(pluginPath).readAsStringSync();
      expect(
        source,
        contains('UNUserNotificationCenter.current().getNotificationSettings'),
        reason: 'notification check goes through UNUserNotificationCenter',
      );
      final body = bodyOf(source, 'notificationStatus');
      expect(
        body,
        contains('case .authorized, .provisional, .ephemeral:'),
        reason:
            'authorized, provisional and ephemeral are all grants — '
            'provisional surfaces as granted (the app folds it at its '
            'own boundary)',
      );
      expect(
        body,
        contains('case .denied:'),
        reason: 'an explicit user denial must check as denied',
      );
      expect(
        body,
        contains('case .notDetermined:'),
        reason: 'a scope never decided must check as undetermined',
      );
    });

    test('check never reports a denied scope as undetermined', () {
      final source = File(pluginPath).readAsStringSync();
      final body = bodyOf(source, 'notificationStatus');
      final deniedArm = body.indexOf('case .denied:');
      expect(deniedArm, isNonNegative);
      final armTail = body.substring(
        deniedArm,
        body.indexOf('case ', deniedArm + 1) == -1
            ? body.length
            : body.indexOf('case ', deniedArm + 1),
      );
      expect(
        armTail,
        contains('denied'),
        reason: 'the .denied arm resolves to the denied wire status',
      );
      expect(
        armTail,
        isNot(contains('undetermined')),
        reason:
            'denied must never collapse into undetermined — the app '
            'routes a denied scope to settings, an undetermined one '
            'back into request',
      );
    });

    test('request prompts once and returns the outcome', () {
      final source = File(pluginPath).readAsStringSync();
      expect(
        source,
        contains(
          'UNUserNotificationCenter.current().requestAuthorization(',
        ),
        reason: 'notification request goes through requestAuthorization',
      );
      final body = bodyOf(source, 'requestNotifications');
      expect(
        body,
        contains('grantedAccess ? self.granted : self.denied'),
        reason: 'the prompt outcome maps onto granted/denied',
      );
    });
  });

  group('openSettings (Notifications pane parity)', () {
    test('deep-links the system Notifications pane', () {
      final source = File(pluginPath).readAsStringSync();
      expect(
        source,
        contains(
          'x-apple.systempreferences:com.apple.Notifications-Settings',
        ),
        reason:
            'the app retires its channel with zero behavior change — its '
            'settings routing deep-links exactly this pane',
      );
    });

    test('no longer lands on the Security & Privacy pane', () {
      final source = File(pluginPath).readAsStringSync();
      expect(
        source,
        isNot(contains('com.apple.preference.security')),
        reason:
            'the privacy pane is the wrong destination for the '
            'notification scope\'s settings flow',
      );
    });

    test('reports whether the pane could be launched', () {
      final source = File(pluginPath).readAsStringSync();
      final body = bodyOf(source, 'openSettings');
      expect(
        body,
        contains('return NSWorkspace.shared.open(url)'),
        reason: 'the launch result is the port\'s openSettings boolean',
      );
    });
  });

  group('unsupported scopes deny silently', () {
    test('camera and location never reach a prompt on check', () {
      final source = File(pluginPath).readAsStringSync();
      final body = bodyOf(source, 'checkScope');
      expect(
        body,
        contains('case "camera", "locationWhenInUse", "locationAlways":'),
        reason: 'the macOS desktop surface does not support them',
      );
      expect(
        body,
        isNot(contains('avStatus(for: AVMediaType.video)')),
        reason: 'no camera status probe may remain on the check path',
      );
      expect(
        body,
        isNot(contains('locationStatus()')),
        reason: 'no location status probe may remain on the check path',
      );
    });

    test('camera and location never reach a prompt on request', () {
      final source = File(pluginPath).readAsStringSync();
      final body = bodyOf(source, 'requestScope');
      expect(
        body,
        contains('case "camera", "locationWhenInUse", "locationAlways":'),
        reason: 'the macOS desktop surface does not support them',
      );
      expect(
        body,
        isNot(contains('requestAV(.video')),
        reason: 'requesting camera must never raise the AVFoundation prompt',
      );
      expect(
        body,
        isNot(contains('requestLocation(')),
        reason: 'requesting location must never raise the CoreLocation prompt',
      );
    });

    test('the location prompt machinery is gone from the plugin', () {
      final source = File(pluginPath).readAsStringSync();
      expect(
        source,
        isNot(contains('CLLocationManager')),
        reason:
            'a silent-deny scope keeps no prompt machinery — dead prompt '
            'code would contradict the pinned rule',
      );
      expect(
        source,
        isNot(contains('AVMediaType.video')),
        reason: 'same for the camera prompt machinery',
      );
    });

    test('unknown scopes deny instead of reporting undetermined', () {
      final source = File(pluginPath).readAsStringSync();
      for (final name in ['checkScope', 'requestScope']) {
        final body = bodyOf(source, name);
        final defaultArm = body.indexOf('default:');
        expect(defaultArm, isNonNegative,
            reason: '$name must keep a default arm');
        final armTail = body.substring(defaultArm);
        expect(
          armTail,
          contains('completion(denied)'),
          reason:
              '$name: an unknown scope is unsupported — denied without '
              'prompting, never undetermined (the app maps unknown to '
              'denied)',
        );
        expect(
          armTail,
          isNot(contains('undetermined')),
          reason: '$name: the default arm may not fall back to undetermined',
        );
      }
    });
  });
}
