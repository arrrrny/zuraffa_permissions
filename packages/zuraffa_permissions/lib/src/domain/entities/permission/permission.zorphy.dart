// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'permission.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class Permission {
  Permission({
    required String this.id,
    required String this.name,
    required String this.description,
    required String this.scopeId,
  });

  factory Permission.fromJson(Map<String, dynamic> json) =>
      _$PermissionFromJson(json);

  final String id;

  final String name;

  final String description;

  final String scopeId;

  Permission copyWith({
    String? id,
    String? name,
    String? description,
    String? scopeId,
  }) {
    return Permission(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      scopeId: scopeId ?? this.scopeId,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  Permission copyWithField<T>(Field<Permission, T> field, T value) {
    switch (field.name) {
      case 'id':
        return copyWith(id: value as String);
      case 'name':
        return copyWith(name: value as String);
      case 'description':
        return copyWith(description: value as String);
      case 'scopeId':
        return copyWith(scopeId: value as String);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'Permission has no settable field with this name',
        );
    }
  }

  Permission copyWithPermission({
    String? id,
    String? name,
    String? description,
    String? scopeId,
  }) {
    return copyWith(
      id: id,
      name: name,
      description: description,
      scopeId: scopeId,
    );
  }

  Permission patchWithPermission([PermissionPatch? patchInput]) {
    final _patcher = patchInput ?? PermissionPatch();
    final _patchMap = _patcher.patchMap;
    return Permission(
      id: _patchMap.containsKey(Permission$.id)
          ? ((_patchMap[Permission$.id] is Function)
                    ? _patchMap[Permission$.id](this.id)
                    : (_patchMap[Permission$.id] is Patch)
                    ? _patchMap[Permission$.id].applyTo(this.id)
                    : _patchMap[Permission$.id])
                as String
          : this.id,
      name: _patchMap.containsKey(Permission$.name_)
          ? ((_patchMap[Permission$.name_] is Function)
                    ? _patchMap[Permission$.name_](this.name)
                    : (_patchMap[Permission$.name_] is Patch)
                    ? _patchMap[Permission$.name_].applyTo(this.name)
                    : _patchMap[Permission$.name_])
                as String
          : this.name,
      description: _patchMap.containsKey(Permission$.description)
          ? ((_patchMap[Permission$.description] is Function)
                    ? _patchMap[Permission$.description](this.description)
                    : (_patchMap[Permission$.description] is Patch)
                    ? _patchMap[Permission$.description].applyTo(
                        this.description,
                      )
                    : _patchMap[Permission$.description])
                as String
          : this.description,
      scopeId: _patchMap.containsKey(Permission$.scopeId)
          ? ((_patchMap[Permission$.scopeId] is Function)
                    ? _patchMap[Permission$.scopeId](this.scopeId)
                    : (_patchMap[Permission$.scopeId] is Patch)
                    ? _patchMap[Permission$.scopeId].applyTo(this.scopeId)
                    : _patchMap[Permission$.scopeId])
                as String
          : this.scopeId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        scopeId == other.scopeId;
  }

  @override
  int get hashCode {
    return Object.hash(this.id, this.name, this.description, this.scopeId);
  }

  @override
  String toString() {
    return 'Permission(' +
        'id: ${id}' +
        ', ' +
        'name: ${name}' +
        ', ' +
        'description: ${description}' +
        ', ' +
        'scopeId: ${scopeId})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$PermissionToJson(this);
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

extension PermissionPropertyHelpers on Permission {
  bool get hasId {
    return this.id.isNotEmpty;
  }

  bool get noId {
    return this.id.isEmpty;
  }

  bool get hasName {
    return this.name.isNotEmpty;
  }

  bool get noName {
    return this.name.isEmpty;
  }

  bool get hasDescription {
    return this.description.isNotEmpty;
  }

  bool get noDescription {
    return this.description.isEmpty;
  }

  bool get hasScopeId {
    return this.scopeId.isNotEmpty;
  }

  bool get noScopeId {
    return this.scopeId.isEmpty;
  }
}

extension PermissionSerialization on Permission {
  Map<String, dynamic> toJson() {
    return _$PermissionToJson(this);
  }
}

enum Permission$ { id, name_, description, scopeId }

class PermissionPatch extends PatchBase<Permission, Permission$> {
  Permission applyTo(Permission entity) {
    return entity.patchWithPermission(this);
  }

  PermissionPatch withId(String? value) {
    patchMap[Permission$.id] = value;
    return this;
  }

  PermissionPatch withName(String? value) {
    patchMap[Permission$.name_] = value;
    return this;
  }

  PermissionPatch withDescription(String? value) {
    patchMap[Permission$.description] = value;
    return this;
  }

  PermissionPatch withScopeId(String? value) {
    patchMap[Permission$.scopeId] = value;
    return this;
  }
}

/// Field descriptors for [Permission] query construction
abstract final class PermissionFields {
  static const id = Field<Permission, String>('id', _$id);

  static const name = Field<Permission, String>('name', _$name);

  static const description = Field<Permission, String>(
    'description',
    _$description,
  );

  static const scopeId = Field<Permission, String>('scopeId', _$scopeId);

  static String _$id(Permission e) {
    return e.id;
  }

  static String _$name(Permission e) {
    return e.name;
  }

  static String _$description(Permission e) {
    return e.description;
  }

  static String _$scopeId(Permission e) {
    return e.scopeId;
  }
}

extension PermissionCompareE on Permission {
  Map<String, dynamic> compareToPermission(Permission other) {
    final Map<String, dynamic> diff = {};

    if (id != other.id) {
      diff['id'] = () => other.id;
    }

    if (name != other.name) {
      diff['name'] = () => other.name;
    }

    if (description != other.description) {
      diff['description'] = () => other.description;
    }

    if (scopeId != other.scopeId) {
      diff['scopeId'] = () => other.scopeId;
    }
    return diff;
  }
}
