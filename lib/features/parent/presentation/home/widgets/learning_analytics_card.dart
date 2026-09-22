import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Card Phân tích học tập: điểm TB, biểu đồ cột, AI insight.
/// Khi chưa có dữ liệu hiển thị Empty State.
class LearningAnalyticsCard extends StatelessWidget {
  const LearningAnalyticsCard({
    super.key,
    required this.analytics,
    this.onViewDetail,
    this.onViewAllReports,
    this.onViewLearning,
  });

  final ParentAnalyticsData? analytics;
  final VoidCallback? onViewDetail;
  final VoidCallback? onViewAllReports;
  final VoidCallback? onViewLearning;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final data = analytics;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: cs.blue600, size: 20),
              AppSpacing.hGap8,
              Text(
                'PHÂN TÍCH HỌC TẬP',
                style: tt.labelLarge?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.hGap8,
              if (data != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AchievementColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.hGap4,
                Text(
                  'Tiến bộ tốt',
                  style: tt.labelSmall?.copyWith(
                    color: AchievementColors.green,
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.slate100,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    'Chưa có báo cáo',
                    style: tt.labelSmall?.copyWith(color: cs.slate500),
                  ),
                ),
            ],
          ),
          AppSpacing.vGap12,
          if (data == null)
            _EmptyAnalyticsCard(onViewLearning: onViewLearning)
          else
            _AnalyticsContent(
              analytics: data,
              onViewDetail: onViewDetail,
              onViewAllReports: onViewAllReports,
            ),
        ],
      ),
    );
  }
}

class _EmptyAnalyticsCard extends StatelessWidget {
  const _EmptyAnalyticsCard({this.onViewLearning});

  final VoidCallback? onViewLearning;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 40, color: cs.slate300),
          AppSpacing.vGap12,
          Text(
            'Chưa có dữ liệu phân tích tuần này',
            style: tt.titleSmall?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap8,
          Text(
            'Dữ liệu học tập, điểm số trung bình và nhận xét chi tiết sẽ tự '
            'động hiển thị sau khi con nộp bài tập và hoàn thành các bài kiểm '
            'tra đầu tiên.',
            style: tt.bodySmall?.copyWith(color: cs.slate500, height: 1.5),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap12,
          InkWell(
            onTap: onViewLearning,
            borderRadius: AppRadius.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem bảng điểm các kỳ trước',
                    style: tt.labelMedium?.copyWith(
                      color: cs.blue600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: cs.blue600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({
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
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context),
          AppSpacing.vGap16,
          _buildScoreRow(context),
          AppSpacing.vGap16,
          _buildInsightBox(context),
          AppSpacing.vGap16,
          _buildActionsRow(context),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final initial = analytics.childName.isNotEmpty
        ? analytics.childName[0].toUpperCase()
        : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: cs.blue600,
          child: Text(
            initial,
            style: tt.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppSpacing.hGap12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${analytics.childName} (${analytics.className})',
                style: tt.titleSmall?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                analytics.reportLabel,
                style: tt.bodySmall?.copyWith(color: cs.slate500),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: AppRadius.borderFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_upward_rounded,
                size: 14,
                color: AchievementColors.green,
              ),
              Text(
                '+${analytics.progressPercent}%',
                style: tt.labelSmall?.copyWith(
                  color: AchievementColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          analytics.averageScore.toStringAsFixed(1),
          style: tt.displaySmall?.copyWith(
            color: cs.slate900,
            fontWeight: FontWeight.w800,
            fontSize: 38,
            height: 1,
          ),
        ),
        AppSpacing.hGap8,
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '/ 10 điểm TB tuần',
            style: tt.bodySmall?.copyWith(color: cs.slate400),
          ),
        ),
        const Spacer(),
        _buildBarChart(),
      ],
    );
  }

  Widget _buildBarChart() {
    const color = Color(0xFF3B82F6);
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: analytics.weeklyTrend.map((value) {
          return Container(
            width: 10,
            height: 12 + value * 36,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightBox(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: AppRadius.borderMd,
        border: Border(
          left: BorderSide(color: cs.blue700, width: 3.5),
        ),
      ),
      child: Text.rich(
        _buildInsightSpan(context),
        style: tt.bodySmall?.copyWith(color: cs.slate700, height: 1.5),
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
          style: TextStyle(
            color: cs.blue700,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextSpan(text: text.substring(end)),
      ],
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onViewDetail,
            borderRadius: AppRadius.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text(
                    'Xem phân tích của ${analytics.childName}',
                    style: tt.labelMedium?.copyWith(
                      color: cs.blue600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: cs.blue600,
                  ),
                ],
              ),
            ),
          ),
        ),
        AppSpacing.hGap8,
        InkWell(
          onTap: onViewAllReports,
          borderRadius: AppRadius.borderSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  'Tất cả báo cáo',
                  style: tt.labelMedium?.copyWith(
                    color: cs.slate500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 16, color: cs.slate500),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
