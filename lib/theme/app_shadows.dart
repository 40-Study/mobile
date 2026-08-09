import 'package:flutter/material.dart';

/// Design System - Shadow constants
abstract class AppShadows {
  // Shadow color (dark blue tinted)
  static const _shadowColor = Color(0xFF010120);

  // Elevation shadows
  static final none = <BoxShadow>[];

  static final sm = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static final soft = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.035),
      blurRadius: 24,
      spreadRadius: -6,
      offset: const Offset(0, 8),
    ),
  ];

  static final layeredCard = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.065),
      blurRadius: 32,
      spreadRadius: -8,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final md = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final lg = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static final xl = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.05),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  // Semantic shadows
  static final card = md;
  static final button = sm;
  static final dialog = xl;
  static final dropdown = lg;
  static final fab = lg;

  // Colored shadows (for role cards, etc.)
  static List<BoxShadow> colored(Color color, {double opacity = 0.3}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Glow effect
  static List<BoxShadow> glow(Color color, {double opacity = 0.4}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 32,
      spreadRadius: -4,
    ),
  ];
}
