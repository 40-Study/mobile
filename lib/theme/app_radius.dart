import 'package:flutter/widgets.dart';

/// Design System - Border Radius constants
abstract class AppRadius {
  // Base radius scale
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;

  // Semantic radius
  static const double button = xs;
  static const double input = xs;
  static const double card = sm;
  static const double dialog = md;
  static const double sheet = lg;
  static const double avatar = full;

  // BorderRadius helpers
  static final borderNone = BorderRadius.circular(none);
  static final borderXs = BorderRadius.circular(xs);
  static final borderSm = BorderRadius.circular(sm);
  static final borderMd = BorderRadius.circular(md);
  static final borderLg = BorderRadius.circular(lg);
  static final borderXl = BorderRadius.circular(xl);
  static final borderXxl = BorderRadius.circular(xxl);
  static final borderFull = BorderRadius.circular(full);

  // Semantic BorderRadius
  static final borderButton = BorderRadius.circular(button);
  static final borderInput = BorderRadius.circular(input);
  static final borderCard = BorderRadius.circular(card);
  static final borderDialog = BorderRadius.circular(dialog);
  static final borderSheet = BorderRadius.circular(sheet);
  static final borderAvatar = BorderRadius.circular(avatar);

  // Top only
  static final borderTopMd = const BorderRadius.vertical(top: Radius.circular(md));
  static final borderTopLg = const BorderRadius.vertical(top: Radius.circular(lg));
  static final borderTopXl = const BorderRadius.vertical(top: Radius.circular(xl));

  // Bottom only
  static final borderBottomMd =
      const BorderRadius.vertical(bottom: Radius.circular(md));
  static final borderBottomLg =
      const BorderRadius.vertical(bottom: Radius.circular(lg));
}
