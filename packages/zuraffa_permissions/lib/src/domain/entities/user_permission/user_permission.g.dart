// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_permission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPermission _$UserPermissionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserPermission', json, ($checkedConvert) {
      final val = UserPermission(
        userId: $checkedConvert('userId', (v) => v as String),
        permissionId: $checkedConvert('permissionId', (v) => v as String),
        grantedAt: $checkedConvert('grantedAt', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$UserPermissionToJson(UserPermission instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'permissionId': instance.permissionId,
      'grantedAt': instance.grantedAt,
    };
