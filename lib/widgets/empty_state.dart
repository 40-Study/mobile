import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

enum EmptyStateStyle { compactCard, card, inline, fullPage }

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.title,
    this.actionLabel,
    this.onAction,
    this.style = EmptyStateStyle.card,
  });

  final String message;
  final IconData? icon;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateStyle style;

  @override
  Widget build(BuildContext context) {
    final content = _EmptyStateContent(
      message: message,
      icon: icon,
      title: title,
      actionLabel: actionLabel,
      onAction: onAction,
      compact: style == EmptyStateStyle.compactCard,
    );

    switch (style) {
      case EmptyStateStyle.compactCard:
        return _CompactCard(child: content);
      case EmptyStateStyle.card:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: content,
          ),
        );
      case EmptyStateStyle.inline:
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: content,
        );
      case EmptyStateStyle.fullPage:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: content,
          ),
        );
    }
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}

class _EmptyStateContent extends StatelessWidget {
  const _EmptyStateContent({
    required this.message,
    required this.compact,
    this.icon,
    this.title,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool compact;
  final IconData? icon;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppIconSize.hero, color: cs.textSecondary),
          const SizedBox(height: AppSpacing.md),
        ],
        if (title != null) ...[
          Text(
            title!,
            textAlign: TextAlign.center,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          message,
          textAlign: TextAlign.center,
          style: compact
              ? tt.bodyMedium?.copyWith(color: cs.textSecondary)
              : tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.lg),
          FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}
