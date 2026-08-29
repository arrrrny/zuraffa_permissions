import 'package:test/test.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt, ZuraffaSessionException;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

/// Spec `001-permission-port` — the port contract, the registry, the
/// service, and the in-memory adapter's state machine (all pure Dart).
void main() {
  group('built-in scopes (FR-003)', () {
    test('all ten built-ins are registered with zero configuration', () {
      final registry = PermissionScopeRegistry.withBuiltIns();
      for (final id in [
        'camera',
        'photos',
        'notifications',
        'locationWhenInUse',
        'locationAlways',
        'microphone',
        'storage',
        'biometrics',
        'contacts',
        'calendar',
      ]) {
        expect(registry.contains(id), isTrue, reason: '$id must ship built-in');
      }
      expect(BuiltInPermissionScopes.all, hasLength(10));
      expect(registry.lookup('camera')!.platformGroup, 'media');
      expect(
        registry.lookup('notifications')!.description,
        contains('notification'),
      );
    });

    test('custom scopes register through the same seam (FR-004)', () {
      final registry = PermissionScopeRegistry.withBuiltIns()
        ..register(
          PermissionScope(
            id: 'bluetoothScan',
            name: 'bluetoothScan',
            description: 'Scan for nearby Bluetooth devices.',
            platformGroup: 'connectivity',
          ),
        );

      expect(registry.contains('bluetoothScan'), isTrue);
      expect(registry.all, hasLength(11));

      // Duplicate registration is a typed error.
      expect(
        () => registry.register(
          PermissionScope(
            id: 'bluetoothScan',
            name: 'bluetoothScan',
            description: 'shadow',
            platformGroup: 'x',
          ),
        ),
        throwsA(
          isA<ZuraffaSessionException>().having(
            (e) => e.code,
            'code',
            'duplicate_scope',
          ),
        ),
      );
    });
  });

  group('in-memory adapter state machine (FR-006, FR-005)', () {
    test('every scope starts undetermined', () async {
      final port = InMemoryPermissionAdapter();
      expect(await port.check('camera'), PermissionStatus.undetermined);
    });

    test('request on an undetermined scope resolves the prepared prompt '
        'outcome and records it', () async {
      final port = InMemoryPermissionAdapter()
        ..setPromptOutcome('camera', PermissionStatus.denied);

      expect(await port.request('camera'), PermissionStatus.denied);
      expect(
        await port.check('camera'),
        PermissionStatus.denied,
        reason: 'the outcome is sticky',
      );
    });

    test('request defaults to granted when no outcome is prepared', () async {
      final port = InMemoryPermissionAdapter();
      expect(await port.request('photos'), PermissionStatus.granted);
      expect(await port.check('photos'), PermissionStatus.granted);
    });

    test('permanently denied never re-prompts (FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..permanentlyDeny('notifications')
        ..setPromptOutcome('notifications', PermissionStatus.granted);

      expect(
        await port.request('notifications'),
        PermissionStatus.permanentlyDenied,
        reason: 'the prepared prompt outcome must be ignored',
      );
    });

    test('already-decided scopes return their status unchanged '
        '(idempotent requests)', () async {
      final port = InMemoryPermissionAdapter()..grant('storage');

      expect(await port.request('storage'), PermissionStatus.granted);
      // A second request after a deny still reports denied.
      port.deny('storage');
      expect(await port.request('storage'), PermissionStatus.denied);
    });

    test('a scope currently limited is returned unchanged and not re-prompted '
        '(FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..setStatus('camera', PermissionStatus.limited);
      // Even with a prepared prompt outcome, a decided scope is not re-prompted.
      port.setPromptOutcome('camera', PermissionStatus.granted);

      expect(await port.request('camera'), PermissionStatus.limited);
    });

    test('a scope currently restricted is returned unchanged and not re-prompted '
        '(FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..setStatus('camera', PermissionStatus.restricted);
      port.setPromptOutcome('camera', PermissionStatus.granted);

      expect(await port.request('camera'), PermissionStatus.restricted);
    });

    test('openSettings reports launchability', () async {
      final port = InMemoryPermissionAdapter();
      expect(await port.openSettings(), isTrue);
      port.settingsLaunchable = false;
      expect(await port.openSettings(), isFalse);
    });
  });

  group('PermissionService (FR-001/FR-007)', () {
    test('request routes through the port for registered scopes', () async {
      final adapter = InMemoryPermissionAdapter()
        ..setPromptOutcome('camera', PermissionStatus.granted);
      final service = PermissionService(port: adapter);

      expect(await service.request('camera'), PermissionStatus.granted);
      expect(await service.check('camera'), PermissionStatus.granted);
    });

    test('an unknown scope is a typed, fail-fast error', () async {
      final service = PermissionService();
      expect(
        () => service.request('telepathy'),
        throwsA(
          isA<ZuraffaSessionException>().having(
            (e) => e.code,
            'code',
            'unknown_scope',
          ),
        ),
      );
    });

    test('scopes surface built-in and custom metadata', () {
      final service = PermissionService(
        registry: PermissionScopeRegistry.withBuiltIns()
          ..register(
            PermissionScope(
              id: 'nfc',
              name: 'nfc',
              description: 'Read NFC tags.',
              platformGroup: 'connectivity',
            ),
          ),
      );

      expect(service.scopes, hasLength(11));
      expect(
        service.scopes.map((scope) => scope.id),
        containsAll(<String>['nfc', 'biometrics']),
      );
    });

    test('registerPermissionDependencies wires the stack onto GetIt', () async {
      final getIt = getItForTest();
      registerPermissionDependencies(getIt);

      final service = getIt<PermissionService>();
      expect(await service.check('microphone'), PermissionStatus.undetermined);
      expect(service.scopes, hasLength(10));
    });

    test('DI honors an injected custom adapter', () async {
      final getIt = getItForTest();
      final adapter = InMemoryPermissionAdapter()..grant('calendar');
      registerPermissionDependencies(getIt, port: adapter);

      final service = getIt<PermissionService>();
      expect(await service.check('calendar'), PermissionStatus.granted);
    });
  });

  group('permission status enum (FR-002)', () {
    test('enumerates exactly the six required states', () {
      expect(PermissionStatus.values, hasLength(6));
      expect(
        PermissionStatus.values.map((s) => s.name).toSet(),
        {
          'granted',
          'denied',
          'permanentlyDenied',
          'undetermined',
          'restricted',
          'limited',
        },
      );
    });
  });
}

/// Fresh GetIt per test (registerLazySingleton rejects re-registration on
/// a shared instance).
GetIt getItForTest() {
  final getIt = GetIt.asNewInstance();
  return getIt;
}
