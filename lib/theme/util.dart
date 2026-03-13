import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Web dùng Inter làm font sans chính (tailwind.config.ts).
const _defaultFontName = 'Inter';

TextTheme createTextTheme({
  required BuildContext context,
  String bodyFontString = _defaultFontName,
  String displayFontString = _defaultFontName,
}) {
  final baseTextTheme = Theme.of(context).textTheme;
  final bodyTextTheme = GoogleFonts.getTextTheme(bodyFontString, baseTextTheme);
  final displayTextTheme =
      GoogleFonts.getTextTheme(displayFontString, baseTextTheme);
  final textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}
