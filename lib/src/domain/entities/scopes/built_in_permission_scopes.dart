import '../../../domain/entities/permission_scope/permission_scope.dart';

/// Built-in permission scopes (FR-003): the ten every app touches,
/// instantiable with zero configuration.
abstract final class BuiltInPermissionScopes {
  /// Camera capture (photo/video).
  static final PermissionScope camera = PermissionScope(
    id: 'camera',
    name: 'camera',
    description: 'Take photos and record video.',
    platformGroup: 'media',
  );

  /// Photo library read/write (gallery picker).
  static final PermissionScope photos = PermissionScope(
    id: 'photos',
    name: 'photos',
    description: 'Pick and save photos from your library.',
    platformGroup: 'media',
  );

  /// Push/local notifications.
  static final PermissionScope notifications = PermissionScope(
    id: 'notifications',
    name: 'notifications',
    description: 'Send you notifications.',
    platformGroup: 'engagement',
  );

  /// Location while the app is in use.
  static final PermissionScope locationWhenInUse = PermissionScope(
    id: 'locationWhenInUse',
    name: 'locationWhenInUse',
    description: 'Access your location while using the app.',
    platformGroup: 'location',
  );

  /// Location always (background).
  static final PermissionScope locationAlways = PermissionScope(
    id: 'locationAlways',
    name: 'locationAlways',
    description: 'Access your location in the background.',
    platformGroup: 'location',
  );

  /// Microphone capture (audio).
  static final PermissionScope microphone = PermissionScope(
    id: 'microphone',
    name: 'microphone',
    description: 'Record audio with your microphone.',
    platformGroup: 'media',
  );

  /// File storage read/write.
  static final PermissionScope storage = PermissionScope(
    id: 'storage',
    name: 'storage',
    description: 'Read and write files on your device.',
    platformGroup: 'files',
  );

  /// Biometric authentication (Face ID / fingerprint).
  static final PermissionScope biometrics = PermissionScope(
    id: 'biometrics',
    name: 'biometrics',
    description: 'Authenticate with biometrics.',
    platformGroup: 'identity',
  );

  /// Contacts read access.
  static final PermissionScope contacts = PermissionScope(
    id: 'contacts',
    name: 'contacts',
    description: 'Read your contacts.',
    platformGroup: 'identity',
  );

  /// Calendar read/write.
  static final PermissionScope calendar = PermissionScope(
    id: 'calendar',
    name: 'calendar',
    description: 'Read and write calendar events.',
    platformGroup: 'productivity',
  );

  /// All built-ins in registration order.
  static final List<PermissionScope> all = [
    camera,
    photos,
    notifications,
    locationWhenInUse,
    locationAlways,
    microphone,
    storage,
    biometrics,
    contacts,
    calendar,
  ];
}
