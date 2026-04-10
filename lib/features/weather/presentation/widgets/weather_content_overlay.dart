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

/// Extension to get appropriate text color for background
/// Now uses system theme (light/dark mode) instead of weather state
extension WeatherTextColor on BuildContext {
  /// Check if current theme is dark mode
  bool get isWeatherBackgroundDark {
    return Theme.of(this).brightness == Brightness.dark;
  }

  /// Get text color that contrasts with background
  Color get weatherTextColor {
    final cs = Theme.of(this).colorScheme;
    return cs.onSurface;
  }

  /// Get secondary text color
  Color get weatherTextColorSecondary {
    final cs = Theme.of(this).colorScheme;
    return cs.onSurfaceVariant;
  }

  /// Get themed text color
  Color get weatherTextColorThemed {
    final cs = Theme.of(this).colorScheme;
    return cs.onSurface;
  }

  /// Get themed secondary text color with opacity
  Color get weatherTextColorThemedSecondary {
    final cs = Theme.of(this).colorScheme;
    return cs.onSurfaceVariant;
  }

  /// Get icon color
  Color get weatherIconColor {
    final cs = Theme.of(this).colorScheme;
    return cs.primary;
  }

  /// Get icon background color
  Color get weatherIconBackgroundColor {
    final cs = Theme.of(this).colorScheme;
    return cs.primaryContainer;
  }
}
