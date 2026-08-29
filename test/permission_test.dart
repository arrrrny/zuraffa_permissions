import 'package:test/test.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt, ZuraffaPlatformException;
import 'package:zuraffa_permissions/zuraffa_permissions.dart';
import 'package:zuraffa_permissions/src/domain/usecases/permission_scope/create_permission_scope_usecase.dart';
import 'package:zuraffa_permissions/src/domain/usecases/permission_scope/get_permission_scope_usecase.dart';
import 'package:zuraffa_permissions/src/domain/usecases/permission_scope/get_permission_scope_list_usecase.dart';

/// Named scope identifiers — the literal ids the registry keys on, reused
/// across tests so a typo fails a compile rather than a silent mismatch.
const kCamera = 'camera';
const kPhotos = 'photos';
const kNotifications = 'notifications';
const kLocationWhenInUse = 'locationWhenInUse';
const kLocationAlways = 'locationAlways';
const kMicrophone = 'microphone';
const kStorage = 'storage';
const kBiometrics = 'biometrics';
const kContacts = 'contacts';
const kCalendar = 'calendar';
const kTracking = 'tracking';

/// Spec `001-permission-port` — the port contract, the registry, the
/// service, and the in-memory adapter's state machine (all pure Dart).
void main() {
  group('built-in scopes (FR-003)', () {
    test('all eleven built-ins are registered with zero configuration', () {
      final registry = PermissionScopeRegistry.withBuiltIns();
      for (final id in [
        kCamera,
        kPhotos,
        kNotifications,
        kLocationWhenInUse,
        kLocationAlways,
        kMicrophone,
        kStorage,
        kBiometrics,
        kContacts,
        kCalendar,
        kTracking,
      ]) {
        expect(registry.contains(id), isTrue, reason: '$id must ship built-in');
      }
      expect(BuiltInPermissionScopes.all, hasLength(11),
          reason: 'eleven built-ins ship zero-config');
      expect(registry.lookup(kCamera)!.platformGroup, 'media',
          reason: 'camera maps to the media platform group');
      expect(
        registry.lookup(kNotifications)!.description,
        contains('notification'),
        reason: 'notifications scope carries a notification description',
      );
    });

    test('tracking is the 11th built-in scope, registered zero-config (FR-003)', () {
      final registry = PermissionScopeRegistry.withBuiltIns();
      expect(registry.contains(kTracking), isTrue,
          reason: 'tracking must ship built-in');
      expect(BuiltInPermissionScopes.tracking.id, kTracking);
      expect(BuiltInPermissionScopes.tracking.platformGroup, 'privacy',
          reason: 'tracking maps to the privacy platform group');
      expect(BuiltInPermissionScopes.all, hasLength(11),
          reason: 'eleven built-ins including tracking');
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
      expect(registry.all, hasLength(12),
          reason: 'eleven built-ins plus one custom');

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
          isA<ZuraffaPlatformException>().having(
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
      expect(await port.check(kCamera), PermissionStatus.undetermined);
    });

    test('request on an undetermined scope resolves the prepared prompt '
        'outcome and records it', () async {
      final port = InMemoryPermissionAdapter()
        ..setPromptOutcome(kCamera, PermissionStatus.denied);

      expect((await port.request(kCamera)).status, PermissionStatus.denied);
      expect(
        await port.check(kCamera),
        PermissionStatus.denied,
        reason: 'the outcome is sticky',
      );
    });

    test('request defaults to granted when no outcome is prepared', () async {
      final port = InMemoryPermissionAdapter();
      expect((await port.request(kPhotos)).status, PermissionStatus.granted);
      expect(await port.check(kPhotos), PermissionStatus.granted);
    });

    test('permanently denied never re-prompts (FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..permanentlyDeny(kNotifications)
        ..setPromptOutcome(kNotifications, PermissionStatus.granted);

      expect(
        (await port.request(kNotifications)).status,
        PermissionStatus.permanentlyDenied,
        reason: 'the prepared prompt outcome must be ignored',
      );
    });

    test('already-decided scopes return their status unchanged '
        '(idempotent requests)', () async {
      final port = InMemoryPermissionAdapter()..grant(kStorage);

      expect((await port.request(kStorage)).status, PermissionStatus.granted);
      // A second request after a deny still reports denied.
      port.deny(kStorage);
      expect((await port.request(kStorage)).status, PermissionStatus.denied);
    });

    test('a scope currently limited is returned unchanged and not re-prompted '
        '(FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..setStatus(kCamera, PermissionStatus.limited);
      // Even with a prepared prompt outcome, a decided scope is not re-prompted.
      port.setPromptOutcome(kCamera, PermissionStatus.granted);

      expect((await port.request(kCamera)).status, PermissionStatus.limited);
    });

    test('a scope currently restricted is returned unchanged and not re-prompted '
        '(FR-005)', () async {
      final port = InMemoryPermissionAdapter()
        ..setStatus(kCamera, PermissionStatus.restricted);
      port.setPromptOutcome(kCamera, PermissionStatus.granted);

      expect((await port.request(kCamera)).status, PermissionStatus.restricted);
    });

    test('check() returns an explicitly set limited or restricted status (FR-002)', () async {
      final port = InMemoryPermissionAdapter();
      port.setStatus(kCamera, PermissionStatus.limited);
      expect(await port.check(kCamera), PermissionStatus.limited);

      port.setStatus(kPhotos, PermissionStatus.restricted);
      expect(await port.check(kPhotos), PermissionStatus.restricted);
    });

    test('request returns a PermissionRequestResult carrying scope, status, and '
        'requestedAt (FR-001)', () async {
      final port = InMemoryPermissionAdapter()
        ..setPromptOutcome(kCamera, PermissionStatus.granted);
      final result = await port.request(kCamera);
      expect(result.scope, kCamera, reason: 'result carries the requested scope');
      expect(result.status, PermissionStatus.granted,
          reason: 'result carries the resolved status');
      expect(result.requestedAt, greaterThan(0),
          reason: 'result carries a positive timestamp');
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
        ..setPromptOutcome(kCamera, PermissionStatus.granted);
      final service = PermissionService(port: adapter);

      expect((await service.request(kCamera)).status, PermissionStatus.granted);
      expect(await service.check(kCamera), PermissionStatus.granted);
    });

    test('an unknown scope is a typed, fail-fast error', () async {
      final service = PermissionService();
      expect(
        () => service.request('telepathy'),
        throwsA(
          isA<ZuraffaPlatformException>().having(
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
        containsAll(<String>['nfc', kBiometrics]),
      );
    });

    test('registerPermissionDependencies wires the stack onto GetIt', () async {
      final getIt = getItForTest();
      registerPermissionDependencies(getIt);

      final service = getIt<PermissionService>();
      expect(await service.check(kMicrophone), PermissionStatus.undetermined);
      expect(service.scopes, hasLength(11));
    });

    test('DI honors an injected custom adapter', () async {
      final getIt = getItForTest();
      final adapter = InMemoryPermissionAdapter()..grant(kCalendar);
      registerPermissionDependencies(getIt, port: adapter);

      final service = getIt<PermissionService>();
      expect(await service.check(kCalendar), PermissionStatus.granted);
    });

    test('registerPermissionDependencies also wires the permission-scope use '
        'cases (FR-007)', () async {
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
    // A distinguishable instance: granted for camera, so a test can prove which
    // `PermissionPort` the DI actually resolved (a default `InMemoryPermissionAdapter`
    // would report `undetermined` for an unset scope).
    late InMemoryPermissionAdapter fake;

    setUp(() {
      fake = InMemoryPermissionAdapter()..grant(kCamera);
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

      // Pin the wiring directly: the resolved port must be the factory instance,
      // not the in-memory default.
      expect(identical(getIt<PermissionPort>(), fake), isTrue,
          reason: 'DI must resolve the factory-supplied port, not the default');
      final service = getIt<PermissionService>();
      expect(await service.check(kCamera), PermissionStatus.granted,
          reason: 'factory port reports granted (default would be undetermined)');
      expect(await service.request(kCamera), isA<PermissionRequestResult>());
    });

    test('an injected port still wins over the factory', () async {
      final injected = InMemoryPermissionAdapter()..grant(kCamera);
      final getIt = getItForTest();
      registerPermissionDependencies(getIt, port: injected);

      final service = getIt<PermissionService>();
      expect(await service.check(kCamera), PermissionStatus.granted);
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
