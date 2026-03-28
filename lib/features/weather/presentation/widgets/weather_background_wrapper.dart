import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/weather/bloc/weather_background_cubit.dart';
import 'package:study/features/weather/data/models/models.dart';
import 'package:study/features/weather/presentation/widgets/weather_background.dart';

/// Wrapper widget that displays weather background behind content
class WeatherBackgroundWrapper extends StatelessWidget {
  const WeatherBackgroundWrapper({
    super.key,
    required this.child,
    this.condition,
    this.timeOfDay,
    this.showOverlay = true,
    this.overlayIntensity = 0.5,
    this.bottomOverlayIntensity = 0.85,
  });

  final Widget child;

  /// Override condition (for testing). If null, uses Cubit state
  final WeatherCondition? condition;

  /// Override time of day (for testing). If null, uses Cubit state
  final TimeOfDayType? timeOfDay;

  /// Show gradient overlay for better text readability
  final bool showOverlay;

  /// Overlay intensity (0.0 - 1.0)
  final double overlayIntensity;

  /// Bottom overlay intensity for mountain/sea area
  final double bottomOverlayIntensity;

  @override
  Widget build(BuildContext context) {
    // Use overrides if provided, otherwise use Cubit
    if (condition != null || timeOfDay != null) {
      return _buildWithBackground(
        condition: condition ?? WeatherCondition.sunny,
        timeOfDay: timeOfDay ?? TimeOfDayType.day,
        child: child,
      );
    }

    return BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
      builder: (context, state) {
        return _buildWithBackground(
          condition: state.condition,
          timeOfDay: state.timeOfDay,
          child: child,
        );
      },
    );
  }

  Widget _buildWithBackground({
    required WeatherCondition condition,
    required TimeOfDayType timeOfDay,
    required Widget child,
  }) {
    final isDark =
        timeOfDay == TimeOfDayType.night || timeOfDay == TimeOfDayType.dusk;

    final overlayColor = isDark ? Colors.black : Colors.white;

    return Stack(
      children: [
        Positioned.fill(
          child: WeatherBackground(
            condition: condition,
            timeOfDay: timeOfDay,
          ),
        ),
        if (showOverlay)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    overlayColor.withValues(alpha: overlayIntensity),
                    overlayColor.withValues(alpha: overlayIntensity * 0.7),
                    overlayColor.withValues(alpha: overlayIntensity * 0.5),
                    overlayColor.withValues(alpha: overlayIntensity * 0.6),
                    overlayColor.withValues(alpha: bottomOverlayIntensity),
                  ],
                  stops: const [0.0, 0.2, 0.45, 0.7, 1.0],
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
