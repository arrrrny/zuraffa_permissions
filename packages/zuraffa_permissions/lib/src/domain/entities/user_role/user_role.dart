import 'package:zorphy_annotation/zorphy_annotation.dart';

part 'user_role.zorphy.dart';
part 'user_role.g.dart';

/// UserRole entity (FR-001): an assignment of one role to one user,
/// identified by the ([userId], [roleId]) pair.
@Zorphy(generateJson: true, generateCompareTo: true)
abstract class $UserRole {
  /// The user holding the role.
  String get userId;

  /// The assigned role id.
  String get roleId;

  /// Assignment timestamp (milliseconds since epoch).
  int get assignedAt;
}
