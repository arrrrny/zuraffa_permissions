// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'role.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class Role {
  Role({
    required String this.id,
    required String this.name,
    required String this.description,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  final String id;

  final String name;

  final String description;

  Role copyWith({String? id, String? name, String? description}) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  Role copyWithField<T>(Field<Role, T> field, T value) {
    switch (field.name) {
      case 'id':
        return copyWith(id: value as String);
      case 'name':
        return copyWith(name: value as String);
      case 'description':
        return copyWith(description: value as String);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'Role has no settable field with this name',
        );
    }
  }

  Role copyWithRole({String? id, String? name, String? description}) {
    return copyWith(id: id, name: name, description: description);
  }

  Role patchWithRole([RolePatch? patchInput]) {
    final _patcher = patchInput ?? RolePatch();
    final _patchMap = _patcher.patchMap;
    return Role(
      id: _patchMap.containsKey(Role$.id)
          ? ((_patchMap[Role$.id] is Function)
                    ? _patchMap[Role$.id](this.id)
                    : (_patchMap[Role$.id] is Patch)
                    ? _patchMap[Role$.id].applyTo(this.id)
                    : _patchMap[Role$.id])
                as String
          : this.id,
      name: _patchMap.containsKey(Role$.name_)
          ? ((_patchMap[Role$.name_] is Function)
                    ? _patchMap[Role$.name_](this.name)
                    : (_patchMap[Role$.name_] is Patch)
                    ? _patchMap[Role$.name_].applyTo(this.name)
                    : _patchMap[Role$.name_])
                as String
          : this.name,
      description: _patchMap.containsKey(Role$.description)
          ? ((_patchMap[Role$.description] is Function)
                    ? _patchMap[Role$.description](this.description)
                    : (_patchMap[Role$.description] is Patch)
                    ? _patchMap[Role$.description].applyTo(this.description)
                    : _patchMap[Role$.description])
                as String
          : this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role &&
        id == other.id &&
        name == other.name &&
        description == other.description;
  }

  @override
  int get hashCode {
    return Object.hash(this.id, this.name, this.description);
  }

  @override
  String toString() {
    return 'Role(' +
        'id: ${id}' +
        ', ' +
        'name: ${name}' +
        ', ' +
        'description: ${description})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$RoleToJson(this);
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

extension RolePropertyHelpers on Role {
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
}

extension RoleSerialization on Role {
  Map<String, dynamic> toJson() {
    return _$RoleToJson(this);
  }
}

enum Role$ { id, name_, description }

class RolePatch extends PatchBase<Role, Role$> {
  Role applyTo(Role entity) {
    return entity.patchWithRole(this);
  }

  RolePatch withId(String? value) {
    patchMap[Role$.id] = value;
    return this;
  }

  RolePatch withName(String? value) {
    patchMap[Role$.name_] = value;
    return this;
  }

  RolePatch withDescription(String? value) {
    patchMap[Role$.description] = value;
    return this;
  }
}

/// Field descriptors for [Role] query construction
abstract final class RoleFields {
  static const id = Field<Role, String>('id', _$id);

  static const name = Field<Role, String>('name', _$name);

  static const description = Field<Role, String>('description', _$description);

  static String _$id(Role e) {
    return e.id;
  }

  static String _$name(Role e) {
    return e.name;
  }

  static String _$description(Role e) {
    return e.description;
  }
}

extension RoleCompareE on Role {
  Map<String, dynamic> compareToRole(Role other) {
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
    return diff;
  }
}
