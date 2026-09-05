import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_permissions/zuraffa_permissions.dart';

import 'package:example/main.dart';

/// The outcome-matrix demonstrator's widget suite (issue #7).
///
/// Every test drives the real [PermissionApp] root through the real
/// [PermissionService] public API; the simulator tab's port is the package's
/// own [InMemoryPermissionAdapter] — the profile's in-memory-fake convention,
/// no mocking library.
void main() {
  /// Test surface tall enough for the matrix, the exerciser, and the log.
  void useLargeSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  PermissionService inMemoryService() =>
      PermissionService(port: InMemoryPermissionAdapter());

  InMemoryPermissionAdapter adapterOf(PermissionService service) =>
      service.port as InMemoryPermissionAdapter;

  Future<PermissionService> pumpMatrix(WidgetTester tester) async {
    final service = inMemoryService();
    await tester.pumpWidget(PermissionApp(matrixService: service));
    await tester.pumpAndSettle();
    return service;
  }

  Finder cell(String scope, PermissionStatus status) =>
      find.byKey(ValueKey('matrix-cell-$scope-${status.name}'));

  Finder statusChip(String scope) => find.byKey(ValueKey('status-chip-$scope'));

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  group('acceptance (issue #7)', () {
    testWidgets('the app boots to the outcome-matrix home', (tester) async {
      useLargeSurface(tester);
      await pumpMatrix(tester);
      expect(
        find.text('zuraffa_permissions'),
        findsOneWidget,
        reason: 'the app bar title renders',
      );
      expect(find.text('Matrix'), findsOneWidget, reason: 'simulator tab renders');
      expect(find.text('Live'), findsOneWidget, reason: 'live tab renders');
      expect(
        find.text('Outcome matrix — every scope × status'),
        findsOneWidget,
        reason: 'the outcome-matrix section renders',
      );
    });

    testWidgets('every built-in scope is exercisable end to end', (tester) async {
      useLargeSurface(tester);
      final service = await pumpMatrix(tester);
      final adapter = adapterOf(service);
      for (final scope in BuiltInPermissionScopes.all) {
        await tap(tester, cell(scope.id, PermissionStatus.denied));
        await tap(tester, find.byKey(ValueKey('request-${scope.id}')));
        expect(
          find.descendant(
            of: statusChip(scope.id),
            matching: find.text(PermissionStatus.denied.name),
          ),
          findsOneWidget,
          reason: '${scope.id}: placed into a status and requested through '
              'the real port',
        );
        expect(
          await adapter.check(scope.id),
          PermissionStatus.denied,
          reason: '${scope.id}: the port recorded the outcome',
        );
      }
    });
  });

  group('outcome matrix structure (FR-001/FR-002)', () {
    testWidgets('renders a matrix row for every built-in scope', (tester) async {
      useLargeSurface(tester);
      await pumpMatrix(tester);
      const issueScopes = {
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
      };
      for (final scope in BuiltInPermissionScopes.all) {
        expect(
          find.byKey(ValueKey('matrix-scope-${scope.id}')),
          findsOneWidget,
          reason: 'the matrix renders the ${scope.id} row',
        );
      }
      expect(
        BuiltInPermissionScopes.all.map((scope) => scope.id).toSet().containsAll(
              issueScopes,
            ),
        isTrue,
        reason: 'the ten scopes named in issue #7 are all built-ins',
      );
    });

    testWidgets('presents the six statuses as columns in enum order', (
      tester,
    ) async {
      useLargeSurface(tester);
      await pumpMatrix(tester);
      final xs = <double>[];
      for (final status in PermissionStatus.values) {
        final header = find.byKey(ValueKey('matrix-col-${status.name}'));
        expect(header, findsOneWidget, reason: 'the ${status.name} column renders');
        xs.add(tester.getTopLeft(header).dx);
      }
      for (var i = 1; i < xs.length; i++) {
        expect(
          xs[i] > xs[i - 1],
          isTrue,
          reason:
              'the ${PermissionStatus.values[i].name} column renders after '
              '${PermissionStatus.values[i - 1].name} (enum order)',
        );
      }
    });
  });

  group('request flow (FR-004)', () {
    testWidgets(
      'request on an undetermined scope resolves the prepared prompt outcome',
      (tester) async {
        useLargeSurface(tester);
        final service = await pumpMatrix(tester);
        final adapter = adapterOf(service);
        adapter.setPromptOutcome('camera', PermissionStatus.denied);
        await tap(tester, find.byKey(const ValueKey('request-camera')));
        expect(
          find.descendant(
            of: statusChip('camera'),
            matching: find.text(PermissionStatus.denied.name),
          ),
          findsOneWidget,
          reason: 'the prompt outcome the adapter prepared is what shows',
        );
        expect(
          await adapter.check('camera'),
          PermissionStatus.denied,
          reason: 'the resolved outcome is recorded (sticky)',
        );
      },
    );

    testWidgets('request with no prepared outcome defaults to granted', (
      tester,
    ) async {
      useLargeSurface(tester);
      final service = await pumpMatrix(tester);
      final adapter = adapterOf(service);
      await tap(tester, find.byKey(const ValueKey('request-photos')));
      expect(
        find.descendant(
          of: statusChip('photos'),
          matching: find.text(PermissionStatus.granted.name),
        ),
        findsOneWidget,
        reason: 'the in-memory default prompt resolves to granted',
      );
      expect(
        await adapter.check('photos'),
        PermissionStatus.granted,
        reason: 'the default outcome is recorded',
      );
    });

    testWidgets(
      'request on an already-decided status returns it unchanged',
      (tester) async {
        useLargeSurface(tester);
        await pumpMatrix(tester);
        const decided = [
          PermissionStatus.granted,
          PermissionStatus.denied,
          PermissionStatus.restricted,
          PermissionStatus.limited,
        ];
        for (final status in decided) {
          await tap(tester, cell('microphone', status));
          await tap(tester, find.byKey(const ValueKey('request-microphone')));
          expect(
            find.descendant(
              of: statusChip('microphone'),
              matching: find.text(status.name),
            ),
            findsOneWidget,
            reason: 'request returns the decided ${status.name} unchanged '
                '(idempotent)',
          );
        }
      },
    );
  });

  group('scope × status cells (FR-003)', () {
    testWidgets('every cell forces its scope into that status', (tester) async {
      useLargeSurface(tester);
      final service = await pumpMatrix(tester);
      final adapter = adapterOf(service);
      for (final scope in BuiltInPermissionScopes.all) {
        for (final status in PermissionStatus.values) {
          await tap(tester, cell(scope.id, status));
          expect(
            find.descendant(
              of: statusChip(scope.id),
              matching: find.text(status.name),
            ),
            findsOneWidget,
            reason: 'forcing ${scope.id} to ${status.name} shows that status',
          );
          expect(
            await adapter.check(scope.id),
            status,
            reason: 'the adapter records ${scope.id} as ${status.name}',
          );
        }
      }
    });

    testWidgets('the active cell marker tracks the forced status', (
      tester,
    ) async {
      useLargeSurface(tester);
      await pumpMatrix(tester);
      final dot = find.byKey(const ValueKey('matrix-active-dot-camera'));
      expect(dot, findsOneWidget, reason: 'the active-cell marker renders');
      expect(
        find.ancestor(of: dot, matching: cell('camera', PermissionStatus.undetermined)),
        findsOneWidget,
        reason: 'camera starts undetermined',
      );
      await tap(tester, cell('camera', PermissionStatus.granted));
      expect(
        find.ancestor(of: dot, matching: cell('camera', PermissionStatus.granted)),
        findsOneWidget,
        reason: 'the marker moves to the granted cell',
      );
      await tap(tester, cell('camera', PermissionStatus.limited));
      expect(
        find.ancestor(of: dot, matching: cell('camera', PermissionStatus.limited)),
        findsOneWidget,
        reason: 'the marker moves to the limited cell',
      );
    });
  });
}
