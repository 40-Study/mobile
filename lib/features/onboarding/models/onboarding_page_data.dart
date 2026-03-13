import 'package:flutter/material.dart';

/// Dữ liệu cho một trang onboarding. Tách riêng để tái sử dụng và dễ mở rộng.
@immutable
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.imagePath,
  }) : assert(
         icon != null || imagePath != null,
         'Cần ít nhất icon hoặc imagePath',
       );

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imagePath;
}
