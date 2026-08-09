import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_state.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';
import 'package:study/features/student/presentation/schedule/widgets/calendar_widget.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/section_header.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(const ScheduleStarted());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: Text(
          'Lịch học',
          style: tt.titleLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: 'Về hôm nay',
            onPressed: () {
              context.read<ScheduleBloc>().add(
                ScheduleDateSelected(DateTime.now()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          return switch (state) {
            ScheduleInitial() || ScheduleInProgress() => const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            ScheduleFailure(:final message) => _buildError(context, message),
            ScheduleSuccess() => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreenAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_problem, color: cs.onErrorContainer),
            ),
            AppSpacing.vGap16,
            Text(
              'Không thể tải lịch học',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap4,
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: () =>
                  context.read<ScheduleBloc>().add(const ScheduleStarted()),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScheduleSuccess state) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ScheduleBloc>().add(const ScheduleStarted());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Calendar section
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month summary
                _MonthSummary(
                  eventCount: state.eventDates.length,
                  currentMonth: state.currentMonth,
                ),
                AppSpacing.vGap16,
                // Calendar
                CalendarWidget(
                  currentMonth: state.currentMonth,
                  selectedDate: state.selectedDate,
                  eventDates: state.eventDates,
                  onDateSelected: (date) {
                    context.read<ScheduleBloc>().add(ScheduleDateSelected(date));
                  },
                  onMonthChanged: (month) {
                    context.read<ScheduleBloc>().add(ScheduleMonthChanged(month));
                  },
                ),
              ],
            ),
          ),

          // Background layer với schedule
          Container(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                cs.primary.withValues(
                  alpha: Theme.of(context).brightness == Brightness.light
                      ? 0.045
                      : 0.065,
                ),
                cs.surfaceContainer,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              border: Border(
                top: BorderSide(color: cs.primary.withValues(alpha: 0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.045),
                  blurRadius: 32,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.xl,
              AppSpacing.screenPadding,
              104,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected date header
                _SelectedDateHeader(
                  selectedDate: state.selectedDate,
                  itemCount: state.selectedDateItems.length,
                ),
                AppSpacing.vGap16,

                // Schedule timeline
                if (state.isLoadingDay)
                  _LoadingSchedule()
                else if (state.selectedDateItems.isEmpty)
                  _EmptySchedule(selectedDate: state.selectedDate)
                else
                  ScheduleTimeline(
                    items: state.selectedDateItems.map((item) {
                      return ScheduleTimelineItemData(
                        time: _formatTimeRange(item.startTime, item.endTime),
                        title: item.title,
                        subtitle:
                            '${_typeLabel(item.type)} • ${item.instructorName ?? ""}',
                        type: _mapScheduleType(item.type),
                        isActive: _isCurrentOrNext(item.startTime, item.endTime),
                      );
                    }).toList(),
                  ),

                AppSpacing.vGap24,

                // Quick tips section
                SectionHeader(
                  title: 'Mẹo học tập',
                  iconColor: cs.secondary,
                ),
                AppSpacing.vGap12,
                _LearningTipCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  ScheduleItemType _mapScheduleType(String type) {
    return switch (type.toLowerCase()) {
      'livestream' => ScheduleItemType.livestream,
      'quiz' => ScheduleItemType.quiz,
      'deadline' => ScheduleItemType.deadline,
      _ => ScheduleItemType.video,
    };
  }

  bool _isCurrentOrNext(DateTime start, DateTime end) {
    final now = DateTime.now();
    return start.isAfter(now) || (start.isBefore(now) && end.isAfter(now));
  }

  String _typeLabel(String type) {
    return switch (type.toLowerCase()) {
      'livestream' => 'Trực tuyến',
      'quiz' => 'Bài kiểm tra',
      'deadline' => 'Hạn nộp',
      _ => 'Video',
    };
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({
    required this.eventCount,
    required this.currentMonth,
  });

  final int eventCount;
  final DateTime currentMonth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: cs.onPrimaryContainer,
            size: 22,
          ),
        ),
        AppSpacing.hGap12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tháng ${currentMonth.month}/${currentMonth.year}',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '$eventCount ngày có lịch',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedDateHeader extends StatelessWidget {
  const _SelectedDateHeader({
    required this.selectedDate,
    required this.itemCount,
  });

  final DateTime selectedDate;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isToday = _isToday(selectedDate);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Lịch trong ngày',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (isToday) ...[
                    AppSpacing.hGap8,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Hôm nay',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              AppSpacing.vGap4,
              Text(
                _formatFullDate(selectedDate),
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_note_outlined,
                size: 16,
                color: cs.primary,
              ),
              AppSpacing.hGap4,
              Text(
                '$itemCount hoạt động',
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatFullDate(DateTime date) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day}/${date.month}/${date.year}';
  }
}

class _LoadingSchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outline),
        boxShadow: AppShadows.layeredCard,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outline),
        boxShadow: AppShadows.layeredCard,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_outlined,
              color: cs.onSecondaryContainer,
              size: 28,
            ),
          ),
          AppSpacing.vGap12,
          Text(
            'Không có lịch học',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.vGap4,
          Text(
            'Ngày này bạn được nghỉ ngơi!',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LearningTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final tips = [
      (Icons.lightbulb_outline, 'Chia nhỏ bài học thành các phần 25 phút'),
      (Icons.self_improvement, 'Nghỉ ngơi 5 phút sau mỗi phiên học'),
      (Icons.edit_note, 'Ghi chú lại những điểm quan trọng'),
    ];

    final tip = tips[DateTime.now().day % tips.length];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.secondaryContainer,
            cs.secondaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.onSecondaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              tip.$1,
              color: cs.onSecondaryContainer,
              size: 24,
            ),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Text(
              tip.$2,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
