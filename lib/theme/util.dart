import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _defaultFontName = 'Inter';

TextTheme createTextTheme({
  required BuildContext context,
  String bodyFontString = _defaultFontName,
  String displayFontString = _defaultFontName,
}) {
  final baseTextTheme = Theme.of(context).textTheme;
  final bodyTextTheme = GoogleFonts.getTextTheme(bodyFontString, baseTextTheme);
  final displayTextTheme = GoogleFonts.getTextTheme(
    displayFontString,
    baseTextTheme,
  );

  final textTheme = displayTextTheme.copyWith(
    displayLarge: displayTextTheme.displayLarge?.copyWith(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: 0,
    ),
    displayMedium: displayTextTheme.displayMedium?.copyWith(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: 0,
    ),
    displaySmall: displayTextTheme.displaySmall?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0,
    ),
    headlineLarge: displayTextTheme.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0,
    ),
    headlineMedium: displayTextTheme.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0,
    ),
    headlineSmall: displayTextTheme.headlineSmall?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
    ),
    titleLarge: displayTextTheme.titleLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: 0,
    ),
    titleMedium: displayTextTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
    ),
    titleSmall: displayTextTheme.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
    ),
    bodyLarge: bodyTextTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
    ),
    bodyMedium: bodyTextTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
    ),
    bodySmall: bodyTextTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.45,
      letterSpacing: 0,
    ),
    labelLarge: bodyTextTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
    ),
    labelMedium: bodyTextTheme.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
    ),
    labelSmall: bodyTextTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
    ),
  );
  return textTheme;
}
