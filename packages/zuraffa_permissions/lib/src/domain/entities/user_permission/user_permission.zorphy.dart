// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'user_permission.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class UserPermission {
  UserPermission({
    required String this.userId,
    required String this.permissionId,
    required int this.grantedAt,
  });

  factory UserPermission.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionFromJson(json);

  final String userId;

  final String permissionId;

  final int grantedAt;

  UserPermission copyWith({
    String? userId,
    String? permissionId,
    int? grantedAt,
  }) {
    return UserPermission(
      userId: userId ?? this.userId,
      permissionId: permissionId ?? this.permissionId,
      grantedAt: grantedAt ?? this.grantedAt,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  UserPermission copyWithField<T>(Field<UserPermission, T> field, T value) {
    switch (field.name) {
      case 'userId':
        return copyWith(userId: value as String);
      case 'permissionId':
        return copyWith(permissionId: value as String);
      case 'grantedAt':
        return copyWith(grantedAt: value as int);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'UserPermission has no settable field with this name',
        );
    }
  }

  UserPermission copyWithUserPermission({
    String? userId,
    String? permissionId,
    int? grantedAt,
  }) {
    return copyWith(
      userId: userId,
      permissionId: permissionId,
      grantedAt: grantedAt,
    );
  }

  UserPermission patchWithUserPermission([UserPermissionPatch? patchInput]) {
    final _patcher = patchInput ?? UserPermissionPatch();
    final _patchMap = _patcher.patchMap;
    return UserPermission(
      userId: _patchMap.containsKey(UserPermission$.userId)
          ? ((_patchMap[UserPermission$.userId] is Function)
                    ? _patchMap[UserPermission$.userId](this.userId)
                    : (_patchMap[UserPermission$.userId] is Patch)
                    ? _patchMap[UserPermission$.userId].applyTo(this.userId)
                    : _patchMap[UserPermission$.userId])
                as String
          : this.userId,
      permissionId: _patchMap.containsKey(UserPermission$.permissionId)
          ? ((_patchMap[UserPermission$.permissionId] is Function)
                    ? _patchMap[UserPermission$.permissionId](this.permissionId)
                    : (_patchMap[UserPermission$.permissionId] is Patch)
                    ? _patchMap[UserPermission$.permissionId].applyTo(
                        this.permissionId,
                      )
                    : _patchMap[UserPermission$.permissionId])
                as String
          : this.permissionId,
      grantedAt: _patchMap.containsKey(UserPermission$.grantedAt)
          ? ((_patchMap[UserPermission$.grantedAt] is Function)
                    ? _patchMap[UserPermission$.grantedAt](this.grantedAt)
                    : (_patchMap[UserPermission$.grantedAt] is Patch)
                    ? _patchMap[UserPermission$.grantedAt].applyTo(
                        this.grantedAt,
                      )
                    : _patchMap[UserPermission$.grantedAt])
                as int
          : this.grantedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPermission &&
        userId == other.userId &&
        permissionId == other.permissionId &&
        grantedAt == other.grantedAt;
  }

  @override
  int get hashCode {
    return Object.hash(this.userId, this.permissionId, this.grantedAt);
  }

  @override
  String toString() {
    return 'UserPermission(' +
        'userId: ${userId}' +
        ', ' +
        'permissionId: ${permissionId}' +
        ', ' +
        'grantedAt: ${grantedAt})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$UserPermissionToJson(this);
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

extension UserPermissionPropertyHelpers on UserPermission {
  bool get hasUserId {
    return this.userId.isNotEmpty;
  }

  bool get noUserId {
    return this.userId.isEmpty;
  }

  bool get hasPermissionId {
    return this.permissionId.isNotEmpty;
  }

  bool get noPermissionId {
    return this.permissionId.isEmpty;
  }
}

extension UserPermissionSerialization on UserPermission {
  Map<String, dynamic> toJson() {
    return _$UserPermissionToJson(this);
  }
}

enum UserPermission$ { userId, permissionId, grantedAt }

class UserPermissionPatch extends PatchBase<UserPermission, UserPermission$> {
  UserPermission applyTo(UserPermission entity) {
    return entity.patchWithUserPermission(this);
  }

  UserPermissionPatch withUserId(String? value) {
    patchMap[UserPermission$.userId] = value;
    return this;
  }

  UserPermissionPatch withPermissionId(String? value) {
    patchMap[UserPermission$.permissionId] = value;
    return this;
  }

  UserPermissionPatch withGrantedAt(int? value) {
    patchMap[UserPermission$.grantedAt] = value;
    return this;
  }
}

/// Field descriptors for [UserPermission] query construction
abstract final class UserPermissionFields {
  static const userId = Field<UserPermission, String>('userId', _$userId);

  static const permissionId = Field<UserPermission, String>(
    'permissionId',
    _$permissionId,
  );

  static const grantedAt = Field<UserPermission, int>('grantedAt', _$grantedAt);

  static String _$userId(UserPermission e) {
    return e.userId;
  }

  static String _$permissionId(UserPermission e) {
    return e.permissionId;
  }

  static int _$grantedAt(UserPermission e) {
    return e.grantedAt;
  }
}

extension UserPermissionCompareE on UserPermission {
  Map<String, dynamic> compareToUserPermission(UserPermission other) {
    final Map<String, dynamic> diff = {};

    if (userId != other.userId) {
      diff['userId'] = () => other.userId;
    }

    if (permissionId != other.permissionId) {
      diff['permissionId'] = () => other.permissionId;
    }

    if (grantedAt != other.grantedAt) {
      diff['grantedAt'] = () => other.grantedAt;
    }
    return diff;
  }
}
