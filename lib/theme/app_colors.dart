import 'package:flutter/material.dart';

/// Together AI Design System - Professional Blue & White Theme
///
/// Clean, minimal design với xanh dương làm màu chủ đạo.
/// Sử dụng các sắc thái của xanh + trắng cho giao diện chuyên nghiệp.
extension TogetherColorsX on ColorScheme {
  // ══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS - Professional Blue Palette
  // ══════════════════════════════════════════════════════════════════════════

  /// Brand Blue - màu chủ đạo
  Color get brandBlue => const Color(0xFF2563EB);

  /// Brand Blue Dark - cho text và accent
  Color get brandBlueDark => const Color(0xFF1E40AF);

  /// Brand Blue Light - cho backgrounds
  Color get brandBlueLight => const Color(0xFF3B82F6);

  /// Soft Blue accent - nhẹ nhàng hơn
  Color get softBlue => const Color(0xFF93C5FD);

  /// Navy - cho text đậm
  Color get navy => const Color(0xFF1E3A5F);

  // ══════════════════════════════════════════════════════════════════════════
  // BLUE TINTS - Các sắc thái xanh nhạt
  // ══════════════════════════════════════════════════════════════════════════

  /// Blue 50 - rất nhạt
  Color get blue50 => const Color(0xFFEFF6FF);

  /// Blue 100 - nhạt
  Color get blue100 => const Color(0xFFDBEAFE);

  /// Blue 200 - trung bình nhạt
  Color get blue200 => const Color(0xFFBFDBFE);

  /// Blue 300 - trung bình
  Color get blue300 => const Color(0xFF93C5FD);

  /// Blue 400
  Color get blue400 => const Color(0xFF60A5FA);

  /// Blue 500 - main
  Color get blue500 => const Color(0xFF3B82F6);

  /// Blue 600
  Color get blue600 => const Color(0xFF2563EB);

  /// Blue 700
  Color get blue700 => const Color(0xFF1D4ED8);

  // ══════════════════════════════════════════════════════════════════════════
  // NEUTRAL COLORS - Xám trung tính
  // ══════════════════════════════════════════════════════════════════════════

  /// Slate 50 - background sáng
  Color get slate50 => const Color(0xFFF8FAFC);

  /// Slate 100
  Color get slate100 => const Color(0xFFF1F5F9);

  /// Slate 200
  Color get slate200 => const Color(0xFFE2E8F0);

  /// Slate 300
  Color get slate300 => const Color(0xFFCBD5E1);

  /// Slate 400
  Color get slate400 => const Color(0xFF94A3B8);

  /// Slate 500
  Color get slate500 => const Color(0xFF64748B);

  /// Slate 600
  Color get slate600 => const Color(0xFF475569);

  /// Slate 700
  Color get slate700 => const Color(0xFF334155);

  /// Slate 800
  Color get slate800 => const Color(0xFF1E293B);

  /// Slate 900
  Color get slate900 => const Color(0xFF0F172A);

  // ══════════════════════════════════════════════════════════════════════════
  // GRADIENTS - Soft & Subtle
  // ══════════════════════════════════════════════════════════════════════════

