import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Mục "Hôm nay / Tiếp theo": lịch học sắp tới.
class UpcomingScheduleSection extends StatelessWidget {
  const UpcomingScheduleSection({super.key, required this.schedules});

  final List<ParentScheduleItem> schedules;

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
          ...schedules.map((item) => _ScheduleItem(item: item)),
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({required this.item});

  final ParentScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOnline = item.mode == ParentScheduleMode.online;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.startTime,
                  style: tt.titleLarge?.copyWith(
                    color: isOnline ? cs.blue600 : cs.slate900,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? 'ONLINE' : 'TẠI CƠ SỞ',
                  style: tt.labelSmall?.copyWith(
                    color: isOnline ? cs.blue600 : cs.slate400,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.hGap12,
          Container(width: 1, height: 56, color: cs.slate200),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.childName} — ${item.subjectName}',
                  style: tt.titleSmall?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.locationOrLink,
                  style: tt.bodySmall?.copyWith(color: cs.blue600),
                ),
                const SizedBox(height: 2),
                Text(
                  item.teacherOrRoom,
                  style: tt.bodySmall?.copyWith(color: cs.slate500),
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isOnline ? const Color(0xFFDBEAFE) : cs.slate100,
              borderRadius: AppRadius.borderFull,
            ),
            child: Text(
              item.statusLabel,
              style: tt.labelSmall?.copyWith(
                color: isOnline ? cs.blue600 : cs.slate600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
