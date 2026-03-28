import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/weather/bloc/weather_background_cubit.dart';

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
        final isDark = state.isDarkBackground;

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
}

/// Extension to get appropriate text color for weather background
extension WeatherTextColor on BuildContext {
  /// Check if weather background is dark based on gradient luminance
  /// This automatically handles all weather conditions and times of day
  bool get isWeatherBackgroundDark {
    try {
      final state = read<WeatherBackgroundCubit>().state;
      return state.isDarkBackground;
    } catch (_) {
      return false;
    }
  }

  /// Get text color that contrasts with current weather background
  Color get weatherTextColor {
    return isWeatherBackgroundDark ? Colors.white : Colors.black87;
  }

  /// Get secondary text color for weather background
  Color get weatherTextColorSecondary {
    return isWeatherBackgroundDark ? Colors.white70 : Colors.black54;
  }

  /// Get themed text color - uses theme's onSurface for light, white for dark
  Color get weatherTextColorThemed {
    final cs = Theme.of(this).colorScheme;
    return isWeatherBackgroundDark ? Colors.white : cs.onSurface;
  }

  /// Get themed secondary text color with opacity
  Color get weatherTextColorThemedSecondary {
    final cs = Theme.of(this).colorScheme;
    return isWeatherBackgroundDark
        ? Colors.white.withValues(alpha: 0.7)
        : cs.onSurface.withValues(alpha: 0.6);
  }

  /// Get icon color for weather background
  Color get weatherIconColor {
    final cs = Theme.of(this).colorScheme;
    return isWeatherBackgroundDark ? Colors.white : cs.primary;
  }

  /// Get icon background color for weather background
  Color get weatherIconBackgroundColor {
    final cs = Theme.of(this).colorScheme;
    return isWeatherBackgroundDark
        ? Colors.white.withValues(alpha: 0.15)
        : cs.primaryContainer;
  }
}
