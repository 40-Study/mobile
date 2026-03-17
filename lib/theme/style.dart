import 'package:flutter/material.dart';

class MaterialTheme {
  const MaterialTheme(this.textTheme);

  final TextTheme textTheme;

  /// Light scheme - mapped from web :root CSS variables & tailwind.config.ts
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff0ea5e9), // sky-500
      surfaceTint: Color(0xff0ea5e9),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffe0f2fe), // primary-100
      onPrimaryContainer: Color(0xff082f49), // primary-950
      secondary: Color(0xffa855f7), // purple-500
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfff3e8ff), // secondary-100
      onSecondaryContainer: Color(0xff3b0764), // secondary-950
      tertiary: Color(0xff22c55e), // xp green
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffdcfce7),
      onTertiaryContainer: Color(0xff052e16),
      error: Color(0xffef4444), // destructive red-500
      onError: Color(0xffffffff),
      errorContainer: Color(0xfffee2e2),
      onErrorContainer: Color(0xff7f1d1d),
      surface: Color(0xfff8fafc), // --background slate-50
      onSurface: Color(0xff0f172a), // --foreground slate-900
      onSurfaceVariant: Color(0xff475569), // --muted-foreground slate-600
      outline: Color(0xffe2e8f0), // --border slate-200
      outlineVariant: Color(0xffcbd5e1), // slate-300
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff0f172a),
      inversePrimary: Color(0xff38bdf8), // primary-400
      primaryFixed: Color(0xffe0f2fe),
      onPrimaryFixed: Color(0xff082f49),
      primaryFixedDim: Color(0xff0ea5e9),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xfff3e8ff),
      onSecondaryFixed: Color(0xff3b0764),
      secondaryFixedDim: Color(0xffa855f7),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xffdcfce7),
      onTertiaryFixed: Color(0xff052e16),
      tertiaryFixedDim: Color(0xff22c55e),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffe2e8f0), // slate-200
      surfaceBright: Color(0xfff8fafc), // slate-50
      surfaceContainerLowest: Color(0xffffffff), // --card
      surfaceContainerLow: Color(0xfff1f5f9), // --muted slate-100
      surfaceContainer: Color(0xffe2e8f0), // slate-200
      surfaceContainerHigh: Color(0xffcbd5e1), // slate-300
      surfaceContainerHighest: Color(0xff94a3b8), // slate-400
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  /// Dark scheme - mapped from web .dark CSS variables
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff0ea5e9), // sky-500
      surfaceTint: Color(0xff0ea5e9),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff075985), // primary-800
      onPrimaryContainer: Color(0xffe0f2fe),
      secondary: Color(0xffa855f7),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4c1d95), // secondary-900
      onSecondaryContainer: Color(0xfff3e8ff),
      tertiary: Color(0xff22c55e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff166534),
      onTertiaryContainer: Color(0xffbbf7d0),
      error: Color(0xffef4444),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff7f1d1d),
      onErrorContainer: Color(0xfffee2e2),
      surface: Color(0xff0f172a), // --background slate-900
      onSurface: Color(0xfff8fafc), // --foreground slate-50
      onSurfaceVariant: Color(0xff94a3b8), // --muted-foreground dark
      outline: Color(0xff1e293b), // --border/input slate-800
      outlineVariant: Color(0xff334155), // slate-700
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e7eb),
      inversePrimary: Color(0xff38bdf8),
      primaryFixed: Color(0xff0ea5e9),
      onPrimaryFixed: Color(0xff082f49),
      primaryFixedDim: Color(0xff0284c7),
      onPrimaryFixedVariant: Color(0xffe0f2fe),
      secondaryFixed: Color(0xffa855f7),
      onSecondaryFixed: Color(0xff3b0764),
      secondaryFixedDim: Color(0xff6d28d9),
      onSecondaryFixedVariant: Color(0xfff3e8ff),
      tertiaryFixed: Color(0xff22c55e),
      onTertiaryFixed: Color(0xff052e16),
      tertiaryFixedDim: Color(0xff16a34a),
      onTertiaryFixedVariant: Color(0xffbbf7d0),
      surfaceDim: Color(0xff0f172a),
      surfaceBright: Color(0xff111827),
      surfaceContainerLowest: Color(0xff0f172a),
      surfaceContainerLow: Color(0xff111827), // --muted dark
      surfaceContainer: Color(0xff1e293b), // slate-800
      surfaceContainerHigh: Color(0xff334155), // slate-700
      surfaceContainerHighest: Color(0xff475569), // slate-600
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
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
