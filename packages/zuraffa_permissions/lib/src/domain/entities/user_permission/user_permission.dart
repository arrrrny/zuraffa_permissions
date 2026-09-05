import 'package:zorphy_annotation/zorphy_annotation.dart';

part 'user_permission.zorphy.dart';
part 'user_permission.g.dart';

/// UserPermission entity (FR-001): a direct grant of one permission to
/// one user, identified by the ([userId], [permissionId]) pair.
@Zorphy(generateJson: true, generateCompareTo: true)
abstract class $UserPermission {
  /// The user holding the permission.
  String get userId;

  /// The granted permission id.
  String get permissionId;

  /// Grant timestamp (milliseconds since epoch).
  int get grantedAt;
}
