import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/features/weather/data/models/models.dart';

/// Local cache for weather and location data
class WeatherStorage {
  WeatherStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _weatherKey = 'weather_cache';
  static const String _locationKey = 'location_cache';
  static const String _selectedCityKey = 'selected_city';

  // ==================== Weather Cache ====================

  Future<void> saveWeather(WeatherModel weather) async {
    final json = weather.toJson();
    await _prefs.setString(_weatherKey, jsonEncode(json));
  }

  WeatherModel? getWeather() {
    final jsonStr = _prefs.getString(_weatherKey);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return WeatherModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Get cached weather if still valid (< 30 min)
  WeatherModel? getValidWeather() {
    final weather = getWeather();
    if (weather == null || !weather.isCacheValid) return null;
    return weather;
  }

  Future<void> clearWeather() async {
    await _prefs.remove(_weatherKey);
  }

  // ==================== Location Cache ====================

  Future<void> saveLocation(LocationModel location) async {
    final json = location.toJson();
    await _prefs.setString(_locationKey, jsonEncode(json));
  }

  LocationModel? getLocation() {
    final jsonStr = _prefs.getString(_locationKey);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return LocationModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Get cached location if still valid (< 15 min)
  LocationModel? getValidLocation() {
    final location = getLocation();
    if (location == null || !location.isCacheValid) return null;
    return location;
  }

  Future<void> clearLocation() async {
    await _prefs.remove(_locationKey);
  }

  // ==================== Selected City ====================

  Future<void> saveSelectedCity(CityModel city) async {
    final json = {
      'name': city.name,
      'lat': city.lat,
      'lon': city.lon,
      'country': city.country,
    };
    await _prefs.setString(_selectedCityKey, jsonEncode(json));
    // Clear weather cache when city changes
    await clearWeather();
  }

  CityModel? getSelectedCity() {
    final jsonStr = _prefs.getString(_selectedCityKey);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return CityModel(
        name: json['name'] as String,
        lat: json['lat'] as double,
        lon: json['lon'] as double,
        country: json['country'] as String? ?? 'VN',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSelectedCity() async {
    await _prefs.remove(_selectedCityKey);
  }

  // ==================== Clear All ====================

  Future<void> clearAll() async {
    await Future.wait([
      clearWeather(),
      clearLocation(),
      clearSelectedCity(),
    ]);
  }
}
