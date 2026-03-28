import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:study/features/weather/data/models/models.dart';

/// OpenWeatherMap API client
class WeatherApiClient {
  WeatherApiClient({
    Dio? dio,
    String? apiKey,
  })  : _dio = dio ?? Dio(),
        _apiKey = apiKey ?? dotenv.get('WEATHER_API_KEY', fallback: '');

  final Dio _dio;
  final String _apiKey;

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Fetch weather by lat/lon (preferred method)
  Future<WeatherModel> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return WeatherModel.fromApiResponse(response.data!);
      }

      throw WeatherApiException('Failed to fetch weather data');
    } on DioException catch (e) {
      throw WeatherApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class WeatherApiException implements Exception {
  WeatherApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'WeatherApiException: $message (code: $statusCode)';
}
