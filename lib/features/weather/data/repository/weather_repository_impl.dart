import 'package:study/features/weather/data/location_service.dart';
import 'package:study/features/weather/data/models/models.dart';
import 'package:study/features/weather/data/repository/weather_repository.dart';
import 'package:study/features/weather/data/weather_api_client.dart';
import 'package:study/features/weather/data/weather_storage.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({
    required WeatherApiClient apiClient,
    required WeatherStorage storage,
    required LocationService locationService,
  })  : _apiClient = apiClient,
        _storage = storage,
        _locationService = locationService;

  final WeatherApiClient _apiClient;
  final WeatherStorage _storage;
  final LocationService _locationService;

  @override
  Future<WeatherResult> getWeather({bool forceRefresh = false}) async {
    // 1. Check cache first (if not force refresh)
    if (!forceRefresh) {
      final cachedWeather = _storage.getValidWeather();
      if (cachedWeather != null) {
        return WeatherResult(weather: cachedWeather, isFromCache: true);
      }
    }

    // 2. Get location (cache -> GPS -> default)
    final location = await _getLocation(forceRefresh: forceRefresh);

    // 3. Fetch from API
    try {
      final weather = await _apiClient.getWeatherByCoordinates(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      // Save to cache
      await _storage.saveWeather(weather);

      return WeatherResult(weather: weather, isFromCache: false);
    } catch (_) {
      // 4. Fallback to old cache if API fails
      final oldCache = _storage.getWeather();
      if (oldCache != null) {
        return WeatherResult(weather: oldCache, isFromCache: true);
      }

      // 5. Throw if no fallback available
      rethrow;
    }
  }

  Future<LocationModel> _getLocation({bool forceRefresh = false}) async {
    // 1. Check if user has selected a city manually
    final selectedCity = _storage.getSelectedCity();
    if (selectedCity != null) {
      return LocationModel(
        latitude: selectedCity.lat,
        longitude: selectedCity.lon,
        cityName: selectedCity.name,
        cachedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }

    // 2. Check location cache (if not force refresh)
    if (!forceRefresh) {
      final cachedLocation = _storage.getValidLocation();
      if (cachedLocation != null) {
        return cachedLocation;
      }
    }

    // 3. Try GPS
    final gpsLocation = await _locationService.getCurrentLocation();
    if (gpsLocation != null) {
      await _storage.saveLocation(gpsLocation);
      return gpsLocation;
    }

    // 4. Fallback to cached location (even if expired)
    final oldLocation = _storage.getLocation();
    if (oldLocation != null) {
      return oldLocation;
    }

    // 5. Fallback to default (Hanoi)
    final defaultLocation = _locationService.getDefaultLocation();
    await _storage.saveLocation(defaultLocation);
    return defaultLocation;
  }

  @override
  Future<void> clearCache() async {
    await _storage.clearAll();
  }
}
