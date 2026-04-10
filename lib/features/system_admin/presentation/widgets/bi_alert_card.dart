import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import '../../data/models/bi_models.dart';

/// Compact alert card for dashboard
class BIAlertCard extends StatelessWidget {
  const BIAlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onDismiss,
  });

  final DashboardAlert alert;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (icon, color) = _getAlertStyle(alert.type, cs);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.message,
                    style: tt.bodySmall?.copyWith(
                      color: cs.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: cs.textTertiary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getAlertStyle(AlertType type, ColorScheme cs) {
    switch (type) {
      case AlertType.loss:
        return (Icons.trending_down_rounded, cs.error);
      case AlertType.inefficiency:
        return (Icons.warning_amber_rounded, cs.tertiary);
      case AlertType.opportunity:
        return (Icons.lightbulb_outline_rounded, cs.primary);
      case AlertType.milestone:
        return (Icons.celebration_outlined, cs.secondary);
    }
  }
}

/// Auto-generated insight card for the insights screen
class BIInsightCard extends StatelessWidget {
  const BIInsightCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  final BusinessInsight insight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (icon, color, gradient) = _getInsightStyle(
      insight.type,
      insight.severity,
      cs,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _SeverityDot(severity: insight.severity),
                          const SizedBox(width: 6),
                          Text(
                            _getTypeLabel(insight.type),
                            style: tt.labelSmall?.copyWith(
                              color: cs.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight.title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              insight.description,
              style: tt.bodyMedium?.copyWith(
                color: cs.textSecondary,
                height: 1.5,
              ),
            ),
            if (insight.centerName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 14,
                      color: cs.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      insight.centerName!,
                      style: tt.labelSmall?.copyWith(
                        color: cs.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(InsightType type) {
    switch (type) {
      case InsightType.revenue:
        return 'REVENUE';
      case InsightType.investment:
        return 'INVESTMENT';
      case InsightType.roi:
        return 'ROI';
      case InsightType.aiPerformance:
        return 'AI PERFORMANCE';
      case InsightType.growth:
        return 'GROWTH';
      case InsightType.risk:
        return 'RISK';
    }
  }

  (IconData, Color, LinearGradient) _getInsightStyle(
    InsightType type,
    InsightSeverity severity,
    ColorScheme cs,
  ) {
    final color = switch (severity) {
      InsightSeverity.positive => cs.secondary,
      InsightSeverity.neutral => cs.primary,
      InsightSeverity.warning => cs.tertiary,
      InsightSeverity.critical => cs.error,
    };

    final icon = switch (type) {
      InsightType.revenue => Icons.attach_money_rounded,
      InsightType.investment => Icons.account_balance_rounded,
      InsightType.roi => Icons.trending_up_rounded,
      InsightType.aiPerformance => Icons.auto_awesome_rounded,
      InsightType.growth => Icons.show_chart_rounded,
      InsightType.risk => Icons.warning_rounded,
    };

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withValues(alpha: 0.05),
        cs.surfaceContainerLowest,
      ],
    );

    return (icon, color, gradient);
  }
}

class _SeverityDot extends StatelessWidget {
  const _SeverityDot({required this.severity});

  final InsightSeverity severity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final color = switch (severity) {
      InsightSeverity.positive => cs.secondary,
      InsightSeverity.neutral => cs.primary,
      InsightSeverity.warning => cs.tertiary,
      InsightSeverity.critical => cs.error,
    };

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
