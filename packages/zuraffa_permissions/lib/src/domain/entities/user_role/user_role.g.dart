// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRole _$UserRoleFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserRole', json, ($checkedConvert) {
      final val = UserRole(
        userId: $checkedConvert('userId', (v) => v as String),
        roleId: $checkedConvert('roleId', (v) => v as String),
        assignedAt: $checkedConvert('assignedAt', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
  'userId': instance.userId,
  'roleId': instance.roleId,
  'assignedAt': instance.assignedAt,
};
