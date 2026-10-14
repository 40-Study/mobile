import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_analytics_data.dart';
import 'package:study/theme/theme.dart';

class ChildAnalyticsContent extends StatelessWidget {
  const ChildAnalyticsContent({
    super.key,
    required this.analytics,
    this.onViewDetail,
    this.onViewAllReports,
  });

  final ParentAnalyticsData analytics;
  final VoidCallback? onViewDetail;
  final VoidCallback? onViewAllReports;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentScoreRow(context),
          AppSpacing.vGap12,
          _buildAiInsightBox(context),
          AppSpacing.vGap12,
          _buildActionLinksRow(context),
        ],
      ),
    );
  }

  Widget _buildStudentScoreRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final initial = analytics.childName.isNotEmpty
        ? analytics.childName[0].toUpperCase()
        : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: const Color(0xFFEFF6FF),
          child: Text(
            initial,
            style: tt.titleMedium?.copyWith(
              color: cs.blue600,
              fontWeight: FontWeight.w800,
              fontSize: 16,
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
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                analytics.reportLabel,
                style: tt.bodySmall?.copyWith(
                  color: cs.slate500,
                  fontSize: 12.5,
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
                    fontSize: 13,
                  ),
                ),
                Text(
                  analytics.averageScore.toStringAsFixed(1),
                  style: tt.titleLarge?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
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
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAiInsightBox(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Text.rich(
        _buildInsightSpan(context),
        style: tt.bodySmall?.copyWith(
          color: cs.slate700,
          height: 1.45,
          fontSize: 13,
        ),
      ),
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

  Widget _buildActionLinksRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        InkWell(
          onTap: onViewDetail,
          borderRadius: AppRadius.borderSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Xem phân tích của ${analytics.childName} ->',
                  style: tt.labelMedium?.copyWith(
                    color: cs.blue600,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onViewAllReports,
          borderRadius: AppRadius.borderSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tất cả phân tích >',
                  style: tt.labelMedium?.copyWith(
                    color: cs.blue600,
                    fontWeight: FontWeight.w600,
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
}
