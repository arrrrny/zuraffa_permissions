// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'user_role.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class UserRole {
  UserRole({
    required String this.userId,
    required String this.roleId,
    required int this.assignedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      _$UserRoleFromJson(json);

  final String userId;

  final String roleId;

  final int assignedAt;

  UserRole copyWith({String? userId, String? roleId, int? assignedAt}) {
    return UserRole(
      userId: userId ?? this.userId,
      roleId: roleId ?? this.roleId,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  UserRole copyWithField<T>(Field<UserRole, T> field, T value) {
    switch (field.name) {
      case 'userId':
        return copyWith(userId: value as String);
      case 'roleId':
        return copyWith(roleId: value as String);
      case 'assignedAt':
        return copyWith(assignedAt: value as int);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'UserRole has no settable field with this name',
        );
    }
  }

  UserRole copyWithUserRole({String? userId, String? roleId, int? assignedAt}) {
    return copyWith(userId: userId, roleId: roleId, assignedAt: assignedAt);
  }

  UserRole patchWithUserRole([UserRolePatch? patchInput]) {
    final _patcher = patchInput ?? UserRolePatch();
    final _patchMap = _patcher.patchMap;
    return UserRole(
      userId: _patchMap.containsKey(UserRole$.userId)
          ? ((_patchMap[UserRole$.userId] is Function)
                    ? _patchMap[UserRole$.userId](this.userId)
                    : (_patchMap[UserRole$.userId] is Patch)
                    ? _patchMap[UserRole$.userId].applyTo(this.userId)
                    : _patchMap[UserRole$.userId])
                as String
          : this.userId,
      roleId: _patchMap.containsKey(UserRole$.roleId)
          ? ((_patchMap[UserRole$.roleId] is Function)
                    ? _patchMap[UserRole$.roleId](this.roleId)
                    : (_patchMap[UserRole$.roleId] is Patch)
                    ? _patchMap[UserRole$.roleId].applyTo(this.roleId)
                    : _patchMap[UserRole$.roleId])
                as String
          : this.roleId,
      assignedAt: _patchMap.containsKey(UserRole$.assignedAt)
          ? ((_patchMap[UserRole$.assignedAt] is Function)
                    ? _patchMap[UserRole$.assignedAt](this.assignedAt)
                    : (_patchMap[UserRole$.assignedAt] is Patch)
                    ? _patchMap[UserRole$.assignedAt].applyTo(this.assignedAt)
                    : _patchMap[UserRole$.assignedAt])
                as int
          : this.assignedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserRole &&
        userId == other.userId &&
        roleId == other.roleId &&
        assignedAt == other.assignedAt;
  }

  @override
  int get hashCode {
    return Object.hash(this.userId, this.roleId, this.assignedAt);
  }

  @override
  String toString() {
    return 'UserRole(' +
        'userId: ${userId}' +
        ', ' +
        'roleId: ${roleId}' +
        ', ' +
        'assignedAt: ${assignedAt})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$UserRoleToJson(this);
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

extension UserRolePropertyHelpers on UserRole {
  bool get hasUserId {
    return this.userId.isNotEmpty;
  }

  bool get noUserId {
    return this.userId.isEmpty;
  }

  bool get hasRoleId {
    return this.roleId.isNotEmpty;
  }

  bool get noRoleId {
    return this.roleId.isEmpty;
  }
}

extension UserRoleSerialization on UserRole {
  Map<String, dynamic> toJson() {
    return _$UserRoleToJson(this);
  }
}

enum UserRole$ { userId, roleId, assignedAt }

class UserRolePatch extends PatchBase<UserRole, UserRole$> {
  UserRole applyTo(UserRole entity) {
    return entity.patchWithUserRole(this);
  }

  UserRolePatch withUserId(String? value) {
    patchMap[UserRole$.userId] = value;
    return this;
  }

  UserRolePatch withRoleId(String? value) {
    patchMap[UserRole$.roleId] = value;
    return this;
  }

  UserRolePatch withAssignedAt(int? value) {
    patchMap[UserRole$.assignedAt] = value;
    return this;
  }
}

/// Field descriptors for [UserRole] query construction
abstract final class UserRoleFields {
  static const userId = Field<UserRole, String>('userId', _$userId);

  static const roleId = Field<UserRole, String>('roleId', _$roleId);

  static const assignedAt = Field<UserRole, int>('assignedAt', _$assignedAt);

  static String _$userId(UserRole e) {
    return e.userId;
  }

  static String _$roleId(UserRole e) {
    return e.roleId;
  }

  static int _$assignedAt(UserRole e) {
    return e.assignedAt;
  }
}

extension UserRoleCompareE on UserRole {
  Map<String, dynamic> compareToUserRole(UserRole other) {
    final Map<String, dynamic> diff = {};

    if (userId != other.userId) {
      diff['userId'] = () => other.userId;
    }

    if (roleId != other.roleId) {
      diff['roleId'] = () => other.roleId;
    }

    if (assignedAt != other.assignedAt) {
      diff['assignedAt'] = () => other.assignedAt;
    }
    return diff;
  }
}
