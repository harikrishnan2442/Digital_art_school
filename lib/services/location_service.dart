import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}

class LocationResult {
  final double latitude;
  final double longitude;
  final String? label;

  const LocationResult({required this.latitude, required this.longitude, this.label});
}

/// Wraps `geolocator` (GPS fix) + `geocoding` (turning that fix into a
/// human-readable "City, State" string) behind one call, with clear
/// error messages for every way a location request can fail.
///
/// Requires runtime permission entries in the native projects — see
/// the README section "Enabling location" for the exact
/// AndroidManifest.xml / Info.plist lines to add after running
/// `flutter create .`.
class LocationService {
  LocationService._();

  static Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        'Location services are turned off on this device. Enable them and try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permission was denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        'Location permission is permanently denied. Enable it for this app '
        'from your device settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );

    String? label;
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city = (p.locality != null && p.locality!.isNotEmpty)
            ? p.locality
            : p.subAdministrativeArea;
        final state = p.administrativeArea;
        label = [city, state]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
        if (label.isEmpty) label = null;
      }
    } catch (_) {
      // Reverse geocoding is best-effort — coordinates alone still work.
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      label: label,
    );
  }
}
