import 'package:flutter/material.dart';
import 'package:study/features/weather/data/models/models.dart';
import 'package:study/features/weather/presentation/utils/weather_gradients.dart';
import 'package:study/features/weather/presentation/widgets/painters/cloud_layer_painter.dart';
import 'package:study/features/weather/presentation/widgets/painters/moon_painter.dart';
import 'package:study/features/weather/presentation/widgets/painters/mountain_painter.dart';
import 'package:study/features/weather/presentation/widgets/painters/rain_painter.dart';
import 'package:study/features/weather/presentation/widgets/painters/sea_painter.dart';
import 'package:study/features/weather/presentation/widgets/painters/snow_painter.dart';
import 'package:study/features/weather/presentation/widgets/painters/star_painter.dart';

/// Unified weather background supporting all conditions
class WeatherBackground extends StatefulWidget {
  const WeatherBackground({
    super.key,
    required this.condition,
    required this.timeOfDay,
    this.transitionDuration = const Duration(milliseconds: 800),
  });

  final WeatherCondition condition;
  final TimeOfDayType timeOfDay;
  final Duration transitionDuration;

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _seaController;
  late AnimationController _moonController;
  late AnimationController _weatherController;

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _seaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _weatherController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _starController.dispose();
    _seaController.dispose();
    _moonController.dispose();
    _weatherController.dispose();
    super.dispose();
  }

  bool get _showStars {
    // No stars in bad weather
    if (widget.condition == WeatherCondition.cloudy ||
        widget.condition == WeatherCondition.rainy) {
      return false;
    }
    return widget.timeOfDay == TimeOfDayType.night ||
        widget.timeOfDay == TimeOfDayType.dusk;
  }

  bool get _showMoon {
    // No moon in rainy weather
    if (widget.condition == WeatherCondition.rainy) {
      return false;
    }
    return widget.timeOfDay == TimeOfDayType.night;
  }

  int get _starCount {
    return switch (widget.timeOfDay) {
      TimeOfDayType.night => 50,
      TimeOfDayType.dusk => 15,
      _ => 0,
    };
  }

  double get _starOpacity {
    return switch (widget.timeOfDay) {
      TimeOfDayType.night => 1.0,
      TimeOfDayType.dusk => 0.4,
      _ => 0.0,
    };
  }

  List<Color> get _mountainColors {
    final baseColors = _baseMountainColors;

    // Rainy - darker, desaturated mountains
    if (widget.condition == WeatherCondition.rainy) {
      return baseColors.map((c) {
        final hsl = HSLColor.fromColor(c);
        return hsl
            .withSaturation((hsl.saturation * 0.5).clamp(0.0, 1.0))
            .withLightness((hsl.lightness * 0.7).clamp(0.0, 1.0))
            .toColor();
      }).toList();
    }

    // Cloudy - slightly darker
    if (widget.condition == WeatherCondition.cloudy) {
      return baseColors.map((c) {
        return Color.lerp(c, const Color(0xFF4A5568), 0.2)!;
      }).toList();
    }

    // Snowy - cooler tones
    if (widget.condition == WeatherCondition.snowy) {
      return baseColors.map((c) {
        return Color.lerp(c, const Color(0xFF6B8CAE), 0.3)!;
      }).toList();
    }

    return baseColors;
  }

  List<Color> get _baseMountainColors {
    return switch (widget.timeOfDay) {
      TimeOfDayType.dawn => const [
          Color(0xFF4A3728),
          Color(0xFF3D2D22),
          Color(0xFF2D211A),
        ],
      TimeOfDayType.day => const [
          Color(0xFF5B7C6F),
          Color(0xFF4A6B5E),
          Color(0xFF3A5A4D),
        ],
      TimeOfDayType.dusk => const [
          Color(0xFF4A3B6E),
          Color(0xFF3A2B5E),
          Color(0xFF2A1B4E),
        ],
      TimeOfDayType.night => const [
          Color(0xFF1A2744),
          Color(0xFF121D33),
          Color(0xFF0A1222),
        ],
    };
  }

  Color get _seaColor {
    final baseColor = switch (widget.timeOfDay) {
      TimeOfDayType.dawn => const Color(0xFF8B6914),
      TimeOfDayType.day => const Color(0xFF0369A1),
      TimeOfDayType.dusk => const Color(0xFF6366F1),
      TimeOfDayType.night => const Color(0xFF0F172A),
    };

    // Rainy - dark grey-blue stormy sea
    if (widget.condition == WeatherCondition.rainy) {
      return const Color(0xFF2D3748).withValues(alpha: 0.8);
    }

    // Cloudy - muted sea
    if (widget.condition == WeatherCondition.cloudy) {
      return Color.lerp(baseColor, const Color(0xFF4A5568), 0.4)!
          .withValues(alpha: 0.6);
    }

    // Snowy - cold blue
    if (widget.condition == WeatherCondition.snowy) {
      return Color.lerp(baseColor, const Color(0xFF6B8CAE), 0.4)!
          .withValues(alpha: 0.5);
    }

    return baseColor.withValues(alpha: 0.5);
  }

  Color? get _waveColor {
    if (widget.condition == WeatherCondition.rainy) {
      return Colors.white.withValues(alpha: 0.25);
    }
    return null;
  }

  Color? get _reflectionColor {
    // No reflection in bad weather
    if (widget.condition == WeatherCondition.rainy ||
        widget.condition == WeatherCondition.cloudy) {
      return null;
    }
    return switch (widget.timeOfDay) {
      TimeOfDayType.dawn => const Color(0xFFFFD89B),
      TimeOfDayType.day => null,
      TimeOfDayType.dusk => const Color(0xFFC4B5FD),
      TimeOfDayType.night => const Color(0xFFFFFACD),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = WeatherGradients.getGradient(
      condition: widget.condition,
      timeOfDay: widget.timeOfDay,
    );

    return AnimatedContainer(
      duration: widget.transitionDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: WeatherGradients.getStops(colors.length),
        ),
      ),
      child: Stack(
        children: [
          // Stars layer (clear weather only)
          if (_showStars)
            AnimatedOpacity(
              duration: widget.transitionDuration,
              opacity: _starOpacity,
              child: AnimatedBuilder(
                animation: _starController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: StarPainter(
                      starCount: _starCount,
                      twinkleValue: _starController.value,
                    ),
                  );
                },
              ),
            ),

          // Moon (clear night only)
          if (_showMoon)
            AnimatedBuilder(
              animation: _moonController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: MoonPainter(
                    animationValue: _moonController.value,
                    position: const Offset(0.75, 0.08),
                    size: 0.07,
                  ),
                );
              },
            ),

          // Cloud layers (cloudy weather - before mountains)
          if (widget.condition == WeatherCondition.cloudy)
            AnimatedBuilder(
              animation: _weatherController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: CloudLayerPainter(
                    animationValue: _weatherController.value,
                    cloudColor: _getCloudColor(),
                    layerCount: 3,
                  ),
                );
              },
            ),

          // Mountains
          CustomPaint(
            size: Size.infinite,
            painter: MountainPainter(
              colors: _mountainColors,
              heightFactor: 0.22,
              layerCount: 3,
            ),
          ),

          // Sea
          AnimatedBuilder(
            animation: _seaController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: SeaPainter(
                  animationValue: _seaController.value,
                  seaColor: _seaColor,
                  waveColor: _waveColor,
                  heightFactor: 0.12,
                  showReflection: _reflectionColor != null,
                  reflectionColor: _reflectionColor,
                ),
              );
            },
          ),

          // Weather effects (rain, snow)
          ..._buildWeatherEffects(),
        ],
      ),
    );
  }

  Color _getCloudColor() {
    return switch (widget.timeOfDay) {
      TimeOfDayType.dawn => const Color(0xFFD1D5DB),
      TimeOfDayType.day => const Color(0xFFE5E7EB),
      TimeOfDayType.dusk => const Color(0xFFCBCBDB),
      TimeOfDayType.night => const Color(0xFF6B7280),
    };
  }

  List<Widget> _buildWeatherEffects() {
    return switch (widget.condition) {
      WeatherCondition.rainy => [
          AnimatedBuilder(
            animation: _weatherController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: RainPainter(
                  animationValue: _weatherController.value,
                  dropCount: 50,
                  dropColor: const Color(0xFFB0C4DE),
                  showRipples: true,
                  rippleY: 0.88,
                ),
              );
            },
          ),
        ],
      WeatherCondition.snowy => [
          AnimatedBuilder(
            animation: _weatherController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: SnowPainter(
                  animationValue: _weatherController.value,
                  flakeCount: 25,
                ),
              );
            },
          ),
        ],
      _ => [],
    };
  }
}
