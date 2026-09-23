import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Mục "Hôm nay / Tiếp theo": lịch học sắp tới.
/// Khi rỗng hiển thị Empty State "Hôm nay không có ca học nào".
class UpcomingScheduleSection extends StatelessWidget {
  const UpcomingScheduleSection({
    super.key,
    required this.schedules,
    this.onViewFullSchedule,
  });

  final List<ParentScheduleItem> schedules;
  final VoidCallback? onViewFullSchedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: cs.blue600, size: 20),
              AppSpacing.hGap8,
              Text(
                'HÔM NAY / TIẾP THEO',
                style: tt.labelLarge?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'Thứ Sáu, 24 Th10',
                style: tt.labelSmall?.copyWith(color: cs.slate400),
              ),
            ],
          ),
          AppSpacing.vGap12,
          if (schedules.isEmpty)
            _EmptyScheduleCard(onViewFullSchedule: onViewFullSchedule)
          else
            ...schedules.map((item) => _ScheduleItem(item: item)),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
            style: tt.bodySmall?.copyWith(
              color: cs.slate500,
              height: 1.5,
            ),
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

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({required this.item, this.onTap});

  final ParentScheduleItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOnline = item.mode == ParentScheduleMode.online;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.startTime,
                      style: tt.titleLarge?.copyWith(
                        color: isOnline ? cs.blue600 : cs.slate900,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOnline ? 'ONLINE' : 'TẠI CƠ SỞ',
                      style: tt.labelSmall?.copyWith(
                        color: isOnline ? cs.blue600 : cs.slate500,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hGap8,
              VerticalDivider(
                width: 16,
                thickness: 1,
                color: cs.slate200,
              ),
              AppSpacing.hGap8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${item.childName} — ${item.subjectName}',
                      style: tt.titleSmall?.copyWith(
                        color: cs.slate900,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.locationOrLink,
                      style: tt.bodySmall?.copyWith(
                        color: isOnline ? cs.blue600 : cs.slate700,
                        fontWeight: isOnline ? FontWeight.w500 : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.teacherOrRoom,
                      style: tt.bodySmall?.copyWith(
                        color: cs.slate500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hGap8,
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOnline ? const Color(0xFFDBEAFE) : cs.slate100,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      item.statusLabel,
                      style: tt.labelSmall?.copyWith(
                        color: isOnline ? cs.blue600 : cs.slate700,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  AppSpacing.hGap4,
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.slate400,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
