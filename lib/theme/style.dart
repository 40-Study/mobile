import 'package:flutter/material.dart';

/// Together AI Design System
/// Pastel gradients + sharp geometry + midnight blue dark mode
class MaterialTheme {
  const MaterialTheme(this.textTheme);

  final TextTheme textTheme;

  // ══════════════════════════════════════════════════════════════════════════
  // TOGETHER AI COLORS
  // ══════════════════════════════════════════════════════════════════════════

  /// Brand Magenta - for illustrations only
  static const brandMagenta = Color(0xFFEF2CC1);

  /// Brand Orange - for illustrations only
  static const brandOrange = Color(0xFFFC4C02);

  /// Dark Blue - primary dark surface (midnight blue)
  static const darkBlue = Color(0xFF010120);

  /// Soft Lavender - accent
  static const softLavender = Color(0xFFBDBBFF);

  // ══════════════════════════════════════════════════════════════════════════
  // LIGHT SCHEME - Together AI
  // ══════════════════════════════════════════════════════════════════════════

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,

      // Primary: Dark Blue (CTA buttons)
      primary: darkBlue,
      surfaceTint: darkBlue,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFEDE9FE), // pastel lavender
      onPrimaryContainer: darkBlue,
      inversePrimary: softLavender,

      // Secondary: Soft Lavender
      secondary: softLavender,
      onSecondary: darkBlue,
      secondaryContainer: Color(0xFFF5F3FF),
      onSecondaryContainer: darkBlue,

      // Tertiary: Brand Magenta (subtle use)
      tertiary: brandMagenta,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFCE7F3), // pastel pink
      onTertiaryContainer: Color(0xFF4A0E2C),

      // Error
      error: Color(0xFFEF4444),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF7F1D1D),

      // Surfaces: Pure White
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      onSurfaceVariant: Color(0xFF6B7280), // gray-500
      outline: Color(0x14000000), // 8% black border
      outlineVariant: Color(0x0A000000), // 4% black

      // System
      shadow: darkBlue, // dark-blue tinted shadow
      scrim: darkBlue,
      inverseSurface: darkBlue,

      // Surface containers
      surfaceDim: Color(0xFFF9FAFB),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFAFAFA),
      surfaceContainer: Color(0xFFF5F5F5),
      surfaceContainerHigh: Color(0xFFEFEFEF),
      surfaceContainerHighest: Color(0xFFE5E5E5),

      // Fixed variants
      primaryFixed: Color(0xFFEDE9FE),
      onPrimaryFixed: darkBlue,
      primaryFixedDim: darkBlue,
      onPrimaryFixedVariant: Color(0xFFFFFFFF),
      secondaryFixed: softLavender,
      onSecondaryFixed: darkBlue,
      secondaryFixedDim: Color(0xFF9997E6),
      onSecondaryFixedVariant: Color(0xFFFFFFFF),
      tertiaryFixed: Color(0xFFFCE7F3),
      onTertiaryFixed: Color(0xFF4A0E2C),
      tertiaryFixedDim: brandMagenta,
      onTertiaryFixedVariant: Color(0xFFFFFFFF),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DARK SCHEME - Together AI (Midnight Blue)
  // ══════════════════════════════════════════════════════════════════════════

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,

      // Primary: Soft Lavender on dark
      primary: softLavender,
      surfaceTint: softLavender,
      onPrimary: darkBlue,
      primaryContainer: Color(0xFF1A1A40),
      onPrimaryContainer: softLavender,
      inversePrimary: darkBlue,

      // Secondary
      secondary: Color(0xFFD4D2FF),
      onSecondary: darkBlue,
      secondaryContainer: Color(0xFF2A2A50),
      onSecondaryContainer: Color(0xFFEDE9FE),

      // Tertiary: Brand Magenta
      tertiary: Color(0xFFF472B6), // lighter magenta
      onTertiary: darkBlue,
      tertiaryContainer: Color(0xFF4A0E2C),
      onTertiaryContainer: Color(0xFFFCE7F3),

      // Error
      error: Color(0xFFF87171),
      onError: Color(0xFF7F1D1D),
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFEE2E2),

      // Surfaces: Dark Blue (NOT gray-black)
      surface: darkBlue,
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFF9CA3AF), // gray-400
      outline: Color(0x1FFFFFFF), // 12% white border
      outlineVariant: Color(0x14FFFFFF), // 8% white

      // System
      shadow: Color(0xFF000010),
      scrim: Color(0xFF000010),
      inverseSurface: Color(0xFFFFFFFF),

      // Surface containers: layered midnight blue
      surfaceDim: darkBlue,
      surfaceBright: Color(0xFF0A0A30),
      surfaceContainerLowest: Color(0xFF000015),
      surfaceContainerLow: Color(0xFF050525),
      surfaceContainer: Color(0xFF0A0A35),
      surfaceContainerHigh: Color(0xFF151545),
      surfaceContainerHighest: Color(0xFF202055),

      // Fixed variants
      primaryFixed: softLavender,
      onPrimaryFixed: darkBlue,
      primaryFixedDim: Color(0xFF9997E6),
      onPrimaryFixedVariant: Color(0xFFEDE9FE),
      secondaryFixed: Color(0xFFD4D2FF),
      onSecondaryFixed: darkBlue,
      secondaryFixedDim: Color(0xFFB0ADFF),
      onSecondaryFixedVariant: Color(0xFFEDE9FE),
      tertiaryFixed: Color(0xFFF472B6),
      onTertiaryFixed: Color(0xFF4A0E2C),
      tertiaryFixedDim: brandMagenta,
      onTertiaryFixedVariant: Color(0xFFFCE7F3),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // THEME BUILDER
  // ══════════════════════════════════════════════════════════════════════════

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    dividerColor: colorScheme.outline,

    // AppBar - clean, minimal
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
      ),
    ),

    // Cards - sharp radius (8px), dark-blue shadow
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // comfortable radius
        side: BorderSide(color: colorScheme.outline),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
      ),
    ),

    // Input - sharp radius (4px)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4), // sharp radius
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),

    // Buttons - sharp radius (4px)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // FilledButton - dark solid
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 44),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),

    // Chips/Badges - sharp radius (4px)
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: colorScheme.outline),
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.surface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Bottom Navigation
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
