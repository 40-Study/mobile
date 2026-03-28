import 'package:study/features/weather/data/models/models.dart';

/// Result wrapper for weather data
class WeatherResult {
  const WeatherResult({
    required this.weather,
    required this.isFromCache,
  });

  final WeatherModel weather;
  final bool isFromCache;
}

/// Abstract repository interface for weather data
abstract class WeatherRepository {
  /// Get weather data
  /// - Uses cache if valid (< 30 min)
  /// - Falls back to default location if GPS fails
  /// - Falls back to cached data if API fails
  Future<WeatherResult> getWeather({bool forceRefresh = false});

  /// Clear all cached data
  Future<void> clearCache();
}
