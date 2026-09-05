import 'package:zorphy_annotation/zorphy_annotation.dart';

part 'permission.zorphy.dart';
part 'permission.g.dart';

/// Permission entity (FR-001): a named capability a user may hold,
/// identified by a unique [id] and linked to the permission [scopeId]
/// it exercises on the device (a built-in or custom scope id).
@Zorphy(generateJson: true, generateCompareTo: true)
abstract class $Permission {
  /// Unique identifier, e.g. `perm.camera.read`.
  String get id;

  /// Human-readable name.
  String get name;

  /// What the permission allows.
  String get description;

  /// The PermissionScope id this permission exercises (e.g. `camera`).
  String get scopeId;
}
