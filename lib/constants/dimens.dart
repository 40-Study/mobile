import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  LAYOUT GRID — Mobile 8pt Grid System
// ═══════════════════════════════════════════════════════════════

/// 8-point spacing scale used across the entire app.
///
/// Based on Material Design 8dp grid:
/// - Use multiples of 4 for fine adjustments (xs, sm)
/// - Use multiples of 8 for standard spacing (md, lg, xl…)
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;
}

/// Screen-level layout constants following mobile grid conventions.
///
/// Default mobile grid: 4 columns, 16dp margin, 16dp gutter.
abstract final class AppLayout {
  /// Horizontal margin for screen content (left + right padding).
  static const double screenMargin = 20;

  /// Gutter between columns / cards in a row.
  static const double gutter = 12;

  /// Standard content padding for list views.
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenMargin,
    vertical: AppSpacing.lg,
  );

  /// Dashboard list padding (extra bottom for FAB / nav bar clearance).
  static const EdgeInsets dashboardPadding = EdgeInsets.fromLTRB(
    screenMargin,
    AppSpacing.lg,
    screenMargin,
    AppSpacing.xxxl,
  );

  /// Padding inside cards.
  static const EdgeInsets cardPadding = EdgeInsets.all(AppSpacing.lg);

  /// Compact card padding.
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(AppSpacing.md);

  /// Dialog content padding.
  static const EdgeInsets dialogPadding = EdgeInsets.all(AppSpacing.xl);
}

/// Corner radius tokens following a consistent scale.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 20;
  static const double xxxl = 24;
  static const double full = 999;

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius borderXxxl =
      BorderRadius.all(Radius.circular(xxxl));
}

/// Icon size tokens.
abstract final class AppIconSize {
  static const double xs = 14;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 28;
  static const double xxl = 32;
  static const double avatar = 40;
  static const double hero = 48;
}

// ═══════════════════════════════════════════════════════════════
//  LEGACY — kept for backward compatibility, prefer new tokens
// ═══════════════════════════════════════════════════════════════

class Margins {
  Margins._();

  static const double minimum = 8.0;
  static const double normal = 16.0;
}

class Paddings {
  Paddings._();

  static const double minimum = 8.0;
  static const double normal = 16.0;
  static const double content = 32.0;
  static const double kDialogContentPadding = 20.0;
}

class IconSizes {
  IconSizes._();

  static const double avatar = 40.0;
  static const double settingsItem = 20.0;
  static const double themeDialogIconSize = 22.0;
}

class ContainerSizes {
  ContainerSizes._();

  static const double kAttachmentHeight = 24.0;
}

class FontSizes {
  FontSizes._();

  static const double subtitle2 = 14.0;
  static const double subtitle1 = 16.0;
  static const double label = 18.0;
  static const double subheading = 20.0;
  static const double headline1 = 90.0;
  static const double headline2 = 60.0;
  static const double headline3 = 48.0;
  static const double headline4 = 34.0;
  static const double headline5 = 24.0;
  static const double headline6 = 20.0;
}

class RadiusSize {
  RadiusSize._();

  static const double kAttachmentBorderRadius = 30.0;
  static const kDialogCornerRadius = 25.0;

  static const popupMenuBorderRadius = 6.0;
}

class UiSize {
  UiSize._();

  static const double calendarTileHeight = 150;
  static const double bottomSheetTopIconWidth = 42;
  static const double bottomSheetTopIconHeight = 15;
}

class Space {
  Space._();

  static const superLarge = 24.0;
  static const large = 16.0;

  static const medium = 12.0;
  static const mediumSmall = 8.0;

  static const small = 6.0;
  static const superSmall = 4.0;
}
