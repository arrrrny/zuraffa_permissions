// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_scope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PermissionScope _$PermissionScopeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PermissionScope', json, ($checkedConvert) {
      final val = PermissionScope(
        name: $checkedConvert('name', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        platformGroup: $checkedConvert('platformGroup', (v) => v as String),
        id: $checkedConvert('id', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$PermissionScopeToJson(PermissionScope instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'platformGroup': instance.platformGroup,
      'id': instance.id,
    };
