import 'package:zuraffa/zuraffa.dart';

import 'data/permission/in_memory_permission_adapter.dart';
import 'domain/entities/enums/permission_status.dart';
import 'domain/entities/permission_request_result/permission_request_result.dart';
import 'domain/entities/permission_scope/permission_scope.dart';
import 'domain/entities/scopes/built_in_permission_scopes.dart';

import 'data/datasources/permission_scope/permission_scope_remote_datasource.dart';
import 'data/repositories/data_permission_scope_repository.dart';
import 'di/index.dart';
import 'domain/permission/permission_port.dart';
import 'domain/repositories/permission_scope_repository.dart';

export 'domain/permission/permission_port.dart';

/// Registry of known permission scopes: the ten built-ins plus any custom
/// scopes applications register (FR-004) — the SessionPresetRegistry
/// pattern applied to permissions.
class PermissionScopeRegistry {
  final Map<String, PermissionScope> _scopes = {};

  PermissionScopeRegistry({Iterable<PermissionScope> additional = const []}) {
    for (final scope in BuiltInPermissionScopes.all) {
      _scopes[scope.id] = scope;
    }
    for (final scope in additional) {
      register(scope);
    }
  }

  /// A registry with only the built-in scopes.
  factory PermissionScopeRegistry.withBuiltIns() => PermissionScopeRegistry();

  /// Registers a custom scope; duplicate ids are rejected with a typed
  /// [ZuraffaPlatformException]-style error so one domain cannot silently
  /// shadow another's scope.
  void register(PermissionScope scope) {
    if (_scopes.containsKey(scope.id)) {
      throw ZuraffaPlatformException(
        code: 'duplicate_scope',
        message: 'A permission scope "${scope.id}" is already registered.',
      );
    }
    _scopes[scope.id] = scope;
  }

  /// Looks up a scope by id, or `null` when unknown.
  PermissionScope? lookup(String id) => _scopes[id];

  /// Whether [id] is a registered scope.
  bool contains(String id) => _scopes.containsKey(id);

  /// All registered scopes.
  Iterable<PermissionScope> get all => List.unmodifiable(_scopes.values);
}

/// The app-facing permission service: the port plus scope discovery.
///
/// ```dart
/// final permissions = PermissionService(
///   port: InMemoryPermissionAdapter(),
/// );
/// final status = await permissions.request('camera');
/// ```
class PermissionService {
  /// The platform adapter (or the in-memory default in tests).
  final PermissionPort port;

  /// Registry consulted for scope metadata.
  final PermissionScopeRegistry registry;

  PermissionService({PermissionPort? port, PermissionScopeRegistry? registry})
    : port = port ?? InMemoryPermissionAdapter(),
      registry = registry ?? PermissionScopeRegistry.withBuiltIns();

  /// Current status of [scopeId] without prompting.
  Future<PermissionStatus> check(String scopeId) => port.check(scopeId);

  /// Requests [scopeId]; an unknown scope is a typed error (a typo in
  /// your own scope wiring should fail fast, not silently "succeed").
  Future<PermissionRequestResult> request(String scopeId) {
    if (!registry.contains(scopeId)) {
      throw ZuraffaPlatformException(
        code: 'unknown_scope',
        message: 'No permission scope registered under "$scopeId".',
      );
    }
    return port.request(scopeId);
  }

  /// Opens OS settings; returns whether it could be launched.
  Future<bool> openSettings() => port.openSettings();

  /// All registered scopes (built-ins + customs).
  Iterable<PermissionScope> get scopes => registry.all;
}

/// Optional factory installed by a federated platform package so apps get
/// real OS permissions without wiring the adapter by hand.
///
/// `zuraffa_permissions_android` / `_ios` / `_macos` call
/// [setPlatformPermissionPortFactory] from their `registerWith()` (which Flutter
/// runs when the app starts). Until one does, the package stays pure Dart and
/// defaults to [InMemoryPermissionAdapter] — so it tests without a platform
/// (FR-006) and consumers can still inject a custom [PermissionPort].
PermissionPort? Function()? _platformPortFactory;

/// Called by a platform package at registration time to supply the real
/// [PermissionPort] (bridged onto its native [ZuraffaPermissionsPlatform]).
void setPlatformPermissionPortFactory(PermissionPort Function() factory) {
  _platformPortFactory = factory;
}

/// The default [PermissionPort] when the caller injects none: the platform
/// package's real adapter if one registered, otherwise the in-memory default.
PermissionPort _defaultPermissionPort() =>
    _platformPortFactory?.call() ?? InMemoryPermissionAdapter();

/// Registers the permission stack onto [getIt] (FR-007).
///
/// ```dart
/// final getIt = GetIt.instance;
/// registerPermissionDependencies(getIt);
/// final permissions = getIt<PermissionService>();
/// ```
void registerPermissionDependencies(
  GetIt getIt, {
  PermissionPort? port,
  PermissionScopeRegistry? registry,
}) {
  getIt
    ..registerLazySingleton<PermissionPort>(
      () => port ?? _defaultPermissionPort(),
    )
    ..registerLazySingleton<PermissionScopeRegistry>(
      () => registry ?? PermissionScopeRegistry.withBuiltIns(),
    )
    ..registerLazySingleton<PermissionService>(
      () => PermissionService(
        port: getIt<PermissionPort>(),
        registry: getIt<PermissionScopeRegistry>(),
      ),
    )
    // FR-007: also wire the permission-scope use cases and their repository.
    ..registerLazySingleton<PermissionScopeRepository>(
      () => DataPermissionScopeRepository(getIt<PermissionScopeRemoteDataSource>()),
    );
  setupDependencies(getIt);
}
