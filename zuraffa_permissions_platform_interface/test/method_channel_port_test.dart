// Behavioral suite for the method-channel port bridge (spec
// 001-method-channel-port). Written test-first against the shipped stack:
// every behavior is validated red via a deliberate mutant before it is
// counted green (see tdd/cycle-log.md for the per-cycle evidence).
//
// Style follows the repo's TDD profile: group names carry the FR tag,
// plain `expect`/matchers only, hand-rolled in-memory fakes (no mocking
// library — the channel is mocked through flutter_test's canonical
// TestDefaultBinaryMessengerBinding seam instead).
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_permissions/zuraffa_permissions.dart';
import 'package:zuraffa_permissions_platform_interface/zuraffa_permissions_platform_interface.dart';

// Named scope ids — no bare string literals at assertion sites.
const kCameraScope = 'camera';
const kPhotosScope = 'photos';
const kMicrophoneScope = 'microphone';

/// Hand-rolled in-memory fake (the repo's only double pattern): a
/// platform implementation with scripted replies, registered through the
/// real token-verified seam.
class _ScriptedPermissionsPlatform extends ZuraffaPermissionsPlatform {
  _ScriptedPermissionsPlatform({
    this.checkReply = const {},
    this.requestReply = const {},
    this.settingsLaunched = false,
  });

  final Map<String, String> checkReply;
  final Map<String, String> requestReply;
  final bool settingsLaunched;

  @override
  Future<Map<String, String>> checkPermissions(List<String> scopes) async => {
    for (final scope in scopes) scope: checkReply[scope] ?? 'undetermined',
  };

  @override
  Future<Map<String, String>> requestPermissions(List<String> scopes) async => {
    for (final scope in scopes) scope: requestReply[scope] ?? 'undetermined',
  };

