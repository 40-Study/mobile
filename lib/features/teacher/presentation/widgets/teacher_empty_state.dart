import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Reusable empty state component cho Teacher UI.
///
/// - Icon 64px trong colored circle (primary.withAlpha(0.1))
/// - Centered layout với proper spacing
/// - Optional action button
class TeacherEmptyState extends StatelessWidget {
  const TeacherEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? cs.primary;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon trong colored circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: effectiveIconColor,
              ),
            ),
            AppSpacing.vGap24,
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
            ),
            // Subtitle
            if (subtitle != null) ...[
              AppSpacing.vGap8,
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
            // Action button
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.vGap24,
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline empty state nhỏ gọn hơn, dùng trong cards/sections.
class TeacherEmptyStateInline extends StatelessWidget {
  const TeacherEmptyStateInline({
    super.key,
    required this.icon,
    required this.message,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          AppSpacing.vGap12,
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          if (action != null && onAction != null) ...[
            AppSpacing.vGap12,
            TextButton(
              onPressed: onAction,
              child: Text(action!),
            ),
          ],
        ],
      ),
    );
  }
}
