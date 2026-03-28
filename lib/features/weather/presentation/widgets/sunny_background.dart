import 'package:flutter/material.dart';
import 'package:study/features/weather/data/models/models.dart';
import 'package:study/features/weather/presentation/utils/weather_gradients.dart';
import 'package:study/features/weather/presentation/widgets/painters/moon_painter.dart';
import 'package:study/features/weather/presentation/widgets/painters/mountain_painter.dart';
import 'package:study/features/weather/presentation/widgets/painters/sea_painter.dart';
import 'package:study/features/weather/presentation/widgets/painters/star_painter.dart';

/// Animated weather background with gradient, mountains, and sea
class SunnyBackground extends StatefulWidget {
  const SunnyBackground({
    super.key,
    required this.timeOfDay,
    this.transitionDuration = const Duration(milliseconds: 800),
  });

  final TimeOfDayType timeOfDay;
  final Duration transitionDuration;

  @override
  State<SunnyBackground> createState() => _SunnyBackgroundState();
}

class _SunnyBackgroundState extends State<SunnyBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _seaController;
  late AnimationController _moonController;

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
  }

  @override
  void dispose() {
    _starController.dispose();
    _seaController.dispose();
    _moonController.dispose();
    super.dispose();
  }

  bool get _showStars =>
      widget.timeOfDay == TimeOfDayType.night ||
      widget.timeOfDay == TimeOfDayType.dusk;

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
    return switch (widget.timeOfDay) {
      TimeOfDayType.dawn => const [
          Color(0xFF4A3728), // Back - warm brown
          Color(0xFF3D2D22), // Middle
          Color(0xFF2D211A), // Front - dark
        ],
      TimeOfDayType.day => const [
          Color(0xFF5B7C6F), // Back - misty green
          Color(0xFF4A6B5E), // Middle
          Color(0xFF3A5A4D), // Front - darker green
        ],
      TimeOfDayType.dusk => const [
          Color(0xFF3D2645), // Back - purple
          Color(0xFF2D1B35), // Middle
          Color(0xFF1D1025), // Front - dark purple
        ],
      TimeOfDayType.night => const [
          Color(0xFF1A2744), // Back - navy
          Color(0xFF121D33), // Middle
          Color(0xFF0A1222), // Front - near black
        ],
    };
  }

  Color get _seaColor {
    return switch (widget.timeOfDay) {
      TimeOfDayType.dawn => const Color(0xFF8B6914).withValues(alpha: 0.6),
      TimeOfDayType.day => const Color(0xFF0369A1).withValues(alpha: 0.5),
      TimeOfDayType.dusk => const Color(0xFF581C87).withValues(alpha: 0.5),
      TimeOfDayType.night => const Color(0xFF0F172A).withValues(alpha: 0.7),
    };
  }

  Color? get _reflectionColor {
    return switch (widget.timeOfDay) {
      TimeOfDayType.dawn => const Color(0xFFFFD89B),
      TimeOfDayType.day => null,
      TimeOfDayType.dusk => const Color(0xFFFFB86C),
      TimeOfDayType.night => const Color(0xFFFFFACD),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = WeatherGradients.getGradient(
      condition: WeatherCondition.sunny,
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
          // Stars layer (night & dusk only)
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

          // Moon for night
          if (widget.timeOfDay == TimeOfDayType.night)
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

          // Mountains (layered)
          CustomPaint(
            size: Size.infinite,
            painter: MountainPainter(
              colors: _mountainColors,
              heightFactor: 0.22,
              layerCount: 3,
            ),
          ),

          // Sea with waves
          AnimatedBuilder(
            animation: _seaController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: SeaPainter(
                  animationValue: _seaController.value,
                  seaColor: _seaColor,
                  heightFactor: 0.12,
                  showReflection: _reflectionColor != null,
                  reflectionColor: _reflectionColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
