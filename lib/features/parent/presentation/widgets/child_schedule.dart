import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class ChildSchedule extends StatefulWidget {
  const ChildSchedule({super.key});

  @override
  State<ChildSchedule> createState() => _ChildScheduleState();
}

class _ChildScheduleState extends State<ChildSchedule> {
  int _selectedDayIndex = DateTime.now().weekday - 1;

  static const List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  // Mock schedule data
  static final Map<int, List<_ScheduleItem>> _scheduleData = {
    0: [
      _ScheduleItem(
        subject: 'Toan',
        teacher: 'Nguyen Van A',
        time: '08:00 - 09:30',
        room: 'Phong 101',
        color: Colors.blue,
      ),
      _ScheduleItem(
        subject: 'Tieng Anh',
        teacher: 'Tran Thi B',
        time: '10:00 - 11:30',
        room: 'Phong 102',
        color: Colors.green,
      ),
      _ScheduleItem(
        subject: 'Ngu Van',
        teacher: 'Le Van C',
        time: '14:00 - 15:30',
        room: 'Phong 103',
        color: Colors.purple,
      ),
    ],
    1: [
      _ScheduleItem(
        subject: 'Vat Ly',
        teacher: 'Pham Thi D',
        time: '08:00 - 09:30',
        room: 'Phong 201',
        color: Colors.orange,
      ),
      _ScheduleItem(
        subject: 'Hoa Hoc',
        teacher: 'Hoang Van E',
        time: '10:00 - 11:30',
        room: 'Phong 202',
        color: Colors.teal,
      ),
    ],
    2: [
      _ScheduleItem(
        subject: 'Toan',
        teacher: 'Nguyen Van A',
        time: '08:00 - 09:30',
        room: 'Phong 101',
        color: Colors.blue,
      ),
      _ScheduleItem(
        subject: 'Sinh Hoc',
        teacher: 'Vu Thi F',
        time: '10:00 - 11:30',
        room: 'Phong 203',
        color: Colors.lightGreen,
      ),
      _ScheduleItem(
        subject: 'Lich Su',
        teacher: 'Dao Van G',
        time: '14:00 - 15:30',
        room: 'Phong 104',
        color: Colors.brown,
      ),
    ],
    3: [
      _ScheduleItem(
        subject: 'Tieng Anh',
        teacher: 'Tran Thi B',
        time: '08:00 - 09:30',
        room: 'Phong 102',
        color: Colors.green,
      ),
      _ScheduleItem(
        subject: 'Dia Ly',
        teacher: 'Bui Van H',
        time: '10:00 - 11:30',
        room: 'Phong 105',
        color: Colors.cyan,
      ),
    ],
    4: [
      _ScheduleItem(
        subject: 'Toan',
        teacher: 'Nguyen Van A',
        time: '08:00 - 09:30',
        room: 'Phong 101',
        color: Colors.blue,
      ),
      _ScheduleItem(
        subject: 'Tieng Anh',
        teacher: 'Tran Thi B',
        time: '10:00 - 11:30',
        room: 'Phong 102',
        color: Colors.green,
      ),
      _ScheduleItem(
        subject: 'The Duc',
        teacher: 'Ngo Van I',
        time: '14:00 - 15:30',
        room: 'San TD',
        color: Colors.red,
      ),
    ],
    5: [
      _ScheduleItem(
        subject: 'Am Nhac',
        teacher: 'Dinh Thi K',
        time: '08:00 - 09:30',
        room: 'Phong AN',
        color: Colors.pink,
      ),
    ],
    6: [],
  };

  List<_ScheduleItem> get _todaySchedule => _scheduleData[_selectedDayIndex] ?? [];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lich hoc',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_todaySchedule.length} tiet',
                style: textTheme.bodySmall?.copyWith(
                  color: cs.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Day selector
          Row(
            children: List.generate(7, (index) {
              final isSelected = index == _selectedDayIndex;
              final isToday = index == DateTime.now().weekday - 1;
              final hasClasses = (_scheduleData[index]?.length ?? 0) > 0;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = index),
                  child: Container(
                    margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary
                          : isToday
                              ? cs.primaryContainer
                              : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: cs.primary, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _weekDays[index],
                          style: textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? cs.onPrimary
                                : isToday
                                    ? cs.primary
                                    : cs.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (hasClasses)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cs.onPrimary
                                  : cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Schedule list
          if (_todaySchedule.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 48,
                      color: cs.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Khong co lich hoc',
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_todaySchedule.length, (index) {
              final item = _todaySchedule[index];
              final isLast = index == _todaySchedule.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
                child: _ScheduleCard(item: item),
              );
            }),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.item});

  final _ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subject,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.teacher,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.textSecondary,
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
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: cs.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.time,
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.room_outlined,
                    size: 14,
                    color: cs.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.room,
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem {
  const _ScheduleItem({
    required this.subject,
    required this.teacher,
    required this.time,
    required this.room,
    required this.color,
  });

  final String subject;
  final String teacher;
  final String time;
  final String room;
  final Color color;
}

/// Compact version for dashboard
class ChildScheduleCompact extends StatelessWidget {
  const ChildScheduleCompact({super.key});

  // Today's schedule mock
  static final List<_ScheduleItem> _todaySchedule = [
    _ScheduleItem(
      subject: 'Toan',
      teacher: 'Nguyen Van A',
      time: '08:00 - 09:30',
      room: 'Phong 101',
      color: Colors.blue,
    ),
    _ScheduleItem(
      subject: 'Tieng Anh',
      teacher: 'Tran Thi B',
      time: '10:00 - 11:30',
      room: 'Phong 102',
      color: Colors.green,
    ),
    _ScheduleItem(
      subject: 'Ngu Van',
      teacher: 'Le Van C',
      time: '14:00 - 15:30',
      room: 'Phong 103',
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lich hoc hom nay',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_todaySchedule.length} tiet hoc',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTodayLabel(),
                  style: textTheme.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Schedule timeline
          ...List.generate(_todaySchedule.length, (index) {
            final item = _todaySchedule[index];
            final isLast = index == _todaySchedule.length - 1;

            return _CompactScheduleItem(
              item: item,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  String _getTodayLabel() {
    final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return weekdays[DateTime.now().weekday - 1];
  }
}

class _CompactScheduleItem extends StatelessWidget {
  const _CompactScheduleItem({
    required this.item,
    required this.isLast,
  });

  final _ScheduleItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Content
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.subject,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.time,
                          style: textTheme.labelSmall?.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item.room,
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.textSecondary,
                    ),
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
