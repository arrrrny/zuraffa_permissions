import 'package:test/test.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt, ZuraffaSessionException;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';
import 'package:zuraffa_permissions/src/domain/usecases/permission_scope/create_permission_scope_usecase.dart';
import 'package:zuraffa_permissions/src/domain/usecases/permission_scope/get_permission_scope_usecase.dart';
import 'package:zuraffa_permissions/src/domain/usecases/permission_scope/get_permission_scope_list_usecase.dart';

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
        'tracking',
      ]) {
        expect(registry.contains(id), isTrue, reason: '$id must ship built-in');
      }
      expect(BuiltInPermissionScopes.all, hasLength(11));
      expect(registry.lookup('camera')!.platformGroup, 'media');
      expect(
        registry.lookup('notifications')!.description,
        contains('notification'),
      );
    });

    test('tracking is the 11th built-in scope, registered zero-config (FR-003)', () {
      final registry = PermissionScopeRegistry.withBuiltIns();
      expect(registry.contains('tracking'), isTrue,
          reason: 'tracking must ship built-in');
      expect(BuiltInPermissionScopes.tracking.id, 'tracking');
      expect(BuiltInPermissionScopes.tracking.platformGroup, isNotNull);
      expect(BuiltInPermissionScopes.all, hasLength(11));
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
      expect(registry.all, hasLength(12));

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

      expect((await port.request('camera')).status, PermissionStatus.denied);
      expect(
        await port.check('camera'),
        PermissionStatus.denied,
        reason: 'the outcome is sticky',
      );
    });

    test('request defaults to granted when no outcome is prepared', () async {
      final port = InMemoryPermissionAdapter();
      expect((await port.request('photos')).status, PermissionStatus.granted);
      expect(await port.check('photos'), PermissionStatus.granted);
    });

    test('permanently denied never re-prompts (FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..permanentlyDeny('notifications')
        ..setPromptOutcome('notifications', PermissionStatus.granted);

      expect(
        (await port.request('notifications')).status,
        PermissionStatus.permanentlyDenied,
        reason: 'the prepared prompt outcome must be ignored',
      );
    });

    test('already-decided scopes return their status unchanged '
        '(idempotent requests)', () async {
      final port = InMemoryPermissionAdapter()..grant('storage');

      expect((await port.request('storage')).status, PermissionStatus.granted);
      // A second request after a deny still reports denied.
      port.deny('storage');
      expect((await port.request('storage')).status, PermissionStatus.denied);
    });

    test('a scope currently limited is returned unchanged and not re-prompted '
        '(FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..setStatus('camera', PermissionStatus.limited);
      // Even with a prepared prompt outcome, a decided scope is not re-prompted.
      port.setPromptOutcome('camera', PermissionStatus.granted);

      expect((await port.request('camera')).status, PermissionStatus.limited);
    });

    test('a scope currently restricted is returned unchanged and not re-prompted '
        '(FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..setStatus('camera', PermissionStatus.restricted);
      port.setPromptOutcome('camera', PermissionStatus.granted);

      expect((await port.request('camera')).status, PermissionStatus.restricted);
    });

    test('check() returns an explicitly set limited or restricted status (FR-002)', () async {
      final port = InMemoryPermissionAdapter();
      port.setStatus('camera', PermissionStatus.limited);
      expect(await port.check('camera'), PermissionStatus.limited);

      port.setStatus('photos', PermissionStatus.restricted);
      expect(await port.check('photos'), PermissionStatus.restricted);
    });

    test('request returns a PermissionRequestResult carrying scope, status, and requestedAt (FR-001)', () async {
      final port = InMemoryPermissionAdapter()
        ..setPromptOutcome('camera', PermissionStatus.granted);
      final result = await port.request('camera');
      expect(result.scope, 'camera');
      expect(result.status, PermissionStatus.granted);
      expect(result.requestedAt, greaterThan(0));
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

      expect((await service.request('camera')).status, PermissionStatus.granted);
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

      expect(service.scopes, hasLength(12));
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
      expect(service.scopes, hasLength(11));
    });

    test('DI honors an injected custom adapter', () async {
      final getIt = getItForTest();
      final adapter = InMemoryPermissionAdapter()..grant('calendar');
      registerPermissionDependencies(getIt, port: adapter);

      final service = getIt<PermissionService>();
      expect(await service.check('calendar'), PermissionStatus.granted);
    });

    test('registerPermissionDependencies also wires the permission-scope use cases '
        '(FR-007)', () async {
      final getIt = getItForTest();
      registerPermissionDependencies(getIt);

      expect(
        getIt<GetPermissionScopeListUseCase>(),
        isA<GetPermissionScopeListUseCase>(),
      );
      expect(
        getIt<GetPermissionScopeUseCase>(),
        isA<GetPermissionScopeUseCase>(),
      );
      expect(
        getIt<CreatePermissionScopeUseCase>(),
        isA<CreatePermissionScopeUseCase>(),
      );
    });
  });

  group('default port selection (FR-001 wiring)', () {
    // A fake that reports a distinguishable status so we can prove the
    // factory-supplied port is the one the DI actually resolved.
    late _FakePermissionPort fake;

    setUp(() {
      fake = _FakePermissionPort();
      setPlatformPermissionPortFactory(() => fake);
    });

    // Restore the pure-Dart default so the rest of the suite (and any later
    // test) still sees the in-memory adapter when no platform package is
    // registered (FR-006).
    tearDown(
      () => setPlatformPermissionPortFactory(() => InMemoryPermissionAdapter()),
    );

    test('registerPermissionDependencies uses the factory-supplied port', () async {
      final getIt = getItForTest();
      registerPermissionDependencies(getIt);

      final service = getIt<PermissionService>();
      // The fake reports granted; the in-memory default would report
      // undetermined — so granted proves the factory port is wired in.
      expect(await service.check('camera'), PermissionStatus.granted);
      expect(await service.request('camera'), isA<PermissionRequestResult>());
    });

    test('an injected port still wins over the factory', () async {
      final injected = InMemoryPermissionAdapter()..grant('camera');
      final getIt = getItForTest();
      registerPermissionDependencies(getIt, port: injected);

      final service = getIt<PermissionService>();
      expect(await service.check('camera'), PermissionStatus.granted);
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

/// Test double that reports a distinguishable status, so a test can prove
/// which [PermissionPort] the DI actually resolved.
class _FakePermissionPort implements PermissionPort {
  @override
  Future<PermissionStatus> check(String scope) async => PermissionStatus.granted;

  @override
  Future<PermissionRequestResult> request(String scope) async =>
      PermissionRequestResult(
        scope: scope,
        status: PermissionStatus.granted,
        requestedAt: 1,
      );

  @override
  Future<bool> openSettings() async => true;
}
