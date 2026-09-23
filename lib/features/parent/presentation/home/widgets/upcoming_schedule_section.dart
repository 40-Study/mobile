import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Mục "Hôm nay / Tiếp theo": lịch học sắp tới.
/// Khi rỗng hiển thị Empty State "Hôm nay không có ca học nào".
/// Tiêu đề nằm ngoài card, mỗi ca học là một thẻ card độc lập, hỗ trợ thu gọn/mở rộng.
class UpcomingScheduleSection extends StatefulWidget {
  const UpcomingScheduleSection({
    super.key,
    required this.schedules,
    this.onViewFullSchedule,
    this.onScheduleTap,
  });

  final List<ParentScheduleItem> schedules;
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
          firstChild: widget.schedules.isEmpty
              ? Container(
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
                )
              : Column(
                  children: [
                    for (var i = 0; i < widget.schedules.length; i++)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          0,
                        ),
                        child: _ScheduleItemCard(
                          item: widget.schedules[i],
                          onTap: widget.onScheduleTap != null
                              ? () => widget.onScheduleTap!(widget.schedules[i])
                              : null,
                        ),
                      ),
                  ],
                ),
          secondChild: const SizedBox.shrink(),
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

class _ScheduleItemCard extends StatelessWidget {
  const _ScheduleItemCard({required this.item, this.onTap});

  final ParentScheduleItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOnline = item.mode == ParentScheduleMode.online;
    final duration = '${item.durationMinutes ?? (isOnline ? 60 : 90)}p';

    final timeBoxBg =
        isOnline ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9);
    final timeColor = isOnline ? cs.blue600 : cs.slate900;
    final durationColor = isOnline ? cs.blue600 : cs.slate500;

    final childBadgeBg =
        isOnline ? const Color(0xFFDBEAFE) : const Color(0xFFFEF3C7);
    final childBadgeColor = isOnline ? cs.blue700 : const Color(0xFFD97706);

    final statusBg =
        isOnline ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9);
    final statusColor = isOnline ? cs.blue600 : cs.slate700;

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderLg,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Khối thời gian bên trái
                Container(
                  width: 64,
                  height: 52,
                  decoration: BoxDecoration(
                    color: timeBoxBg,
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.startTime,
                        style: tt.titleMedium?.copyWith(
                          color: timeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        duration,
                        style: tt.labelSmall?.copyWith(
                          color: durationColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap12,
                // Cột thông tin ở giữa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: childBadgeBg,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              item.childName,
                              style: tt.labelSmall?.copyWith(
                                color: childBadgeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.subjectName,
                              style: tt.titleSmall?.copyWith(
                                color: cs.slate900,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            isOnline
                                ? Icons.videocam_outlined
                                : Icons.business_outlined,
                            size: 15,
                            color: cs.slate500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item.locationOrLink} · ${item.teacherOrRoom}',
                              style: tt.bodySmall?.copyWith(
                                color: cs.slate600,
                                fontSize: 12.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap8,
                // Badge trạng thái bên phải
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    item.statusLabel,
                    style: tt.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
