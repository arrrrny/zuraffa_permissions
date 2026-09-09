// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_permission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RolePermission _$RolePermissionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RolePermission', json, ($checkedConvert) {
      final val = RolePermission(
        roleId: $checkedConvert('roleId', (v) => v as String),
        permissionId: $checkedConvert('permissionId', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RolePermissionToJson(RolePermission instance) =>
    <String, dynamic>{
      'roleId': instance.roleId,
      'permissionId': instance.permissionId,
    };
