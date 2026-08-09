import 'package:flutter/widgets.dart';

/// Design System - Spacing constants
abstract class AppSpacing {
  // Base spacing scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double section = 64;
  static const double hero = 80;

  // Semantic spacing
  static const double cardPadding = 16;
  static const double screenPadding = 24;
  static const double listItemSpacing = 12;
  static const double sectionSpacing = 32;

  // Gap helpers
  static const gap4 = SizedBox.square(dimension: xs);
  static const gap8 = SizedBox.square(dimension: sm);
  static const gap12 = SizedBox.square(dimension: md);
  static const gap16 = SizedBox.square(dimension: lg);
  static const gap24 = SizedBox.square(dimension: xl);
  static const gap32 = SizedBox.square(dimension: xxl);
  static const gap48 = SizedBox.square(dimension: xxxl);

  // Horizontal gaps
  static const hGap4 = SizedBox(width: xs);
  static const hGap8 = SizedBox(width: sm);
  static const hGap12 = SizedBox(width: md);
  static const hGap16 = SizedBox(width: lg);
  static const hGap24 = SizedBox(width: xl);
  static const hGap32 = SizedBox(width: xxl);

  // Vertical gaps
  static const vGap4 = SizedBox(height: xs);
  static const vGap8 = SizedBox(height: sm);
  static const vGap12 = SizedBox(height: md);
  static const vGap16 = SizedBox(height: lg);
  static const vGap24 = SizedBox(height: xl);
  static const vGap32 = SizedBox(height: xxl);
  static const vGap48 = SizedBox(height: xxxl);

  // Padding helpers
  static const paddingXs = EdgeInsets.all(xs);
  static const paddingSm = EdgeInsets.all(sm);
  static const paddingMd = EdgeInsets.all(md);
  static const paddingLg = EdgeInsets.all(lg);
  static const paddingXl = EdgeInsets.all(xl);
  static const paddingXxl = EdgeInsets.all(xxl);

  // Horizontal padding
  static const paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);

  // Screen padding
  static const paddingScreen = EdgeInsets.symmetric(horizontal: screenPadding);
  static const paddingScreenAll = EdgeInsets.all(screenPadding);
}
