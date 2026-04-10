import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Poppins - elegant, modern font
const _defaultFontName = 'Poppins';

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

  // Tăng kích thước chữ cho dễ đọc hơn
  final textTheme = displayTextTheme.copyWith(
    displayLarge: displayTextTheme.displayLarge?.copyWith(
      fontSize: 60,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
    ),
    displayMedium: displayTextTheme.displayMedium?.copyWith(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    displaySmall: displayTextTheme.displaySmall?.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: displayTextTheme.headlineLarge?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: displayTextTheme.headlineMedium?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: displayTextTheme.headlineSmall?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: displayTextTheme.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: displayTextTheme.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: displayTextTheme.titleSmall?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: bodyTextTheme.bodyLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
    bodyMedium: bodyTextTheme.bodyMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: bodyTextTheme.bodySmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: bodyTextTheme.labelLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: bodyTextTheme.labelMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: bodyTextTheme.labelSmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );
  return textTheme;
}
