part of 'weather_background_cubit.dart';

sealed class WeatherBackgroundState extends Equatable {
  const WeatherBackgroundState();

  /// Always has display data (never null) - fallback to default
  WeatherCondition get condition => WeatherCondition.defaultNeutral;
  TimeOfDayType get timeOfDay => TimeOfDayType.day;

  @override
  List<Object?> get props => [];
}

final class WeatherBackgroundInitial extends WeatherBackgroundState {
  const WeatherBackgroundInitial();
}

final class WeatherBackgroundLoading extends WeatherBackgroundState {
  const WeatherBackgroundLoading({
    this.previousCondition,
    this.previousTimeOfDay,
  });

  final WeatherCondition? previousCondition;
  final TimeOfDayType? previousTimeOfDay;

  /// Keep previous background while loading
  @override
  WeatherCondition get condition => previousCondition ?? super.condition;

  @override
  TimeOfDayType get timeOfDay => previousTimeOfDay ?? super.timeOfDay;

  @override
  List<Object?> get props => [previousCondition, previousTimeOfDay];
}

final class WeatherBackgroundLoaded extends WeatherBackgroundState {
  const WeatherBackgroundLoaded({
    required this.displayData,
    this.isFromCache = false,
  });

  final WeatherDisplayData displayData;
  final bool isFromCache;

  @override
  WeatherCondition get condition => displayData.condition;

  @override
  TimeOfDayType get timeOfDay => displayData.timeOfDay;

  @override
  List<Object?> get props => [displayData, isFromCache];
}

final class WeatherBackgroundFailure extends WeatherBackgroundState {
  const WeatherBackgroundFailure({
    required this.message,
    this.fallbackData,
  });

  final String message;
  final WeatherDisplayData? fallbackData;

  /// Fallback when error - never empty
  @override
  WeatherCondition get condition => fallbackData?.condition ?? super.condition;

  @override
  TimeOfDayType get timeOfDay => fallbackData?.timeOfDay ?? super.timeOfDay;

  @override
  List<Object?> get props => [message, fallbackData];
}