  @override
  Future<bool> openSettings() async => settingsLaunched;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    // Restore the shipped default instance so instance-mutating tests
    // never leak into their siblings.
    ZuraffaPermissionsPlatform.instance = DefaultZuraffaPermissionsPlatform();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          MethodChannelZuraffaPermissions.channel,
          null,
        );
  });

  group('wire vocabulary (FR-001)', () {
    test(
      'U1: PermissionWireStatus exposes exactly the six stable wire strings',
      () {
        final wires = <String>{
          PermissionWireStatus.granted,
          PermissionWireStatus.denied,
          PermissionWireStatus.permanentlyDenied,
          PermissionWireStatus.undetermined,
          PermissionWireStatus.restricted,
          PermissionWireStatus.limited,
        };
        expect(
          wires,
          hasLength(6),
          reason: 'the vocabulary is exactly six strings',
        );
        expect(
          wires,
          equals(<String>{
            'granted',
            'denied',
            'permanentlyDenied',
            'undetermined',
            'restricted',
            'limited',
          }),
          reason: 'every wire string matches the documented channel vocabulary',
        );
      },
    );
  });

  group('platform instance registry (FR-002)', () {
    test(
      'U2: instance defaults to the safe fallback before any registration',
      () async {
        // No assignment here: this test reads the shipped default directly
        // (in the isolated single-test run the static is pristine, so a
        // default that stops initializing is observed as a read failure).
        expect(
          ZuraffaPermissionsPlatform.instance,
          isA<DefaultZuraffaPermissionsPlatform>(),
          reason: 'no platform package registered — the safe fallback is live',
        );
        expect(
          await ZuraffaPermissionsPlatform.instance.checkPermissions([
            kCameraScope,
          ]),
          {kCameraScope: 'undetermined'},
          reason: 'the default answers with the fallback semantics',
        );
      },
    );

    test(
      'U3: assigning instance registers a custom implementation that reads observe',
      () {
        final scripted = _ScriptedPermissionsPlatform(
          checkReply: {kCameraScope: 'granted'},
        );
        ZuraffaPermissionsPlatform.instance = scripted;
        expect(
          identical(ZuraffaPermissionsPlatform.instance, scripted),
          isTrue,
          reason: 'the registered implementation is the one reads observe',
        );
      },
    );
  });

  group('default fallback semantics (FR-003)', () {
    test(
      'U4: checkPermissions reports every requested scope as undetermined',
      () async {
        final fallback = DefaultZuraffaPermissionsPlatform();
        final statuses = await fallback.checkPermissions([
          kCameraScope,
          kPhotosScope,
          kMicrophoneScope,
        ]);
        expect(
          statuses,
          {
            kCameraScope: 'undetermined',
            kPhotosScope: 'undetermined',
            kMicrophoneScope: 'undetermined',
          },
          reason:
              'the fallback cannot know real statuses — everything is undetermined',
        );
      },
    );

    test(
      'U5: requestPermissions reports every requested scope as undetermined',
      () async {
        final fallback = DefaultZuraffaPermissionsPlatform();
        final statuses = await fallback.requestPermissions([kCameraScope]);
        expect(
          statuses,
          {kCameraScope: 'undetermined'},
          reason: 'the fallback never prompts — requests resolve undetermined',
        );
      },
    );

    test(
      'U6: openSettings returns false — the fallback cannot launch settings',
      () async {
        final fallback = DefaultZuraffaPermissionsPlatform();
        expect(
          await fallback.openSettings(),
          isFalse,
          reason: 'no platform package loaded — settings cannot be launched',
        );
      },
    );
  });

  group('method-channel client (FR-004)', () {
    test(
      'U7: checkPermissions invokes the shared channel with the scope list and returns the statuses',
      () async {
        final invocations = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MethodChannelZuraffaPermissions.channel, (
              call,
            ) async {
              invocations.add(call);
              return {kCameraScope: 'granted'};
            });
        final client = MethodChannelZuraffaPermissions();

        final statuses = await client.checkPermissions([
          kCameraScope,
          kPhotosScope,
        ]);

        expect(invocations, hasLength(1), reason: 'exactly one channel call');
        expect(invocations.single.method, 'checkPermissions');
        expect(invocations.single.arguments, [kCameraScope, kPhotosScope]);
        expect(statuses, {kCameraScope: 'granted'});
      },
    );

    test(
      'U8: requestPermissions invokes method requestPermissions and returns the statuses',
      () async {
        final invocations = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MethodChannelZuraffaPermissions.channel, (
              call,
            ) async {
              invocations.add(call);
              return {kCameraScope: 'denied'};
            });
        final client = MethodChannelZuraffaPermissions();

        final statuses = await client.requestPermissions([kCameraScope]);

        expect(invocations, hasLength(1), reason: 'exactly one channel call');
        expect(invocations.single.method, 'requestPermissions');
        expect(invocations.single.arguments, [kCameraScope]);
        expect(statuses, {kCameraScope: 'denied'});
      },
    );

    test(
      'U9: a null platform reply normalizes to an empty map — no crash',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              MethodChannelZuraffaPermissions.channel,
              (call) async => null,
            );
        final client = MethodChannelZuraffaPermissions();

        final statuses = await client.checkPermissions([kCameraScope]);

        expect(
          statuses,
          isEmpty,
          reason:
              'a null reply means no scopes reported — degrade, never throw',
        );
      },
    );

    test(
      'U10: non-string keys and values are stringified onto Map<String, String>',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MethodChannelZuraffaPermissions.channel, (
              call,
            ) async {
              return <Object?, Object?>{1: true};
            });
        final client = MethodChannelZuraffaPermissions();

        final statuses = await client.checkPermissions([kCameraScope]);

        expect(
          statuses,
          {'1': 'true'},
          reason:
              'the standard codec reply is Map<Object?, Object?> — normalization stringifies',
        );
        expect(
          statuses[kCameraScope],
          isNull,
          reason: 'int key 1 is not the camera scope',
        );
      },
    );

    test(
      'U11: openSettings returns the channel bool; null degrades to false',
      () async {
        final client = MethodChannelZuraffaPermissions();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              MethodChannelZuraffaPermissions.channel,
              (call) async => call.method == 'openSettings',
            );
        expect(await client.openSettings(), isTrue);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              MethodChannelZuraffaPermissions.channel,
              (call) async => null,
            );
        expect(
          await client.openSettings(),
          isFalse,
          reason: 'a null verdict means settings were not launched',
        );
      },
    );
  });

  group('adapter wire-to-enum bridge (FR-005, FR-006, FR-007)', () {
    test(
      'U12: check maps every known wire status onto the typed enum',
      () async {
        final scripted = _ScriptedPermissionsPlatform(
          checkReply: {
            kCameraScope: 'granted',
            kPhotosScope: 'denied',
            kMicrophoneScope: 'permanentlyDenied',
          },
        );
        final adapter = MethodChannelPermissionAdapter(platform: scripted);

        expect(await adapter.check(kCameraScope), PermissionStatus.granted);
        expect(await adapter.check(kPhotosScope), PermissionStatus.denied);
        expect(
          await adapter.check(kMicrophoneScope),
          PermissionStatus.permanentlyDenied,
        );
      },
    );

    test(
      'U13: check degrades unknown and missing wire values to undetermined',
      () async {
        final scripted = _ScriptedPermissionsPlatform(
          checkReply: {kCameraScope: 'brandNewFutureStatus'},
        );
        final adapter = MethodChannelPermissionAdapter(platform: scripted);

        expect(
          await adapter.check(kCameraScope),
          PermissionStatus.undetermined,
          reason:
              'an unknown wire value from a newer native SDK never crashes older apps',
        );
        expect(
          await adapter.check(kPhotosScope),
          PermissionStatus.undetermined,
          reason: 'a scope the reply omits has no verdict — undetermined',
        );
      },
    );

    test(
      'U14: request returns a result carrying scope, mapped status, and a real requestedAt',
      () async {
        final scripted = _ScriptedPermissionsPlatform(
          requestReply: {kCameraScope: 'granted'},
        );
        final adapter = MethodChannelPermissionAdapter(platform: scripted);
        final before = DateTime.now().millisecondsSinceEpoch;

        final result = await adapter.request(kCameraScope);

        expect(result.scope, kCameraScope);
        expect(result.status, PermissionStatus.granted);
        expect(
          result.requestedAt,
          greaterThanOrEqualTo(before),
          reason:
              'requestedAt is a real epoch-milliseconds timestamp, not zero',
        );
        expect(
          result.requestedAt,
          lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch + 5),
        );
      },
    );

    test(
      'U15: openSettings delegates to the platform and returns its verdict',
      () async {
        final launched = MethodChannelPermissionAdapter(
          platform: _ScriptedPermissionsPlatform(settingsLaunched: true),
        );
        final refused = MethodChannelPermissionAdapter(
          platform: _ScriptedPermissionsPlatform(settingsLaunched: false),
        );
        expect(await launched.openSettings(), isTrue);
        expect(await refused.openSettings(), isFalse);
      },
    );

    test(
      'U16: a constructor-supplied platform overrides the registered instance',
      () async {
        // The registered instance would answer undetermined; the injected
        // one answers granted — the injected seam must win.
        final adapter = MethodChannelPermissionAdapter(
          platform: _ScriptedPermissionsPlatform(
            checkReply: {kCameraScope: 'granted'},
          ),
        );
        expect(
          await adapter.check(kCameraScope),
          PermissionStatus.granted,
          reason: 'the injected platform is the one consulted',
        );
      },
    );

    test(
      'U17: without an override the adapter routes through the registered instance',
      () async {
        ZuraffaPermissionsPlatform.instance = _ScriptedPermissionsPlatform(
          checkReply: {kCameraScope: 'limited'},
        );
        final adapter = MethodChannelPermissionAdapter();

        expect(
          await adapter.check(kCameraScope),
          PermissionStatus.limited,
          reason: 'no injection — the registered instance is consulted',
        );
      },
    );
  });
}
