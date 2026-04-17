import 'package:flutter/material.dart';

/// Together AI Design System - Color Extensions
///
/// Pastel gradients, dark-blue-tinted shadows, glass effects.
/// Sharp geometry (4px, 8px radius).
extension TogetherColorsX on ColorScheme {
  // ══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS (illustrations only, NOT UI chrome)
  // ══════════════════════════════════════════════════════════════════════════

  /// Brand Magenta - for illustrations only
  Color get brandMagenta => const Color(0xFFEF2CC1);

  /// Brand Orange - for illustrations only
  Color get brandOrange => const Color(0xFFFC4C02);

  /// Soft Lavender accent
  Color get softLavender => const Color(0xFFBDBBFF);

  /// Dark Blue (midnight blue)
  Color get darkBlue => const Color(0xFF010120);

  // ══════════════════════════════════════════════════════════════════════════
  // PASTEL COLORS
  // ══════════════════════════════════════════════════════════════════════════

  Color get pastelPink => const Color(0xFFFCE7F3);
  Color get pastelLavender => const Color(0xFFEDE9FE);
  Color get pastelBlue => const Color(0xFFDBEAFE);
  Color get pastelCyan => const Color(0xFFCFFAFE);

  // ══════════════════════════════════════════════════════════════════════════
  // PASTEL GRADIENTS (decorative backgrounds)
  // ══════════════════════════════════════════════════════════════════════════

  /// Hero pastel gradient - pink to lavender to blue
  LinearGradient get gradientPastelCloud => const LinearGradient(
    colors: [
      Color(0xFFFCE7F3), // pastel pink
      Color(0xFFEDE9FE), // pastel lavender
      Color(0xFFDBEAFE), // pastel blue
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Vertical pastel gradient for page backgrounds
  LinearGradient get gradientPastelVertical => LinearGradient(
    colors: brightness == Brightness.light
        ? const [
            Color(0xFFFFFFFF),
            Color(0xFFFDF4F9), // subtle pink
            Color(0xFFF5F0FF), // subtle lavender
            Color(0xFFEEF5FF), // subtle blue
          ]
        : const [
            Color(0xFF010120),
            Color(0xFF0A0A30),
            Color(0xFF010120),
          ],
    stops: const [0.0, 0.3, 0.6, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Dawn gradient - soft pink tint
  LinearGradient get gradientDawn => const LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFDF4F9),
      Color(0xFFF5F0FF),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Brand gradient - magenta to orange (illustrations only)
  LinearGradient get gradientBrand => const LinearGradient(
    colors: [
      Color(0xFFEF2CC1),
      Color(0xFFFC4C02),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary gradient (legacy support)
  LinearGradient get gradientPrimary => LinearGradient(
    colors: [primary, softLavender],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Surface gradient - subtle pastel tint
  LinearGradient get gradientSurfacePrimary => LinearGradient(
    colors: [
      primaryContainer.withValues(alpha: 0.3),
      surface,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // DARK-BLUE-TINTED SHADOWS (not generic black)
  // ══════════════════════════════════════════════════════════════════════════

  /// Standard card shadow - dark blue tinted
  List<BoxShadow> get shadowCard => [
    BoxShadow(
      color: const Color(0xFF010120).withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Primary glow shadow
  List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: const Color(0xFF010120).withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF010120).withValues(alpha: 0.06),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  /// Elevated shadow for floating elements
  List<BoxShadow> get shadowElevated => [
    BoxShadow(
      color: const Color(0xFF010120).withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF010120).withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Lavender accent shadow
  List<BoxShadow> get shadowLavender => [
    BoxShadow(
      color: const Color(0xFFBDBBFF).withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Magenta accent shadow (for special elements)
  List<BoxShadow> get shadowMagenta => [
    BoxShadow(
      color: const Color(0xFFEF2CC1).withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Legacy shadows (mapped to new system)
  List<BoxShadow> get shadowSecondary => shadowLavender;
  List<BoxShadow> get shadowTertiary => shadowMagenta;

  // ══════════════════════════════════════════════════════════════════════════
  // GLASS EFFECTS
  // ══════════════════════════════════════════════════════════════════════════

  /// Glass Light - frosted glass on dark surfaces
  Color get glassLight => const Color(0xFFFFFFFF).withValues(alpha: 0.12);

  /// Glass Dark - subtle tint on light surfaces
  Color get glassDark => const Color(0xFF000000).withValues(alpha: 0.08);

  /// Frosted overlay
  Color get frostedOverlay => brightness == Brightness.light
      ? const Color(0xFFFFFFFF).withValues(alpha: 0.85)
      : const Color(0xFF010120).withValues(alpha: 0.85);

  /// Dark scrim
  Color get darkScrim => const Color(0xFF010120).withValues(alpha: 0.55);

  /// Light scrim
  Color get lightScrim => const Color(0xFF010120).withValues(alpha: 0.08);

  // ══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Secondary text color
  Color get textSecondary => onSurface.withValues(alpha: 0.7);

  /// Tertiary text color
  Color get textTertiary => onSurface.withValues(alpha: 0.5);

  // ══════════════════════════════════════════════════════════════════════════
  // TINTED SURFACES
  // ══════════════════════════════════════════════════════════════════════════

  /// Card with subtle lavender tint
  Color get surfaceTintedPrimary =>
      Color.lerp(surfaceContainerLowest, pastelLavender, 0.08)!;

  /// Card with subtle pink tint
  Color get surfaceTintedSecondary =>
      Color.lerp(surfaceContainerLowest, pastelPink, 0.08)!;

  /// Card with subtle blue tint
  Color get surfaceTintedTertiary =>
      Color.lerp(surfaceContainerLowest, pastelBlue, 0.08)!;

  // Legacy gradients (mapped to new system)
  LinearGradient get gradientWarm => gradientPastelCloud;
  LinearGradient get gradientSunset => gradientBrand;
  LinearGradient get gradientCool => gradientPastelCloud;
  LinearGradient get gradientRich => gradientPastelVertical;
  LinearGradient get gradientBackground => gradientPastelVertical;
  LinearGradient get gradientSurfaceSecondary => gradientSurfacePrimary;
  LinearGradient get gradientSurfaceTertiary => gradientSurfacePrimary;
}

/// Together AI Semantic Colors
class TogetherSemanticColors {
  TogetherSemanticColors._();

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
}
