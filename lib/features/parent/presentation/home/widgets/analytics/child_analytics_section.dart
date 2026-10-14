import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_analytics_data.dart';
import 'package:study/theme/theme.dart';

class ChildAnalyticsSection extends StatelessWidget {
  const ChildAnalyticsSection({
    super.key,
    required this.analytics,
    required this.onViewDetail,
  });

  final ParentAnalyticsData analytics;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final initial = analytics.childName.isNotEmpty
        ? analytics.childName[0].toUpperCase()
        : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dòng điểm số con
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  analytics.childBadgeColor ??
                  (analytics.childName == 'Minh'
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFFDF2F8)),
              child: Text(
                initial,
                style: tt.titleMedium?.copyWith(
                  color: analytics.childName == 'Minh'
                      ? cs.blue600
                      : const Color(0xFFDB2777),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${analytics.childName} · ${analytics.className}',
                    style: tt.titleSmall?.copyWith(
                      color: cs.slate900,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    analytics.reportLabel,
                    style: tt.bodySmall?.copyWith(
                      color: cs.slate500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Điểm TB: ',
                      style: tt.bodySmall?.copyWith(
                        color: cs.slate600,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                    Text(
                      analytics.averageScore.toStringAsFixed(1),
                      style: tt.titleMedium?.copyWith(
                        color: cs.slate900,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '(+${analytics.progressPercent}%)',
                  style: tt.labelSmall?.copyWith(
                    color: AchievementColors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        AppSpacing.vGap12,

        // Hộp AI Insight
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Text.rich(
            _buildInsightSpan(context),
            style: tt.bodySmall?.copyWith(
              color: cs.slate700,
              height: 1.4,
              fontSize: 12.5,
            ),
          ),
        ),
        AppSpacing.vGap8,
        // Nút xem chi tiết con
        InkWell(
          onTap: onViewDetail,
          borderRadius: AppRadius.borderSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Xem phân tích của ${analytics.childName} ->',
                  style: tt.labelMedium?.copyWith(
                    color: cs.blue600,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextSpan _buildInsightSpan(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final highlight = analytics.insightHighlight;
    final text = analytics.insightText;

    if (highlight == null || !text.contains(highlight)) {
      return TextSpan(text: text);
    }

    final start = text.indexOf(highlight);
    final end = start + highlight.length;
    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, start)),
        TextSpan(
          text: highlight,
          style: TextStyle(color: cs.slate900, fontWeight: FontWeight.w700),
        ),
        TextSpan(text: text.substring(end)),
      ],
    );
  }
}
