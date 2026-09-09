import 'package:zorphy_annotation/zorphy_annotation.dart';

part 'role_permission.zorphy.dart';
part 'role_permission.g.dart';

/// RolePermission entity (FR-001): join record placing one permission
/// inside one role, identified by the ([roleId], [permissionId]) pair.
@Zorphy(generateJson: true, generateCompareTo: true)
abstract class $RolePermission {
  /// The role that holds the permission.
  String get roleId;

  /// The permission granted through the role.
  String get permissionId;
}
