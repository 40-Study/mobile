import 'package:flutter/material.dart';

import 'package:study/features/parent/bloc/home/parent_home_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/home/widgets/home_section_skeletons.dart';
import 'package:study/features/parent/presentation/home/widgets/section_error_card.dart';
import 'package:study/features/parent/presentation/schedule/parent_session_detail_screen.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/theme/theme.dart';

/// Mục "Hôm nay / Tiếp theo": lịch học sắp tới.
/// Khi rỗng hiển thị Empty State "Hôm nay không có ca học nào".
/// Tiêu đề nằm ngoài card, mỗi ca học là một thẻ card độc lập, hỗ trợ thu gọn/mở rộng.
/// Hỗ trợ Partial Failure và Skeleton loading riêng biệt.
/// Khi chọn "Tất cả các con": nhóm theo từng con với ChildGroupSubHeader.
class UpcomingScheduleSection extends StatefulWidget {
  const UpcomingScheduleSection({
    super.key,
    required this.schedules,
    this.children = const [],
    this.selectedChildId,
    this.status = HomeSectionStatus.success,
    this.errorMessage,
    this.onRetry,
    this.onViewFullSchedule,
    this.onScheduleTap,
  });

  final List<ParentScheduleItem> schedules;
  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final HomeSectionStatus status;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onViewFullSchedule;
  final ValueChanged<ParentScheduleItem>? onScheduleTap;

  @override
  State<UpcomingScheduleSection> createState() =>
      _UpcomingScheduleSectionState();
}

class _UpcomingScheduleSectionState extends State<UpcomingScheduleSection> {
  bool _isExpanded = true;

  String _formattedDate() {
    final now = DateTime.now();
    const days = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final dayName = days[now.weekday - 1];
    return '$dayName, ${now.day} Th${now.month}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildContent(context, cs),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme cs) {
    if (widget.status == HomeSectionStatus.loading) {
      return const UpcomingScheduleSkeleton();
    }

    if (widget.status == HomeSectionStatus.failure) {
      return SectionErrorCard(
        message: widget.errorMessage ?? 'Không thể tải lịch học lúc này',
        onRetry: widget.onRetry ?? () {},
      );
    }

    if (widget.schedules.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
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
        child: _EmptyScheduleCard(
          onViewFullSchedule: widget.onViewFullSchedule,
        ),
      );
    }

    // Nếu chọn "Tất cả các con" (selectedChildId == null)
    // -> nhóm ca học theo từng con
    if (widget.selectedChildId == null && widget.children.isNotEmpty) {

      final childrenWithSchedules = <Widget>[];
      final renderedSchedules = <ParentScheduleItem>{};

      for (final child in widget.children) {
        final childSchedules = widget.schedules.where((s) {
          if (s.childId != null && s.childId == child.id) return true;
          return s.childName == child.name;
        }).toList();

        if (childSchedules.isNotEmpty) {
          renderedSchedules.addAll(childSchedules);
          childrenWithSchedules.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: ChildGroupSubHeader(
                      child: child,
                      countLabel: '${childSchedules.length} ca học',
                    ),
                  ),
                  for (final item in childSchedules)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.lg,
                        0,
                      ),
                      child: ParentScheduleCard(
                        session: item.toSession(),
                        onTap: widget.onScheduleTap != null
                            ? () => widget.onScheduleTap!(item)
                            : () => ParentSessionDetailScreen.open(
                                  context,
                                  session: item.toSession(),
                                  child: child,
                                ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      }

      final remainingSchedules = widget.schedules
          .where((s) => !renderedSchedules.contains(s))
          .toList();
      if (remainingSchedules.isNotEmpty) {
        childrenWithSchedules.add(
          Column(
            children: [
              for (final item in remainingSchedules)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  child: ParentScheduleCard(
                    session: item.toSession(),
                    onTap: widget.onScheduleTap != null
                        ? () => widget.onScheduleTap!(item)
                        : () => ParentSessionDetailScreen.open(
                              context,
                              session: item.toSession(),
                            ),
                  ),
                ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: childrenWithSchedules,
      );
    }

    return Column(
      children: [
        for (var i = 0; i < widget.schedules.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              0,
            ),
            child: ParentScheduleCard(
              session: widget.schedules[i].toSession(),
              onTap: widget.onScheduleTap != null
                  ? () => widget.onScheduleTap!(widget.schedules[i])
                  : () => ParentSessionDetailScreen.open(
                        context,
                        session: widget.schedules[i].toSession(),
                      ),
            ),
          ),
      ],
    );
  }


  Widget _buildHeader(BuildContext context) {
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
                    Icons.calendar_today_rounded,
                    color: cs.blue600,
                    size: 19,
                  ),
                ),
              ),
              AppSpacing.hGap8,
              Text(
                'HÔM NAY / TIẾP THEO',
                style: tt.labelLarge?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                _formattedDate(),
                style: tt.labelSmall?.copyWith(
                  color: cs.slate500,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
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

class _EmptyScheduleCard extends StatelessWidget {
  const _EmptyScheduleCard({this.onViewFullSchedule});

  final VoidCallback? onViewFullSchedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_outlined,
              color: cs.blue600,
              size: 24,
            ),
          ),
          AppSpacing.vGap12,
          Text(
            'Hôm nay không có ca học nào',
            style: tt.titleSmall?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.vGap4,
          Text(
            'Con không có lịch học trực tuyến hoặc tại cơ sở '
            'hôm nay. Thời gian dành cho nghỉ ngơi hoặc tự ôn tập.',
            style: tt.bodySmall?.copyWith(color: cs.slate500, height: 1.5),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap8,
          InkWell(
            onTap: onViewFullSchedule,
            borderRadius: AppRadius.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem thời khóa biểu đầy đủ',
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
        ],
      ),
    );
  }
}
