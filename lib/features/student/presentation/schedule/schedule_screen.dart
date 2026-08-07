import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_state.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';
import 'package:study/features/student/presentation/schedule/widgets/calendar_widget.dart';
import 'package:study/theme/theme.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch học'),
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          AppSpacing.vGap16,
          Text(message),
          AppSpacing.vGap16,
          FilledButton(
            onPressed: () =>
                context.read<ScheduleBloc>().add(const ScheduleStarted()),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScheduleSuccess state) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
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
        AppSpacing.vGap24,

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch trong ngày',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    _formatDate(state.selectedDate),
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
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${state.selectedDateItems.length} hoạt động',
                style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer),
              ),
            ),
          ],
        ),
        AppSpacing.vGap12,

        if (state.isLoadingDay)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          )
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

        AppSpacing.vGap32,
      ],
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day}/${date.month}/${date.year}';
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
