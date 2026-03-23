import 'package:flutter/material.dart';

/// Builder type cho custom illustration widget.
typedef OnboardingIllustrationBuilder =
    Widget Function(BuildContext context, {required bool isActive});

/// Dữ liệu cho một trang onboarding. Hỗ trợ custom illustration, highlight text.
@immutable
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.imagePath,
    this.illustrationBuilder,
    this.highlightText,
    this.buttonLabel,
  });

  /// Tiêu đề trang (có thể chứa phần highlight).
  final String title;

  /// Mô tả phụ.
  final String subtitle;

  /// Icon fallback nếu không có illustration.
  final IconData? icon;

  /// Đường dẫn ảnh (nếu dùng asset).
  final String? imagePath;

  /// Builder cho custom illustration widget.
  final OnboardingIllustrationBuilder? illustrationBuilder;

  /// Phần text trong title cần highlight màu primary.
  final String? highlightText;

  /// Label cho nút CTA (null = "Tiếp theo", trang cuối thường là "Bắt đầu").
  final String? buttonLabel;

  /// Kiểm tra có custom illustration không.
  bool get hasCustomIllustration => illustrationBuilder != null;
}
