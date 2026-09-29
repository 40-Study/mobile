import 'package:flutter/material.dart';
import 'package:study/features/parent/bloc/home/parent_home_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/home/widgets/home_section_skeletons.dart';
import 'package:study/features/parent/presentation/home/widgets/section_error_card.dart';
import 'package:study/theme/theme.dart';

/// Card Phân tích học tập: điểm TB, AI insight, điều hướng báo cáo.
/// Khi chưa có dữ liệu hiển thị Empty State.
/// Tiêu đề nằm ngoài card, hỗ trợ thu gọn/mở rộng (mặc định: mở toàn bộ).
/// Hỗ trợ Partial Failure và Skeleton loading riêng biệt.
/// Khi ở chế độ "Tất cả các con": hiển thị tổng quan của cả Minh và Lan
/// song song.
class LearningAnalyticsCard extends StatefulWidget {

  const LearningAnalyticsCard({
    super.key,
    required this.analytics,
    this.analyticsList = const [],
    this.selectedChildId,
    this.status = HomeSectionStatus.success,
    this.errorMessage,
    this.onRetry,
    this.onViewDetail,
    this.onViewDetailForChild,
    this.onViewAllReports,
    this.onViewLearning,
  });

  final ParentAnalyticsData? analytics;
  final List<ParentAnalyticsData> analyticsList;
  final String? selectedChildId;
  final HomeSectionStatus status;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onViewDetail;
  final ValueChanged<String?>? onViewDetailForChild;
  final VoidCallback? onViewAllReports;
  final VoidCallback? onViewLearning;

  @override
  State<LearningAnalyticsCard> createState() => _LearningAnalyticsCardState();
}

class _LearningAnalyticsCardState extends State<LearningAnalyticsCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final hasData = widget.selectedChildId == null
        ? widget.analyticsList.isNotEmpty
        : widget.analytics != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, hasData),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildContent(context),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.status == HomeSectionStatus.loading) {
      return const LearningAnalyticsSkeleton();
    }

    if (widget.status == HomeSectionStatus.failure) {
      return SectionErrorCard(
        message: widget.errorMessage ?? 'Không thể tải phân tích học tập',
        onRetry: widget.onRetry ?? () {},
      );
    }

    final isMultiChild =
        widget.selectedChildId == null && widget.analyticsList.length > 1;

    if (isMultiChild) {
      return Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: _MultiChildAnalyticsContent(
          analyticsList: widget.analyticsList,
          onViewDetailForChild: widget.onViewDetailForChild,
          onViewDetail: widget.onViewDetail,
          onViewAllReports: widget.onViewAllReports,
        ),
      );
    }

    final data = widget.analytics ?? widget.analyticsList.firstOrNull;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: data == null
          ? _EmptyAnalyticsCard(onViewLearning: widget.onViewLearning)
          : _AnalyticsContent(
              analytics: data,
              onViewDetail: () {
                if (widget.onViewDetailForChild != null) {
                  widget.onViewDetailForChild!(data.childId);
                } else if (widget.onViewDetail != null) {
                  widget.onViewDetail!();
                }
              },
              onViewAllReports: widget.onViewAllReports,
            ),
    );
  }


  Widget _buildHeader(BuildContext context, bool hasData) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: AppRadius.borderMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: Icon(
                    Icons.insights_rounded,
                    color: cs.blue600,
                    size: 19,
                  ),
                ),
              ),
              AppSpacing.hGap8,
              Text(
                'PHÂN TÍCH HỌC TẬP',
                style: tt.labelLarge?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (hasData)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: AppRadius.borderFull,
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AchievementColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Tiến bộ tốt',
                        style: tt.labelSmall?.copyWith(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.slate100,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    'Chưa có báo cáo',
                    style: tt.labelSmall?.copyWith(color: cs.slate500),
                  ),
                ),
              AppSpacing.hGap8,
              AnimatedRotation(
                turns: _isExpanded ? 0 : 0.5,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: cs.slate500,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
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
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
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
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
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
          style: TextStyle(
            color: cs.slate900,
            fontWeight: FontWeight.w700,
          ),
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
                  'Hộp thư phân tích >',
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

class _MultiChildAnalyticsContent extends StatelessWidget {
  const _MultiChildAnalyticsContent({
    required this.analyticsList,
    this.onViewDetailForChild,
    this.onViewDetail,
    this.onViewAllReports,
  });

  final List<ParentAnalyticsData> analyticsList;
  final ValueChanged<String?>? onViewDetailForChild;
  final VoidCallback? onViewDetail;
  final VoidCallback? onViewAllReports;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
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
          for (var i = 0; i < analyticsList.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
            _SingleChildSection(
              analytics: analyticsList[i],
              onViewDetail: () {
                if (onViewDetailForChild != null) {
                  onViewDetailForChild!(analyticsList[i].childId);
                } else if (onViewDetail != null) {
                  onViewDetail!();
                }
              },
            ),
          ],
          AppSpacing.vGap16,
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng hợp toàn bộ con',
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: onViewAllReports,
                  borderRadius: AppRadius.borderSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hộp thư phân tích >',
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
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleChildSection extends StatelessWidget {
  const _SingleChildSection({
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
              backgroundColor: analytics.childBadgeColor ??
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
          style: TextStyle(
            color: cs.slate900,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextSpan(text: text.substring(end)),
      ],
    );
  }
}

