import 'package:geolocator/geolocator.dart';
import 'package:study/features/weather/data/models/models.dart';

/// Service for getting device location
class LocationService {
  /// Check if location services are enabled and permission granted
  Future<bool> isLocationAvailable() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission if not granted
  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Get current location
  /// Returns null if permission denied or service unavailable
  Future<LocationModel?> getCurrentLocation() async {
    try {
      // Check service enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // Check/request permission
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      // Get position with timeout
      // Low accuracy = faster + less battery
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        cachedAt: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get default location (Hanoi) when GPS fails
  LocationModel getDefaultLocation() => LocationModel.hanoi();
}
