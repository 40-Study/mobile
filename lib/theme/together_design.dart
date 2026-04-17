import 'package:flutter/material.dart';

/// Together AI Design System
///
/// A pastel-gradient dreamscape with sharp geometry and
/// midnight blue dark mode. Optimistic and enterprise-ready.
class TogetherColors {
  TogetherColors._();

  // ══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS (for illustrations only, NOT UI chrome)
  // ══════════════════════════════════════════════════════════════════════════

  /// Brand Magenta - primary brand accent for illustrations
  static const brandMagenta = Color(0xFFEF2CC1);

  /// Brand Orange - secondary brand accent for gradients
  static const brandOrange = Color(0xFFFC4C02);

  // ══════════════════════════════════════════════════════════════════════════
  // PRIMARY COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Dark Blue - primary dark surface (midnight blue, NOT gray-black)
  static const darkBlue = Color(0xFF010120);

  /// Soft Lavender - gentle blue-violet accent
  static const softLavender = Color(0xFFBDBBFF);

  /// Pure White
  static const pureWhite = Color(0xFFFFFFFF);

  /// Pure Black
  static const pureBlack = Color(0xFF000000);

  // ══════════════════════════════════════════════════════════════════════════
  // PASTEL GRADIENTS (for hero/decorative backgrounds)
  // ══════════════════════════════════════════════════════════════════════════

  /// Soft Pink for pastel gradients
  static const pastelPink = Color(0xFFFCE7F3);

  /// Soft Lavender for pastel gradients
  static const pastelLavender = Color(0xFFEDE9FE);

  /// Soft Blue for pastel gradients
  static const pastelBlue = Color(0xFFDBEAFE);

  /// Soft Cyan for pastel gradients
  static const pastelCyan = Color(0xFFCFFAFE);

  // ══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Success Green
  static const success = Color(0xFF10B981);

  /// Warning Amber
  static const warning = Color(0xFFF59E0B);

  /// Error Red
  static const error = Color(0xFFEF4444);

  /// Info Blue
  static const info = Color(0xFF3B82F6);

  // ══════════════════════════════════════════════════════════════════════════
  // GLASS EFFECTS
  // ══════════════════════════════════════════════════════════════════════════

  /// Glass Light - frosted glass on dark surfaces
  static Color get glassLight => pureWhite.withValues(alpha: 0.12);

  /// Glass Dark - subtle tinted surfaces on light
  static Color get glassDark => pureBlack.withValues(alpha: 0.08);

  /// Border Light - borders on light surfaces
  static Color get borderLight => pureBlack.withValues(alpha: 0.08);

  /// Border Dark - borders on dark surfaces
  static Color get borderDark => pureWhite.withValues(alpha: 0.12);

  // ══════════════════════════════════════════════════════════════════════════
  // SHADOWS
  // ══════════════════════════════════════════════════════════════════════════

  /// Dark blue tinted shadow color
  static Color get shadowColor => const Color(0xFF010120).withValues(alpha: 0.1);

  /// Standard card shadow - dark blue tinted
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadowColor,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Elevated shadow for floating elements
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: shadowColor,
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF010120).withValues(alpha: 0.05),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];
}

/// Together AI Gradients
class TogetherGradients {
  TogetherGradients._();

  /// Hero pastel gradient - pink to lavender to blue (decorative)
  static const pastelCloud = LinearGradient(
    colors: [
      TogetherColors.pastelPink,
      TogetherColors.pastelLavender,
      TogetherColors.pastelBlue,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Vertical pastel gradient for page backgrounds
  static const pastelVertical = LinearGradient(
    colors: [
      TogetherColors.pureWhite,
      TogetherColors.pastelPink,
      TogetherColors.pastelLavender,
      TogetherColors.pastelBlue,
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Soft dawn gradient - white to pink tint
  static const dawn = LinearGradient(
    colors: [
      TogetherColors.pureWhite,
      Color(0xFFFDF4F9), // very subtle pink
      Color(0xFFF5F0FF), // very subtle lavender
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Brand gradient - magenta to orange (for illustrations only)
  static const brand = LinearGradient(
    colors: [
      TogetherColors.brandMagenta,
      TogetherColors.brandOrange,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark mode gradient
  static const darkMode = LinearGradient(
    colors: [
      TogetherColors.darkBlue,
      Color(0xFF020235), // slightly lighter dark blue
      TogetherColors.darkBlue,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Lavender accent gradient
  static const lavenderAccent = LinearGradient(
    colors: [
      TogetherColors.softLavender,
      Color(0xFFD4D2FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Together AI Border Radius constants
/// Sharp geometry - no pills, no generous rounding
class TogetherRadius {
  TogetherRadius._();

  /// Sharp radius for buttons, badges, tags (4px)
  static const double sharp = 4.0;

  /// Comfortable radius for larger containers (8px)
  static const double comfortable = 8.0;

  /// Sharp border radius
  static final sharpBorder = BorderRadius.circular(sharp);

  /// Comfortable border radius
  static final comfortableBorder = BorderRadius.circular(comfortable);
}

/// Together AI Spacing constants
class TogetherSpacing {
  TogetherSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double section = 80.0;
}
