import 'package:flutter/material.dart';
import 'package:study/features/onboarding/models/onboarding_page_data.dart';

/// Widget tái sử dụng cho nội dung một trang onboarding (icon/image + title + subtitle).
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.data,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final OnboardingPageData data;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(context, colorScheme),
          const SizedBox(height: 32),
          Text(
            data.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context, ColorScheme colorScheme) {
    if (data.imagePath != null && data.imagePath!.isNotEmpty) {
      return Image.asset(
        data.imagePath!,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildIconFallback(colorScheme),
      );
    }
    return _buildIconFallback(colorScheme);
  }

  Widget _buildIconFallback(ColorScheme colorScheme) {
    final icon = data.icon ?? Icons.lightbulb_outline;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 64, color: colorScheme.primary),
    );
  }
}
