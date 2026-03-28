import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_model.freezed.dart';
part 'weather_model.g.dart';

@freezed
abstract class WeatherModel with _$WeatherModel {
  const factory WeatherModel({
    @Default('Clear') String condition,
    @Default(25.0) double temperature,
    @Default(50) int humidity,
    @JsonKey(name: 'sunrise') required int sunriseTimestamp,
    @JsonKey(name: 'sunset') required int sunsetTimestamp,
    @JsonKey(name: 'city') @Default('') String cityName,
    @JsonKey(name: 'lat') double? latitude,
    @JsonKey(name: 'lon') double? longitude,
    @JsonKey(name: 'cached_at') int? cachedAt,
  }) = _WeatherModel;

  const WeatherModel._();

  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherModelFromJson(json);

  /// Parse from OpenWeatherMap API response
  factory WeatherModel.fromApiResponse(Map<String, dynamic> json) {
    final weather = json['weather'] as List?;
    final main = json['main'] as Map<String, dynamic>?;
    final sys = json['sys'] as Map<String, dynamic>?;
    final coord = json['coord'] as Map<String, dynamic>?;

    return WeatherModel(
      condition: weather?.isNotEmpty == true
          ? (weather!.first['main'] as String? ?? 'Clear')
          : 'Clear',
      temperature: (main?['temp'] as num?)?.toDouble() ?? 25.0,
      humidity: (main?['humidity'] as num?)?.toInt() ?? 50,
      sunriseTimestamp: (sys?['sunrise'] as num?)?.toInt() ?? 0,
      sunsetTimestamp: (sys?['sunset'] as num?)?.toInt() ?? 0,
      cityName: json['name'] as String? ?? '',
      latitude: (coord?['lat'] as num?)?.toDouble(),
      longitude: (coord?['lon'] as num?)?.toDouble(),
      cachedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  DateTime get sunrise =>
      DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000);

  DateTime get sunset =>
      DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000);

  bool get isCacheValid {
    if (cachedAt == null) return false;
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(cachedAt!);
    return DateTime.now().difference(cachedTime).inMinutes < 30;
  }
}
