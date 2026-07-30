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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lich hoc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              context
                  .read<ScheduleBloc>()
                  .add(ScheduleDateSelected(DateTime.now()));
            },
          ),
        ],
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          return switch (state) {
            ScheduleInitial() || ScheduleInProgress() => const Center(
                child: CircularProgressIndicator(),
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
            child: const Text('Thu lai'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScheduleSuccess state) {
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
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
        AppSpacing.vGap24,

        // Selected date header
        Text(
          _formatDate(state.selectedDate),
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        AppSpacing.vGap12,

        // Day schedule
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
                subtitle: '${item.type} • ${item.instructorName ?? ""}',
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
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - '
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
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
}
