// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'role_permission.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class RolePermission {
  RolePermission({
    required String this.roleId,
    required String this.permissionId,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) =>
      _$RolePermissionFromJson(json);

  final String roleId;

  final String permissionId;

  RolePermission copyWith({String? roleId, String? permissionId}) {
    return RolePermission(
      roleId: roleId ?? this.roleId,
      permissionId: permissionId ?? this.permissionId,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  RolePermission copyWithField<T>(Field<RolePermission, T> field, T value) {
    switch (field.name) {
      case 'roleId':
        return copyWith(roleId: value as String);
      case 'permissionId':
        return copyWith(permissionId: value as String);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'RolePermission has no settable field with this name',
        );
    }
  }

  RolePermission copyWithRolePermission({
    String? roleId,
    String? permissionId,
  }) {
    return copyWith(roleId: roleId, permissionId: permissionId);
  }

  RolePermission patchWithRolePermission([RolePermissionPatch? patchInput]) {
    final _patcher = patchInput ?? RolePermissionPatch();
    final _patchMap = _patcher.patchMap;
    return RolePermission(
      roleId: _patchMap.containsKey(RolePermission$.roleId)
          ? ((_patchMap[RolePermission$.roleId] is Function)
                    ? _patchMap[RolePermission$.roleId](this.roleId)
                    : (_patchMap[RolePermission$.roleId] is Patch)
                    ? _patchMap[RolePermission$.roleId].applyTo(this.roleId)
                    : _patchMap[RolePermission$.roleId])
                as String
          : this.roleId,
      permissionId: _patchMap.containsKey(RolePermission$.permissionId)
          ? ((_patchMap[RolePermission$.permissionId] is Function)
                    ? _patchMap[RolePermission$.permissionId](this.permissionId)
                    : (_patchMap[RolePermission$.permissionId] is Patch)
                    ? _patchMap[RolePermission$.permissionId].applyTo(
                        this.permissionId,
                      )
                    : _patchMap[RolePermission$.permissionId])
                as String
          : this.permissionId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RolePermission &&
        roleId == other.roleId &&
        permissionId == other.permissionId;
  }

  @override
  int get hashCode {
    return Object.hash(this.roleId, this.permissionId);
  }

  @override
  String toString() {
    return 'RolePermission(' +
        'roleId: ${roleId}' +
        ', ' +
        'permissionId: ${permissionId})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$RolePermissionToJson(this);
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

extension RolePermissionPropertyHelpers on RolePermission {
  bool get hasRoleId {
    return this.roleId.isNotEmpty;
  }

  bool get noRoleId {
    return this.roleId.isEmpty;
  }

  bool get hasPermissionId {
    return this.permissionId.isNotEmpty;
  }

  bool get noPermissionId {
    return this.permissionId.isEmpty;
  }
}

extension RolePermissionSerialization on RolePermission {
  Map<String, dynamic> toJson() {
    return _$RolePermissionToJson(this);
  }
}

enum RolePermission$ { roleId, permissionId }

class RolePermissionPatch extends PatchBase<RolePermission, RolePermission$> {
  RolePermission applyTo(RolePermission entity) {
    return entity.patchWithRolePermission(this);
  }

  RolePermissionPatch withRoleId(String? value) {
    patchMap[RolePermission$.roleId] = value;
    return this;
  }

  RolePermissionPatch withPermissionId(String? value) {
    patchMap[RolePermission$.permissionId] = value;
    return this;
  }
}

/// Field descriptors for [RolePermission] query construction
abstract final class RolePermissionFields {
  static const roleId = Field<RolePermission, String>('roleId', _$roleId);

  static const permissionId = Field<RolePermission, String>(
    'permissionId',
    _$permissionId,
  );

  static String _$roleId(RolePermission e) {
    return e.roleId;
  }

  static String _$permissionId(RolePermission e) {
    return e.permissionId;
  }
}

extension RolePermissionCompareE on RolePermission {
  Map<String, dynamic> compareToRolePermission(RolePermission other) {
    final Map<String, dynamic> diff = {};

    if (roleId != other.roleId) {
      diff['roleId'] = () => other.roleId;
    }

    if (permissionId != other.permissionId) {
      diff['permissionId'] = () => other.permissionId;
    }
    return diff;
  }
}
