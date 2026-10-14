import 'analytics/multi_child_analytics_content.dart';
import 'analytics/child_analytics_content.dart';
import 'analytics/empty_analytics_card.dart';
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
        child: MultiChildAnalyticsContent(
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
          ? EmptyAnalyticsCard(onViewLearning: widget.onViewLearning)
          : ChildAnalyticsContent(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3.5,
                  ),
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
