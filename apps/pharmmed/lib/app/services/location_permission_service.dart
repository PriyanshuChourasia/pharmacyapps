import 'package:permission_handler/permission_handler.dart';

/// Normalized status of the location permission across platforms.
enum LocationPermissionStatus {
  /// The app can access the user's location.
  granted,

  /// iOS only: the user granted "while in use" / limited accuracy.
  limited,

  /// The user has not yet granted or denied the permission.
  denied,

  /// The user denied and checked "don't ask again" (or system restricted it).
  /// The app must not re-request; it should direct the user to app settings.
  permanentlyDenied,

  /// The status could not be determined.
  unknown,
}

/// Wraps [permission_handler] so the PharmMed app can check and request
/// location permission in one place.
class LocationPermissionService {
  LocationPermissionStatus _normalize(PermissionStatus status) {
    // In test mode, return the forced status if set.
    if (_forcedTestStatus != null) return _forcedTestStatus!;
    switch (status) {
      case PermissionStatus.granted:
        return LocationPermissionStatus.granted;
      case PermissionStatus.limited:
        return LocationPermissionStatus.limited;
      case PermissionStatus.denied:
        return LocationPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return LocationPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return LocationPermissionStatus.permanentlyDenied;
      case PermissionStatus.provisional:
        return LocationPermissionStatus.granted;
    }
  }

  /// The current location permission status.
  Future<LocationPermissionStatus> status() async {
    try {
      return _normalize(await Permission.location.status);
    } catch (_) {
      return LocationPermissionStatus.unknown;
    }
  }

  /// Requests location permission from the user and returns the resulting status.
  Future<LocationPermissionStatus> request() async {
    try {
      return _normalize(await Permission.location.request());
    } catch (_) {
      return LocationPermissionStatus.unknown;
    }
  }

  /// Opens the system app-settings page so the user can grant location access
  /// manually (used when permission is permanently denied).
  Future<bool> openSettings() => openAppSettings();

  /// For testing: forcibly sets the permission status.
  /// Useful in widget tests where real permission checks would block the UI.
  void forceStatusForTest(LocationPermissionStatus status) {
    _forcedTestStatus = status;
  }

  LocationPermissionStatus? _forcedTestStatus;
}