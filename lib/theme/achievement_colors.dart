import 'package:flutter/material.dart';

/// Semantic colors for badges and achievements
abstract class AchievementColors {
  // Badge colors
  static const purple = Color(0xFF7C3AED);
  static const orange = Color(0xFFF59E0B);
  static const deepOrange = Color(0xFFEA580C);
  static const green = Color(0xFF10B981);
  static const blue = Color(0xFF3B82F6);
  static const lightBlue = Color(0xFF06B6D4);
  static const pink = Color(0xFFEC4899);
  static const red = Color(0xFFEF4444);
  static const violet = Color(0xFF8B5CF6);
  static const teal = Color(0xFF0D9488);

  // Badge color list for cycling
  static const badgeColors = [
    purple,
    orange,
    green,
    blue,
    pink,
    lightBlue,
    violet,
    red,
  ];

  static Color getBadgeColor(int index) => badgeColors[index % badgeColors.length];
}
