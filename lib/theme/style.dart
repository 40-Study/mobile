import 'package:flutter/material.dart';

class MaterialTheme {
  const MaterialTheme(this.textTheme);

  final TextTheme textTheme;

  /// Light scheme — blue + white, clean & modern
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,

      // ── Primary: Blue-600 ──
      primary: Color(0xff2563eb), // blue-600 — vivid, confident
      surfaceTint: Color(0xff2563eb),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffdbeafe), // blue-100
      onPrimaryContainer: Color(0xff1e3a5f), // blue-950
      inversePrimary: Color(0xff60a5fa), // blue-400

      // ── Secondary: Emerald-500 ──
      secondary: Color(0xff10b981), // emerald-500 — fresh, growth
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd1fae5), // emerald-100
      onSecondaryContainer: Color(0xff064e3b), // emerald-900

      // ── Tertiary: Amber-500 ──
      tertiary: Color(0xfff59e0b), // amber-500 — warm accent
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfffef3c7), // amber-100
      onTertiaryContainer: Color(0xff451a03), // amber-950

      // ── Error: Red-500 ──
      error: Color(0xffef4444),
      onError: Color(0xffffffff),
      errorContainer: Color(0xfffee2e2),
      onErrorContainer: Color(0xff7f1d1d),

      // ── Surfaces: Blue-tinted white for depth ──
      surface: Color(0xfff6f9ff), // blue-tinted white
      onSurface: Color(0xff111827), // gray-900
      onSurfaceVariant: Color(0xff4b5563), // gray-600
      outline: Color(0xffdce5f5), // blue-tinted border
      outlineVariant: Color(0xffc4d1e8), // deeper blue-tint

      // ── System ──
      shadow: Color(0xff0c1929), // deep blue shadow
      scrim: Color(0xff081422),
      inverseSurface: Color(0xff172554), // blue-950

      // ── Fixed variants ──
      primaryFixed: Color(0xffdbeafe),
      onPrimaryFixed: Color(0xff1e3a5f),
      primaryFixedDim: Color(0xff2563eb),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffd1fae5),
      onSecondaryFixed: Color(0xff064e3b),
      secondaryFixedDim: Color(0xff10b981),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xfffef3c7),
      onTertiaryFixed: Color(0xff451a03),
      tertiaryFixedDim: Color(0xfff59e0b),
      onTertiaryFixedVariant: Color(0xffffffff),

      // ── Surface containers: layered blue tints ──
      surfaceDim: Color(0xffdce5f5), // tinted dim
      surfaceBright: Color(0xfff6f9ff), // tinted bright
      surfaceContainerLowest: Color(0xffffffff), // card bg — pure white
      surfaceContainerLow: Color(0xffeef3fc), // subtle blue wash
      surfaceContainer: Color(0xffe3ebf7), // medium tint
      surfaceContainerHigh: Color(0xffd0dbee), // stronger tint
      surfaceContainerHighest: Color(0xff94a3b8), // muted blue-gray
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  /// Dark scheme — matching blue palette for dark mode
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,

      // ── Primary: Blue ──
      primary: Color(0xff60a5fa), // blue-400
      surfaceTint: Color(0xff60a5fa),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff1e40af), // blue-800
      onPrimaryContainer: Color(0xffdbeafe),
      inversePrimary: Color(0xff2563eb), // blue-600

      // ── Secondary: Emerald ──
      secondary: Color(0xff34d399), // emerald-400
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff065f46), // emerald-800
      onSecondaryContainer: Color(0xffd1fae5),

      // ── Tertiary: Amber ──
      tertiary: Color(0xfffbbf24), // amber-400
      onTertiary: Color(0xff1c1917),
      tertiaryContainer: Color(0xff92400e), // amber-800
      onTertiaryContainer: Color(0xfffef3c7),

      // ── Error ──
      error: Color(0xffef4444),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff7f1d1d),
      onErrorContainer: Color(0xfffee2e2),

      // ── Surfaces: Deep blue-tinted ──
      surface: Color(0xff0b1120), // deep blue-black
      onSurface: Color(0xfff0f4ff), // warm white with blue tint
      onSurfaceVariant: Color(0xff94a3b8), // muted blue-gray
      outline: Color(0xff1c2840), // blue-tinted border
      outlineVariant: Color(0xff2a3a55), // deeper tint

      // ── System ──
      shadow: Color(0xff040a15),
      scrim: Color(0xff040a15),
      inverseSurface: Color(0xffdbeafe), // blue-100

      // ── Fixed variants ──
      primaryFixed: Color(0xff60a5fa),
      onPrimaryFixed: Color(0xff1e3a5f),
      primaryFixedDim: Color(0xff3b82f6), // blue-500
      onPrimaryFixedVariant: Color(0xffdbeafe),
      secondaryFixed: Color(0xff34d399),
      onSecondaryFixed: Color(0xff064e3b),
      secondaryFixedDim: Color(0xff059669), // emerald-600
      onSecondaryFixedVariant: Color(0xffd1fae5),
      tertiaryFixed: Color(0xfffbbf24),
      onTertiaryFixed: Color(0xff451a03),
      tertiaryFixedDim: Color(0xffd97706), // amber-600
      onTertiaryFixedVariant: Color(0xfffef3c7),

      // ── Surface containers: layered deep blue ──
      surfaceDim: Color(0xff0b1120),
      surfaceBright: Color(0xff101828),
      surfaceContainerLowest: Color(0xff0b1120),
      surfaceContainerLow: Color(0xff121d30), // subtle lift
      surfaceContainer: Color(0xff1a2742), // medium depth
      surfaceContainerHigh: Color(0xff243352), // elevated
      surfaceContainerHighest: Color(0xff354766), // highest
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

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
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.surface,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
