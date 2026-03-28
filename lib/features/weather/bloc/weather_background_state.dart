part of 'weather_background_cubit.dart';

sealed class WeatherBackgroundState extends Equatable {
  const WeatherBackgroundState({
    this.debugTimeOverride,
    this.debugConditionOverride,
  });

  /// Debug override for time of day testing
  final TimeOfDayType? debugTimeOverride;

  /// Debug override for weather condition testing
  final WeatherCondition? debugConditionOverride;

  /// Get condition - uses debug override if set
  WeatherCondition get condition =>
      debugConditionOverride ?? WeatherCondition.sunny;

  /// Get time of day - uses debug override if set, otherwise calculates from current time
  TimeOfDayType get timeOfDay => debugTimeOverride ?? _calculateTimeOfDay();

  /// Calculate time of day based on current hour
  TimeOfDayType _calculateTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 8) return TimeOfDayType.dawn;
    if (hour >= 8 && hour < 17) return TimeOfDayType.day;
    if (hour >= 17 && hour < 20) return TimeOfDayType.dusk;
    return TimeOfDayType.night;
  }

  /// Whether the current background is considered "dark"
  /// Calculated from the actual gradient luminance
  bool get isDarkBackground => WeatherGradients.isDarkGradient(
        condition: condition,
        timeOfDay: timeOfDay,
      );

  @override
  List<Object?> get props => [debugTimeOverride, debugConditionOverride];
}

final class WeatherBackgroundInitial extends WeatherBackgroundState {
  const WeatherBackgroundInitial({
    super.debugTimeOverride,
    super.debugConditionOverride,
  });
}

final class WeatherBackgroundLoading extends WeatherBackgroundState {
  const WeatherBackgroundLoading({
    super.debugTimeOverride,
    super.debugConditionOverride,
    this.previousCondition,
    this.previousTimeOfDay,
  });

  final WeatherCondition? previousCondition;
  final TimeOfDayType? previousTimeOfDay;

  @override
  List<Object?> get props => [
        debugTimeOverride,
        debugConditionOverride,
        previousCondition,
        previousTimeOfDay,
      ];
}

final class WeatherBackgroundLoaded extends WeatherBackgroundState {
  const WeatherBackgroundLoaded({
    super.debugTimeOverride,
    super.debugConditionOverride,
    required this.displayData,
    this.isFromCache = false,
  });

  final WeatherDisplayData displayData;
  final bool isFromCache;

  @override
  List<Object?> get props => [
        debugTimeOverride,
        debugConditionOverride,
        displayData,
        isFromCache,
      ];
}

final class WeatherBackgroundFailure extends WeatherBackgroundState {
  const WeatherBackgroundFailure({
    super.debugTimeOverride,
    super.debugConditionOverride,
    required this.message,
    this.fallbackData,
  });

  final String message;
  final WeatherDisplayData? fallbackData;

  @override
  List<Object?> get props => [
        debugTimeOverride,
        debugConditionOverride,
        message,
        fallbackData,
      ];
}
