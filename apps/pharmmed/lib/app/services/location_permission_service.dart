import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

/// Normalized result of a location read, including reverse-geocoded address bits.
class LocationResult {
  final double lat;
  final double lng;
  final String label; // e.g. "123 Main St, City, Pincode" or "Current location (lat, lng)"
  final String? city;
  final String? pincode;

  LocationResult({
    required this.lat,
    required this.lng,
    required this.label,
    this.city,
    this.pincode,
  });

  factory LocationResult.fromPosition(Position pos, {String? address}) {
    // Simple reverse-geocoding fallback: if we have an address string, parse it;
    // otherwise fall back to a readable lat/lng label.
    String label;
    if (address != null && address.isNotEmpty) {
      label = address;
    } else {
      label = 'Current location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
    }
    return LocationResult(
      lat: pos.latitude,
      lng: pos.longitude,
      label: label,
    );
  }
}

/// Wraps [permission_handler] and [geolocator] so the PharmMed app can check and
/// request location permission, check if location services are enabled, and read
/// the current position with reverse geocoding in one place.
class LocationPermissionService {
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

  /// Opens the device's location settings (GPS).
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Checks whether the device's Location service (GPS) is turned on.
  Future<bool> isServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Reads the current position (10 s limit) and reverse-geocodes it.
  /// Returns `null` when the position can't be read.
  Future<LocationResult?> currentLocation() async {
    final Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
    try {
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isNotEmpty) {
        final m = marks.first;
        final parts = [m.name, m.subLocality, m.locality, m.postalCode]
            .whereType<String>()
            .where((p) => p.trim().isNotEmpty)
            .toSet()
            .toList();
        if (parts.isNotEmpty) {
          return LocationResult(
            lat: pos.latitude,
            lng: pos.longitude,
            label: parts.join(', '),
            city: m.locality,
            pincode: m.postalCode,
          );
        }
      }
    } catch (_) {
      // Geocoder unavailable — fall through to a coordinate label.
    }
    return LocationResult.fromPosition(pos);
  }

  /// Normalizes a [PermissionStatus] from permission_handler into our enum.
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

  /// For testing: forcibly sets the permission status.
  /// Useful in widget tests where real permission checks would block the UI.
  void forceStatusForTest(LocationPermissionStatus status) {
    _forcedTestStatus = status;
  }

  LocationPermissionStatus? _forcedTestStatus;
}