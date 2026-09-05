import 'package:zorphy_annotation/zorphy_annotation.dart';

part 'role.zorphy.dart';
part 'role.g.dart';

/// Role entity (FR-001): a named collection of permissions, identified
/// by a unique [id]. Role → permission membership is modeled by the
/// [RolePermission] join entity.
@Zorphy(generateJson: true, generateCompareTo: true)
abstract class $Role {
  /// Unique identifier, e.g. `role.content-editor`.
  String get id;

  /// Human-readable name.
  String get name;

  /// What holding the role means.
  String get description;
}
