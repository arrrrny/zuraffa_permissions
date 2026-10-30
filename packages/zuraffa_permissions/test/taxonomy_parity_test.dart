import 'package:test/test.dart';
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

/// Status-taxonomy parity review for the zik_zak adoption (issue #14,
/// zik_zak spec 1206 FR-1/FR-3, US1–US2) — the review the issue requires
/// to be recorded, pinned as a test: every status the app's providers
/// map on all three platforms is expressible through the port's
/// `PermissionStatus` vocabulary, `PermissionRequestResult` carries each
/// of them, and the FR-005 no-reprompt contract after `permanentlyDenied`
/// still holds for the notification scope's settings-routing flow.
///
/// The app's source surfaces (arrrrny/zik_zak@master):
/// - iOS/Android `PermissionProvider` maps `permission_handler` statuses,
///   folding `provisional` into `granted` at its own boundary;
/// - macOS `MacosPermissionProvider` maps its native channel's
///   granted/denied vocabulary and hard-denies every non-notification
///   scope (unknown native statuses map to denied too).
void main() {
  const kNotifications = 'notifications';

  /// The `permission_handler` statuses the app maps on iOS/Android, with
  /// the app's provisional fold applied (spec 1206: the fold happens at
  /// the app's boundary, so the port only needs to express the outcome).
  final mobileSourceStatuses = <String, PermissionStatus>{
    'granted': PermissionStatus.granted,
    'denied': PermissionStatus.denied,
    'restricted': PermissionStatus.restricted,
    'limited': PermissionStatus.limited,
    'permanentlyDenied': PermissionStatus.permanentlyDenied,
    'provisional (folded to granted at the app boundary)':
        PermissionStatus.granted,
  };

  /// The statuses the app's macOS surface produces: the native channel's
  /// grants and denials, the hard-deny for non-notification scopes, and
  /// the unknown-status fallback — plus the faithful `undetermined` the
  /// port now reports for a never-decided notification scope.
  final macosSourceStatuses = <String, PermissionStatus>{
    'authorized/provisional/ephemeral (native grants)':
        PermissionStatus.granted,
    'denied (native denial)': PermissionStatus.denied,
    'notDetermined (faithful port status)': PermissionStatus.undetermined,
    'non-notification scope (hard-deny, no prompt)': PermissionStatus.denied,
    'unknown native status (fallback)': PermissionStatus.denied,
  };

  PermissionRequestResult resultFor(PermissionStatus status) =>
      PermissionRequestResult(
        scope: kNotifications,
        status: status,
        requestedAt: 0,
      );

  group('taxonomy parity (issue #14, spec 1206 FR-1/FR-3)', () {
    test('every iOS/Android source status the app maps is expressible', () {
      for (final entry in mobileSourceStatuses.entries) {
        expect(
          PermissionStatus.values,
          contains(entry.value),
          reason: '${entry.key}: expressible through the port',
        );
      }
    });

    test('every macOS source status the app maps is expressible', () {
      for (final entry in macosSourceStatuses.entries) {
        expect(
          PermissionStatus.values,
          contains(entry.value),
          reason: '${entry.key}: expressible through the port',
        );
      }
    });

    test('the port round-trips every vocabulary value through check', () async {
      final port = InMemoryPermissionAdapter();
      for (final status in PermissionStatus.values) {
        port.setStatus(kNotifications, status);
        expect(
          await port.check(kNotifications),
          status,
          reason: '${status.name}: expressible through the port surface',
        );
      }
    });

    test('PermissionRequestResult carries every vocabulary value', () {
      for (final status in PermissionStatus.values) {
        expect(
          resultFor(status).status,
          status,
          reason: '${status.name}: a request result can express it',
        );
      }
    });

    test('request never re-prompts after permanentlyDenied (FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..permanentlyDeny(kNotifications)
        // Even a prepared prompt outcome must be ignored: the OS would
        // not show a dialog, the caller routes to openSettings.
        ..setPromptOutcome(kNotifications, PermissionStatus.granted);

      final result = await port.request(kNotifications);
      expect(result.status, PermissionStatus.permanentlyDenied);
      expect(
        await port.check(kNotifications),
        PermissionStatus.permanentlyDenied,
        reason: 'the status survives the request unchanged',
      );
    });
  });
}
