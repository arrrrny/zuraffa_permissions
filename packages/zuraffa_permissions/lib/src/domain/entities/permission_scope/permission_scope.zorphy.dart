// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'permission_scope.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class PermissionScope {
  PermissionScope({
    required String this.name,
    required String this.description,
    required String this.platformGroup,
    required String this.id,
  });

  factory PermissionScope.fromJson(Map<String, dynamic> json) =>
      _$PermissionScopeFromJson(json);

  final String name;

  final String description;

  final String platformGroup;

  final String id;

  PermissionScope copyWith({
    String? name,
    String? description,
    String? platformGroup,
    String? id,
  }) {
    return PermissionScope(
      name: name ?? this.name,
      description: description ?? this.description,
      platformGroup: platformGroup ?? this.platformGroup,
      id: id ?? this.id,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  PermissionScope copyWithField<T>(Field<PermissionScope, T> field, T value) {
    switch (field.name) {
      case 'name':
        return copyWith(name: value as String);
      case 'description':
        return copyWith(description: value as String);
      case 'platformGroup':
        return copyWith(platformGroup: value as String);
      case 'id':
        return copyWith(id: value as String);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'PermissionScope has no settable field with this name',
        );
    }
  }

  PermissionScope copyWithPermissionScope({
    String? name,
    String? description,
    String? platformGroup,
    String? id,
  }) {
    return copyWith(
      name: name,
      description: description,
      platformGroup: platformGroup,
      id: id,
    );
  }

  PermissionScope patchWithPermissionScope([PermissionScopePatch? patchInput]) {
    final _patcher = patchInput ?? PermissionScopePatch();
    final _patchMap = _patcher.patchMap;
    return PermissionScope(
      name: _patchMap.containsKey(PermissionScope$.name_)
          ? ((_patchMap[PermissionScope$.name_] is Function)
                    ? _patchMap[PermissionScope$.name_](this.name)
                    : (_patchMap[PermissionScope$.name_] is Patch)
                    ? _patchMap[PermissionScope$.name_].applyTo(this.name)
                    : _patchMap[PermissionScope$.name_])
                as String
          : this.name,
      description: _patchMap.containsKey(PermissionScope$.description)
          ? ((_patchMap[PermissionScope$.description] is Function)
                    ? _patchMap[PermissionScope$.description](this.description)
                    : (_patchMap[PermissionScope$.description] is Patch)
                    ? _patchMap[PermissionScope$.description].applyTo(
                        this.description,
                      )
                    : _patchMap[PermissionScope$.description])
                as String
          : this.description,
      platformGroup: _patchMap.containsKey(PermissionScope$.platformGroup)
          ? ((_patchMap[PermissionScope$.platformGroup] is Function)
                    ? _patchMap[PermissionScope$.platformGroup](
                        this.platformGroup,
                      )
                    : (_patchMap[PermissionScope$.platformGroup] is Patch)
                    ? _patchMap[PermissionScope$.platformGroup].applyTo(
                        this.platformGroup,
                      )
                    : _patchMap[PermissionScope$.platformGroup])
                as String
          : this.platformGroup,
      id: _patchMap.containsKey(PermissionScope$.id)
          ? ((_patchMap[PermissionScope$.id] is Function)
                    ? _patchMap[PermissionScope$.id](this.id)
                    : (_patchMap[PermissionScope$.id] is Patch)
                    ? _patchMap[PermissionScope$.id].applyTo(this.id)
                    : _patchMap[PermissionScope$.id])
                as String
          : this.id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PermissionScope &&
        name == other.name &&
        description == other.description &&
        platformGroup == other.platformGroup &&
        id == other.id;
  }

  @override
  int get hashCode {
    return Object.hash(
      this.name,
      this.description,
      this.platformGroup,
      this.id,
    );
  }

  @override
  String toString() {
    return 'PermissionScope(' +
        'name: ${name}' +
        ', ' +
        'description: ${description}' +
        ', ' +
        'platformGroup: ${platformGroup}' +
        ', ' +
        'id: ${id})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$PermissionScopeToJson(this);
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

extension PermissionScopePropertyHelpers on PermissionScope {
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

  bool get hasPlatformGroup {
    return this.platformGroup.isNotEmpty;
  }

  bool get noPlatformGroup {
    return this.platformGroup.isEmpty;
  }

  bool get hasId {
    return this.id.isNotEmpty;
  }

  bool get noId {
    return this.id.isEmpty;
  }
}

extension PermissionScopeSerialization on PermissionScope {
  Map<String, dynamic> toJson() {
    return _$PermissionScopeToJson(this);
  }
}

enum PermissionScope$ { name_, description, platformGroup, id }

class PermissionScopePatch
    extends PatchBase<PermissionScope, PermissionScope$> {
  PermissionScope applyTo(PermissionScope entity) {
    return entity.patchWithPermissionScope(this);
  }

  PermissionScopePatch withName(String? value) {
    patchMap[PermissionScope$.name_] = value;
    return this;
  }

  PermissionScopePatch withDescription(String? value) {
    patchMap[PermissionScope$.description] = value;
    return this;
  }

  PermissionScopePatch withPlatformGroup(String? value) {
    patchMap[PermissionScope$.platformGroup] = value;
    return this;
  }

  PermissionScopePatch withId(String? value) {
    patchMap[PermissionScope$.id] = value;
    return this;
  }
}

/// Field descriptors for [PermissionScope] query construction
abstract final class PermissionScopeFields {
  static const name = Field<PermissionScope, String>('name', _$name);

  static const description = Field<PermissionScope, String>(
    'description',
    _$description,
  );

  static const platformGroup = Field<PermissionScope, String>(
    'platformGroup',
    _$platformGroup,
  );

  static const id = Field<PermissionScope, String>('id', _$id);

  static String _$name(PermissionScope e) {
    return e.name;
  }

  static String _$description(PermissionScope e) {
    return e.description;
  }

  static String _$platformGroup(PermissionScope e) {
    return e.platformGroup;
  }

  static String _$id(PermissionScope e) {
    return e.id;
  }
}

extension PermissionScopeCompareE on PermissionScope {
  Map<String, dynamic> compareToPermissionScope(PermissionScope other) {
    final Map<String, dynamic> diff = {};

    if (name != other.name) {
      diff['name'] = () => other.name;
    }

    if (description != other.description) {
      diff['description'] = () => other.description;
    }

    if (platformGroup != other.platformGroup) {
      diff['platformGroup'] = () => other.platformGroup;
    }

    if (id != other.id) {
      diff['id'] = () => other.id;
    }
    return diff;
  }
}
