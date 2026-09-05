// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_request_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PermissionRequestResult _$PermissionRequestResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PermissionRequestResult', json, ($checkedConvert) {
  final val = PermissionRequestResult(
    scope: $checkedConvert('scope', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$PermissionStatusEnumMap, v),
    ),
    requestedAt: $checkedConvert('requestedAt', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$PermissionRequestResultToJson(
  PermissionRequestResult instance,
) => <String, dynamic>{
  'scope': instance.scope,
  'status': _$PermissionStatusEnumMap[instance.status]!,
  'requestedAt': instance.requestedAt,
};

const _$PermissionStatusEnumMap = {
  PermissionStatus.granted: 'granted',
  PermissionStatus.denied: 'denied',
  PermissionStatus.permanentlyDenied: 'permanentlyDenied',
  PermissionStatus.undetermined: 'undetermined',
  PermissionStatus.restricted: 'restricted',
  PermissionStatus.limited: 'limited',
};
