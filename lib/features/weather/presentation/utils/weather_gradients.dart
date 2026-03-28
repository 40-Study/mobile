import 'package:flutter/material.dart';
import 'package:study/features/weather/data/models/models.dart';

/// Gradient definitions for weather backgrounds
class WeatherGradients {
  const WeatherGradients._();

  // ============ SUNNY ============

  static const sunnyDawn = [
    Color(0xFF1A1A2E),
    Color(0xFF3D2645),
    Color(0xFF6B4B5E),
    Color(0xFFB5627D),
    Color(0xFFE8946A),
    Color(0xFFFFBE7B),
    Color(0xFFFFD89B),
  ];

  static const sunnyDay = [
    Color(0xFF0369A1),
    Color(0xFF0EA5E9),
    Color(0xFF38BDF8),
    Color(0xFF7DD3FC),
    Color(0xFFBAE6FD),
    Color(0xFFE0F2FE),
  ];

  static const sunnyDusk = [
    Color(0xFF1E1B4B),
    Color(0xFF3730A3),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFC4B5FD),
    Color(0xFFFED7AA),
    Color(0xFFFFEDD5),
  ];

  static const sunnyNight = [
    Color(0xFF0A0E1A),
    Color(0xFF0F1629),
    Color(0xFF151E3A),
    Color(0xFF1A2744),
    Color(0xFF1E2D4D),
  ];

  // ============ RAINY ============

  static const rainyDawn = [
    Color(0xFF1F2937),
    Color(0xFF374151),
    Color(0xFF4B5563),
    Color(0xFF6B7280),
    Color(0xFF9CA3AF),
  ];

  static const rainyDay = [
    Color(0xFF1F2937),
    Color(0xFF374151),
    Color(0xFF4B5563),
    Color(0xFF6B7280),
  ];

  static const rainyDusk = [
    Color(0xFF374151),
    Color(0xFF4B5563),
    Color(0xFF6B7280),
    Color(0xFF9CA3AF),
    Color(0xFFD1D5DB),
  ];

  static const rainyNight = [
    Color(0xFF0F172A),
    Color(0xFF1E293B),
    Color(0xFF334155),
    Color(0xFF475569),
  ];

  // ============ SNOWY ============

  static const snowyDawn = [
    Color(0xFF1E3A5F),
    Color(0xFF3B5998),
    Color(0xFF6B8CAE),
    Color(0xFFA7C4D4),
    Color(0xFFD6E5F0),
  ];

  static const snowyDay = [
    Color(0xFF4A6B8A),
    Color(0xFF6B8CAE),
    Color(0xFF8AABC4),
    Color(0xFFB8D4E8),
    Color(0xFFE8F4F8),
  ];

  static const snowyDusk = [
    Color(0xFF4A3B6E),
    Color(0xFF6B5B8E),
    Color(0xFF9B8BB8),
    Color(0xFFCDBDE8),
    Color(0xFFE8E0F8),
  ];

  static const snowyNight = [
    Color(0xFF0A1628),
    Color(0xFF152238),
    Color(0xFF1E3048),
    Color(0xFF2A4058),
    Color(0xFF3A5068),
  ];

  // ============ CLOUDY ============

  static const cloudyDawn = [
    Color(0xFF2D3748),
    Color(0xFF4A5568),
    Color(0xFF718096),
    Color(0xFFA0AEC0),
    Color(0xFFCBD5E0),
  ];

  static const cloudyDay = [
    Color(0xFF4A5568),
    Color(0xFF718096),
    Color(0xFFA0AEC0),
    Color(0xFFCBD5E0),
    Color(0xFFE2E8F0),
  ];

  static const cloudyDusk = [
    Color(0xFF4D4D64),
    Color(0xFF6D6D84),
    Color(0xFF8D8DA4),
    Color(0xFFB0B0C4),
    Color(0xFFD0D0E4),
  ];

  static const cloudyNight = [
    Color(0xFF1A1A28),
    Color(0xFF2A2A38),
    Color(0xFF3A3A48),
    Color(0xFF4A4A58),
  ];

  /// Get gradient colors for condition and time
  static List<Color> getGradient({
    required WeatherCondition condition,
    required TimeOfDayType timeOfDay,
  }) {
    return switch (condition) {
      WeatherCondition.sunny => _getSunnyGradient(timeOfDay),
      WeatherCondition.rainy => _getRainyGradient(timeOfDay),
      WeatherCondition.snowy => _getSnowyGradient(timeOfDay),
      WeatherCondition.cloudy => _getCloudyGradient(timeOfDay),
      WeatherCondition.defaultNeutral => cloudyDay,
    };
  }

  static List<Color> _getSunnyGradient(TimeOfDayType timeOfDay) {
    return switch (timeOfDay) {
      TimeOfDayType.dawn => sunnyDawn,
      TimeOfDayType.day => sunnyDay,
      TimeOfDayType.dusk => sunnyDusk,
      TimeOfDayType.night => sunnyNight,
    };
  }

  static List<Color> _getRainyGradient(TimeOfDayType timeOfDay) {
    return switch (timeOfDay) {
      TimeOfDayType.dawn => rainyDawn,
      TimeOfDayType.day => rainyDay,
      TimeOfDayType.dusk => rainyDusk,
      TimeOfDayType.night => rainyNight,
    };
  }

  static List<Color> _getSnowyGradient(TimeOfDayType timeOfDay) {
    return switch (timeOfDay) {
      TimeOfDayType.dawn => snowyDawn,
      TimeOfDayType.day => snowyDay,
      TimeOfDayType.dusk => snowyDusk,
      TimeOfDayType.night => snowyNight,
    };
  }

  static List<Color> _getCloudyGradient(TimeOfDayType timeOfDay) {
    return switch (timeOfDay) {
      TimeOfDayType.dawn => cloudyDawn,
      TimeOfDayType.day => cloudyDay,
      TimeOfDayType.dusk => cloudyDusk,
      TimeOfDayType.night => cloudyNight,
    };
  }

  /// Gradient stops for smooth transitions
  static List<double> getStops(int colorCount) {
    if (colorCount <= 1) return [0.0];
    return List.generate(
      colorCount,
      (i) => i / (colorCount - 1),
    );
  }
}
