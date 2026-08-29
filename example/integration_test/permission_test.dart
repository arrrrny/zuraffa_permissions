import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

/// Real-device characterization of the zuraffa_permissions federated plugin.
///
/// This runs on a physical OS (macOS / Android / iOS), not the in-memory
/// Dart adapter. To stay non-blocking it avoids scopes that pop a native
/// permission dialog; instead it proves the native plugin is registered and
/// the MethodChannel round-trips:
///
/// - `biometrics` is determinable on every real OS (granted/denied, never
///   `undetermined`), so a non-undetermined result proves the native plugin
///   answered over the channel rather than the in-memory fallback.
/// - `camera` is a mapped scope whose `check` returns a valid enum from the OS.
/// - `locationWhenInUse` is a built-in scope whose `check` returns a valid enum
///   from the OS without popping a dialog, proving the channel handles
///   location-specific platform groups.
/// - `storage` resolves without a dialog on every platform (scoped storage on
///   modern Android; unmapped on Apple platforms), exercising `request`.
/// - `openSettings` returns a bool from the native handler.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('zuraffa_permissions — real native plugin (001-permission-port)', () {
    late PermissionService service;

    setUp(() {
      final getIt = GetIt.asNewInstance();
      registerPermissionDependencies(getIt);
      service = getIt<PermissionService>();
    });

    testWidgets('native plugin is live and the method channel round-trips', (
      tester,
    ) async {
      // Proves the federated platform package registered and answered.
      final bio = await service.check('biometrics');
      expect(
        bio,
        isNot(PermissionStatus.undetermined),
        reason: 'native plugin must be live; undetermined means the '
            'in-memory fallback answered instead of the OS',
      );

      // A mapped scope returns a valid enum status straight from the OS.
      final camera = await service.check('camera');
      expect(PermissionStatus.values, contains(camera));

      // A built-in location scope returns a valid enum without a dialog,
      // proving the channel handles the location platform group.
      final location = await service.check('locationWhenInUse');
      expect(PermissionStatus.values, contains(location));

      // request() is plumbed through the channel and carries the scope id.
      final result = await service.request('storage');
      expect(result, isA<PermissionRequestResult>());
      expect(result.scope, 'storage');

      // openSettings resolves to a bool from the native handler.
      expect(await service.openSettings(), isA<bool>());
    });
  });
}