  /// Primary gradient - nhẹ nhàng
  LinearGradient get gradientBluePrimary => const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft gradient - cho cards, rất nhẹ
  LinearGradient get gradientBlueSoft => const LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF93C5FD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light gradient - gần như trắng với hint xanh
  LinearGradient get gradientBlueLight => LinearGradient(
    colors: brightness == Brightness.light
        ? const [Color(0xFFFFFFFF), Color(0xFFFAFCFF)]
        : const [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Page background - rất subtle
  LinearGradient get gradientPastelVertical => LinearGradient(
    colors: brightness == Brightness.light
        ? const [Color(0xFFFFFFFF), Color(0xFFFCFDFF)]
        : const [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Primary gradient (alias)
  LinearGradient get gradientPrimary => gradientBlueSoft;

  /// Surface gradient - subtle tint
  LinearGradient get gradientSurfacePrimary => LinearGradient(
    colors: [
      blue50.withValues(alpha: 0.5),
      surface,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Legacy aliases
  LinearGradient get gradientPastelCloud => gradientBlueLight;
  LinearGradient get gradientBrand => gradientBluePrimary;
  LinearGradient get gradientWarm => gradientBlueSoft;
  LinearGradient get gradientSunset => gradientBluePrimary;
  LinearGradient get gradientCool => gradientBlueLight;
  LinearGradient get gradientRich => gradientPastelVertical;
  LinearGradient get gradientBackground => gradientPastelVertical;
  LinearGradient get gradientSurfaceSecondary => gradientSurfacePrimary;
  LinearGradient get gradientSurfaceTertiary => gradientSurfacePrimary;
  LinearGradient get gradientDawn => gradientBlueLight;

  // ══════════════════════════════════════════════════════════════════════════
  // SHADOWS - Professional Blue-tinted Shadows
  // ══════════════════════════════════════════════════════════════════════════

  /// Standard card shadow
  List<BoxShadow> get shadowCard => [
    BoxShadow(
      color: const Color(0xFF1E3A5F).withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Primary glow shadow
  List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1E3A5F).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Elevated shadow
  List<BoxShadow> get shadowElevated => [
    BoxShadow(
      color: const Color(0xFF1E3A5F).withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1E3A5F).withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Blue accent shadow
  List<BoxShadow> get shadowBlue => [
    BoxShadow(
      color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Legacy shadow aliases
  List<BoxShadow> get shadowLavender => shadowBlue;
  List<BoxShadow> get shadowMagenta => shadowBlue;
  List<BoxShadow> get shadowSecondary => shadowBlue;
  List<BoxShadow> get shadowTertiary => shadowBlue;

  // ══════════════════════════════════════════════════════════════════════════
  // GLASS EFFECTS
  // ══════════════════════════════════════════════════════════════════════════

  Color get glassLight => const Color(0xFFFFFFFF).withValues(alpha: 0.15);
  Color get glassDark => const Color(0xFF1E3A5F).withValues(alpha: 0.08);

  Color get frostedOverlay => brightness == Brightness.light
      ? const Color(0xFFFFFFFF).withValues(alpha: 0.9)
      : const Color(0xFF0F172A).withValues(alpha: 0.9);

  Color get darkScrim => const Color(0xFF0F172A).withValues(alpha: 0.6);
  Color get lightScrim => const Color(0xFF1E3A5F).withValues(alpha: 0.08);

  // ══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ══════════════════════════════════════════════════════════════════════════

  Color get textSecondary => onSurface.withValues(alpha: 0.7);
  Color get textTertiary => onSurface.withValues(alpha: 0.5);

  // ══════════════════════════════════════════════════════════════════════════
  // TINTED SURFACES
  // ══════════════════════════════════════════════════════════════════════════

  /// Card with subtle blue tint
  Color get surfaceTintedPrimary =>
      Color.lerp(surfaceContainerLowest, blue100, 0.1)!;

  Color get surfaceTintedSecondary =>
      Color.lerp(surfaceContainerLowest, blue50, 0.15)!;

  Color get surfaceTintedTertiary =>
      Color.lerp(surfaceContainerLowest, slate100, 0.1)!;

  // ══════════════════════════════════════════════════════════════════════════
  // LEGACY ALIASES - Backward compatibility
  // ══════════════════════════════════════════════════════════════════════════

  // Old brand colors → new blue palette
  Color get brandMagenta => brandBlue;
  Color get brandOrange => brandBlueLight;
  Color get softLavender => softBlue;
  Color get darkBlue => navy;

  // Old pastel colors → blue tints
  Color get pastelPink => blue50;
  Color get pastelLavender => blue100;
  Color get pastelBlue => blue200;
  Color get pastelCyan => blue100;
}

/// Semantic Colors - Status indicators
class TogetherSemanticColors {
  TogetherSemanticColors._();

  static const success = Color(0xFF10B981); // Green
  static const warning = Color(0xFFF59E0B); // Amber
  static const error = Color(0xFFEF4444);   // Red
  static const info = Color(0xFF3B82F6);    // Blue (matches brand)
}

/// Role Colors - Professional Blue variations for each role
class RoleColors {
  RoleColors._();

  // Student - Primary Blue
  static const studentPrimary = Color(0xFF2563EB);
  static const studentSecondary = Color(0xFF93C5FD);

  // Teacher - Darker Blue
  static const teacherPrimary = Color(0xFF1E40AF);
  static const teacherSecondary = Color(0xFF60A5FA);

  // Parent - Teal Blue
  static const parentPrimary = Color(0xFF0891B2);
  static const parentSecondary = Color(0xFF67E8F9);

  // Organization - Navy
  static const orgPrimary = Color(0xFF1E3A5F);
  static const orgSecondary = Color(0xFF38BDF8);
}
