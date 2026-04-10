import 'package:flutter/material.dart';

/// Extended color utilities that build on top of [ColorScheme].
///
/// Provides gradient presets, tinted surfaces, glow shadows, and
/// semantic helpers to create visual depth beyond flat color tokens.
extension AppColorsX on ColorScheme {
  // ── Gradient Presets ───────────────────────────────────────────

  /// Hero gradient: bold primary diagonal.
  LinearGradient get gradientPrimary => LinearGradient(
    colors: [primary, inversePrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warm gradient: secondary to primary (emerald → blue).
  LinearGradient get gradientWarm => LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sunset gradient: tertiary to secondary (amber → emerald).
  LinearGradient get gradientSunset => LinearGradient(
    colors: [tertiary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cool gradient: primary to tertiary (blue → amber).
  LinearGradient get gradientCool => LinearGradient(
    colors: [primary, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Multi-stop rich gradient within the blue family for hero surfaces.
  LinearGradient get gradientRich => LinearGradient(
    colors: [
      primary,
      Color.lerp(primary, inversePrimary, 0.45)!,
      inversePrimary,
    ],
    stops: const [0.0, 0.55, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle surface gradient for section backgrounds.
  LinearGradient get gradientSurfacePrimary => LinearGradient(
    colors: [
      primaryContainer.withValues(alpha: 0.4),
      surface,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Secondary tinted surface gradient.
  LinearGradient get gradientSurfaceSecondary => LinearGradient(
    colors: [
      secondaryContainer.withValues(alpha: 0.3),
      surface,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Tertiary tinted surface gradient.
  LinearGradient get gradientSurfaceTertiary => LinearGradient(
    colors: [
      tertiaryContainer.withValues(alpha: 0.3),
      surface,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Full-screen background gradient for main screens.
  LinearGradient get gradientBackground => LinearGradient(
    colors: [
      surfaceContainerLowest,
      Color.lerp(surfaceContainerLowest, primaryContainer, 0.05)!,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Tinted Surfaces ────────────────────────────────────────────

  /// Card background with subtle primary tint — richer than plain white.
  Color get surfaceTintedPrimary =>
      Color.lerp(surfaceContainerLowest, primaryContainer, 0.08)!;

  /// Card background with subtle secondary tint.
  Color get surfaceTintedSecondary =>
      Color.lerp(surfaceContainerLowest, secondaryContainer, 0.10)!;

  /// Card background with subtle tertiary tint.
  Color get surfaceTintedTertiary =>
      Color.lerp(surfaceContainerLowest, tertiaryContainer, 0.10)!;

  // ── Glow Shadows ───────────────────────────────────────────────

  /// Primary glow shadow for elevated hero cards.
  List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: primary.withValues(alpha: 0.18),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.08),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  /// Secondary glow shadow.
  List<BoxShadow> get shadowSecondary => [
    BoxShadow(
      color: secondary.withValues(alpha: 0.16),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: secondary.withValues(alpha: 0.06),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];

  /// Tertiary glow shadow.
  List<BoxShadow> get shadowTertiary => [
    BoxShadow(
      color: tertiary.withValues(alpha: 0.16),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: tertiary.withValues(alpha: 0.06),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];

  /// Subtle neutral elevation for standard cards.
  List<BoxShadow> get shadowCard => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.02),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Soft elevated shadow for floating elements.
  List<BoxShadow> get shadowElevated => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.04),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  // ── Overlays & Scrims ──────────────────────────────────────────

  /// Light frosted overlay for stacked cards / overlapping content.
  Color get frostedOverlay =>
      surfaceContainerLowest.withValues(alpha: 0.85);

  /// Dark scrim for content on image/gradient backgrounds.
  Color get darkScrim => scrim.withValues(alpha: 0.55);

  /// Light scrim for subtle separation.
  Color get lightScrim => scrim.withValues(alpha: 0.08);

  // ── Text Colors ──────────────────────────────────────────────────

  /// Secondary text color with better contrast than onSurfaceVariant.
  /// Use for labels, subtitles, and descriptions that need to be readable.
  Color get textSecondary => onSurface.withValues(alpha: 0.7);

  /// Tertiary text color for hints and less important information.
  Color get textTertiary => onSurface.withValues(alpha: 0.5);
}
