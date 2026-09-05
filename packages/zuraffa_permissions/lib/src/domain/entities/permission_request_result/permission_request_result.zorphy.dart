// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'permission_request_result.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class PermissionRequestResult {
  PermissionRequestResult({
    required String this.scope,
    required PermissionStatus this.status,
    required int this.requestedAt,
  });

  factory PermissionRequestResult.fromJson(Map<String, dynamic> json) =>
      _$PermissionRequestResultFromJson(json);

  final String scope;

  final PermissionStatus status;

  final int requestedAt;

  PermissionRequestResult copyWith({
    String? scope,
    PermissionStatus? status,
    int? requestedAt,
  }) {
    return PermissionRequestResult(
      scope: scope ?? this.scope,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  PermissionRequestResult copyWithField<T>(
    Field<PermissionRequestResult, T> field,
    T value,
  ) {
    switch (field.name) {
      case 'scope':
        return copyWith(scope: value as String);
      case 'status':
        return copyWith(status: value as PermissionStatus);
      case 'requestedAt':
        return copyWith(requestedAt: value as int);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'PermissionRequestResult has no settable field with this name',
        );
    }
  }

  PermissionRequestResult copyWithPermissionRequestResult({
    String? scope,
    PermissionStatus? status,
    int? requestedAt,
  }) {
    return copyWith(scope: scope, status: status, requestedAt: requestedAt);
  }

  PermissionRequestResult patchWithPermissionRequestResult([
    PermissionRequestResultPatch? patchInput,
  ]) {
    final _patcher = patchInput ?? PermissionRequestResultPatch();
    final _patchMap = _patcher.patchMap;
    return PermissionRequestResult(
      scope: _patchMap.containsKey(PermissionRequestResult$.scope)
          ? ((_patchMap[PermissionRequestResult$.scope] is Function)
                    ? _patchMap[PermissionRequestResult$.scope](this.scope)
                    : (_patchMap[PermissionRequestResult$.scope] is Patch)
                    ? _patchMap[PermissionRequestResult$.scope].applyTo(
                        this.scope,
                      )
                    : _patchMap[PermissionRequestResult$.scope])
                as String
          : this.scope,
      status: _patchMap.containsKey(PermissionRequestResult$.status)
          ? ((_patchMap[PermissionRequestResult$.status] is Function)
                    ? _patchMap[PermissionRequestResult$.status](this.status)
                    : (_patchMap[PermissionRequestResult$.status] is Patch)
                    ? _patchMap[PermissionRequestResult$.status].applyTo(
                        this.status,
                      )
                    : _patchMap[PermissionRequestResult$.status])
                as PermissionStatus
          : this.status,
      requestedAt: _patchMap.containsKey(PermissionRequestResult$.requestedAt)
          ? ((_patchMap[PermissionRequestResult$.requestedAt] is Function)
                    ? _patchMap[PermissionRequestResult$.requestedAt](
                        this.requestedAt,
                      )
                    : (_patchMap[PermissionRequestResult$.requestedAt] is Patch)
                    ? _patchMap[PermissionRequestResult$.requestedAt].applyTo(
                        this.requestedAt,
                      )
                    : _patchMap[PermissionRequestResult$.requestedAt])
                as int
          : this.requestedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PermissionRequestResult &&
        scope == other.scope &&
        status == other.status &&
        requestedAt == other.requestedAt;
  }

  @override
  int get hashCode {
    return Object.hash(this.scope, this.status, this.requestedAt);
  }

  @override
  String toString() {
    return 'PermissionRequestResult(' +
        'scope: ${scope}' +
        ', ' +
        'status: ${status}' +
        ', ' +
        'requestedAt: ${requestedAt})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$PermissionRequestResultToJson(this);
    _sanitizeJson(data);
    return data;
  }

  dynamic _sanitizeJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      json.remove('__typename');
      return json..forEach((key, value) {
        json[key] = _sanitizeJson(value);
      });
    } else if (json is List) {
      return json.map((e) => _sanitizeJson(e)).toList();
    }
    return json;
  }
}

extension PermissionRequestResultPropertyHelpers on PermissionRequestResult {
  bool get hasScope {
    return this.scope.isNotEmpty;
  }

  bool get noScope {
    return this.scope.isEmpty;
  }

  bool get isStatusGranted {
    return this.status == PermissionStatus.granted;
  }

  bool get isStatusDenied {
    return this.status == PermissionStatus.denied;
  }

  bool get isStatusPermanentlyDenied {
    return this.status == PermissionStatus.permanentlyDenied;
  }

  bool get isStatusUndetermined {
    return this.status == PermissionStatus.undetermined;
  }

  bool get isStatusRestricted {
    return this.status == PermissionStatus.restricted;
  }

  bool get isStatusLimited {
    return this.status == PermissionStatus.limited;
  }
}

extension PermissionRequestResultSerialization on PermissionRequestResult {
  Map<String, dynamic> toJson() {
    return _$PermissionRequestResultToJson(this);
  }
}

enum PermissionRequestResult$ { scope, status, requestedAt }

class PermissionRequestResultPatch
    extends PatchBase<PermissionRequestResult, PermissionRequestResult$> {
  PermissionRequestResult applyTo(PermissionRequestResult entity) {
    return entity.patchWithPermissionRequestResult(this);
  }

  PermissionRequestResultPatch withScope(String? value) {
    patchMap[PermissionRequestResult$.scope] = value;
    return this;
  }

  PermissionRequestResultPatch withStatus(PermissionStatus? value) {
    patchMap[PermissionRequestResult$.status] = value;
    return this;
  }

  PermissionRequestResultPatch withRequestedAt(int? value) {
    patchMap[PermissionRequestResult$.requestedAt] = value;
    return this;
  }
}

/// Field descriptors for [PermissionRequestResult] query construction
abstract final class PermissionRequestResultFields {
  static const scope = Field<PermissionRequestResult, String>('scope', _$scope);

  static const status = Field<PermissionRequestResult, PermissionStatus>(
    'status',
    _$status,
  );

  static const requestedAt = Field<PermissionRequestResult, int>(
    'requestedAt',
    _$requestedAt,
  );

  static String _$scope(PermissionRequestResult e) {
    return e.scope;
  }

  static PermissionStatus _$status(PermissionRequestResult e) {
    return e.status;
  }

  static int _$requestedAt(PermissionRequestResult e) {
    return e.requestedAt;
  }
}

extension PermissionRequestResultCompareE on PermissionRequestResult {
  Map<String, dynamic> compareToPermissionRequestResult(
    PermissionRequestResult other,
  ) {
    final Map<String, dynamic> diff = {};

    if (scope != other.scope) {
      diff['scope'] = () => other.scope;
    }

    if (status != other.status) {
      diff['status'] = () => other.status;
    }

    if (requestedAt != other.requestedAt) {
      diff['requestedAt'] = () => other.requestedAt;
    }
    return diff;
  }
}
