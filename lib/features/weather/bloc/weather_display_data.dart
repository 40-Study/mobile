import 'package:equatable/equatable.dart';
import 'package:study/features/weather/data/models/models.dart';

/// UI display data (separated from API model)
class WeatherDisplayData extends Equatable {
  const WeatherDisplayData({
    required this.condition,
    required this.timeOfDay,
    this.cityName,
    this.temperature,
  });

  /// Default fallback data
  factory WeatherDisplayData.defaultData() => const WeatherDisplayData(
        condition: WeatherCondition.defaultNeutral,
        timeOfDay: TimeOfDayType.day,
      );

  final WeatherCondition condition;
  final TimeOfDayType timeOfDay;
  final String? cityName;
  final double? temperature;

  @override
  List<Object?> get props => [condition, timeOfDay, cityName, temperature];
}
