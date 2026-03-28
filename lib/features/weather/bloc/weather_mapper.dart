import 'package:study/features/weather/bloc/weather_display_data.dart';
import 'package:study/features/weather/data/models/models.dart';

/// Maps API model to UI display data
class WeatherMapper {
  const WeatherMapper();

  /// Convert WeatherModel (API) -> WeatherDisplayData (UI)
  WeatherDisplayData toDisplayData(WeatherModel weather) {
    return WeatherDisplayData(
      condition: _mapCondition(weather.condition),
      timeOfDay: _calculateTimeOfDay(weather),
      cityName: weather.cityName.isNotEmpty ? weather.cityName : null,
      temperature: weather.temperature,
    );
  }

  WeatherCondition _mapCondition(String apiCondition) {
    return WeatherCondition.fromApiCondition(apiCondition);
  }

  TimeOfDayType _calculateTimeOfDay(WeatherModel weather) {
    // TODO: Remove hardcode - temporarily fixed to night
    return TimeOfDayType.night;
    // return TimeOfDayType.calculate(
    //   now: DateTime.now(),
    //   sunrise: weather.sunrise,
    //   sunset: weather.sunset,
    // );
  }
}
