import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/weather/bloc/weather_background_cubit.dart';
import 'package:study/features/weather/data/models/models.dart';

/// Overlay gradient to ensure content readability on weather background
class WeatherContentOverlay extends StatelessWidget {
  const WeatherContentOverlay({
    super.key,
    required this.child,
    this.intensity = 0.4,
  });

  final Widget child;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
      builder: (context, state) {
        final isDark = _isDarkBackground(state.timeOfDay);

        return Stack(
          children: [
            // Gradient overlay for readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.black.withValues(alpha: intensity * 0.6),
                            Colors.black.withValues(alpha: intensity * 0.3),
                            Colors.transparent,
                          ]
                        : [
                            Colors.white.withValues(alpha: intensity * 0.7),
                            Colors.white.withValues(alpha: intensity * 0.4),
                            Colors.transparent,
                          ],
                    stops: const [0.0, 0.3, 0.7],
                  ),
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }

  bool _isDarkBackground(TimeOfDayType timeOfDay) {
    return timeOfDay == TimeOfDayType.night || timeOfDay == TimeOfDayType.dusk;
  }
}

/// Extension to get appropriate text color for weather background
extension WeatherTextColor on BuildContext {
  /// Get text color that contrasts with current weather background
  Color get weatherTextColor {
    try {
      final state = read<WeatherBackgroundCubit>().state;
      final isDark = state.timeOfDay == TimeOfDayType.night ||
          state.timeOfDay == TimeOfDayType.dusk;
      return isDark ? Colors.white : Colors.black87;
    } catch (_) {
      return Colors.black87;
    }
  }

  /// Get secondary text color for weather background
  Color get weatherTextColorSecondary {
    try {
      final state = read<WeatherBackgroundCubit>().state;
      final isDark = state.timeOfDay == TimeOfDayType.night ||
          state.timeOfDay == TimeOfDayType.dusk;
      return isDark ? Colors.white70 : Colors.black54;
    } catch (_) {
      return Colors.black54;
    }
  }
}
