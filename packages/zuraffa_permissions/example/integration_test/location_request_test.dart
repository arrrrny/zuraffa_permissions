import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

/// Real-device location **request** path (001-permission-port).
///
/// This is a focused, interactive test intended for a physical iPhone. It calls
/// `request('locationWhenInUse')`, which pops the system "Allow location while
/// using the app" dialog. The runner blocks until the user taps; once resolved,
/// the status must be non-`undetermined`, which is what distinguishes a real
/// grant flow from a no-op.
///
/// The automated macOS / Android / iOS-simulator runs cover the non-blocking
/// `check('locationWhenInUse')` path in `permission_test.dart` instead, so they
/// stay dialog-free. A physical device is used here because only a real OS
/// exercises an authentic location grant.
///
/// Requires `NSLocationWhenInUseUsageDescription` in the example's iOS
/// Info.plist, or `requestWhenInUseAuthorization` crashes on a real device.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('zuraffa_permissions — location request on a real device', () {
    late PermissionService service;

    setUp(() {
      final getIt = GetIt.asNewInstance();
      registerPermissionDependencies(getIt);
      service = getIt<PermissionService>();
    });

    testWidgets(
      'request(locationWhenInUse) engages the system prompt and resolves',
      (tester) async {
        // Non-blocking check first: proves the channel already carries location.
        final before = await service.check('locationWhenInUse');
        expect(PermissionStatus.values, contains(before));

        // request() pops the system dialog (tap Allow when it appears). The
        // resolved status must be non-undetermined — that is the signal the
        // grant flow actually round-tripped through the native channel.
        final result = await service.request('locationWhenInUse');
        expect(result, isA<PermissionRequestResult>());
        expect(result.scope, 'locationWhenInUse');
        expect(
          result.status,
          isNot(PermissionStatus.undetermined),
          reason:
              'request must engage the system prompt and resolve to a real '
              'status, not stay undetermined',
        );
      },
    );
  });
}
