import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_state.dart';
import 'package:study/features/student/data/models/schedule_item_model.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';
import 'package:study/features/student/presentation/learning/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/schedule/widgets/calendar_widget.dart';
import 'package:study/features/student/repository/student_repository_impl.dart';
import 'package:study/widgets/app_header_bar.dart';
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
      appBar: AppHeaderBar(
        title: 'Lịch học',
        showNotification: false,
        actions: [
          IconButton(
            icon: Icon(Icons.today_outlined, color: cs.onSurface),
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
                  _FreeDay()
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
                        onTap: () => _onScheduleItemTap(context, item),
                      );
                    }).toList(),
                  ),

                AppSpacing.vGap24,

                // Daily goals section
                _DailyGoalsSection(date: state.selectedDate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onScheduleItemTap(BuildContext context, ScheduleItemModel item) {
    // Navigate based on item type
    if (item.lessonId != null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => LessonBloc(StudentRepositoryImpl())
              ..add(LessonStarted(item.lessonId!)),
            child: const LessonDetailScreen(),
          ),
        ),
      );
    } else if (item.courseId != null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => CourseDetailBloc(StudentRepositoryImpl())
              ..add(CourseDetailStarted(item.courseId!)),
            child: const CourseDetailScreen(),
          ),
        ),
      );
    } else {
      // Show snackbar for items without navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mở: ${item.title}')),
      );
    }
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

class _FreeDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(
            Icons.celebration_outlined,
            color: cs.onSecondaryContainer,
            size: 24,
          ),
          AppSpacing.hGap12,
          Text(
            'Hôm nay free! Nghỉ ngơi hoặc học thêm nhé.',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalsSection extends StatefulWidget {
  const _DailyGoalsSection({required this.date});

  final DateTime date;

  @override
  State<_DailyGoalsSection> createState() => _DailyGoalsSectionState();
}

class _DailyGoalsSectionState extends State<_DailyGoalsSection> {
  // Goals lưu theo ngày
  static final _goalsByDate = <String, List<_GoalItem>>{};

  final _controller = TextEditingController();
  bool _isAdding = false;

  String get _dateKey =>
      '${widget.date.year}-${widget.date.month}-${widget.date.day}';

  List<_GoalItem> get _goals => _goalsByDate[_dateKey] ?? [];

  @override
  void didUpdateWidget(covariant _DailyGoalsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset adding state khi đổi ngày
    if (_dateKey != '${oldWidget.date.year}-${oldWidget.date.month}-${oldWidget.date.day}') {
      _isAdding = false;
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addGoal() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final goals = List<_GoalItem>.from(_goals);
      goals.add(_GoalItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: text,
      ));
      _goalsByDate[_dateKey] = goals;
      _controller.clear();
      _isAdding = false;
    });
  }

  void _toggleGoal(String id) {
    setState(() {
      final goals = List<_GoalItem>.from(_goals);
      final index = goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        goals[index] = goals[index].copyWith(
          isCompleted: !goals[index].isCompleted,
        );
        _goalsByDate[_dateKey] = goals;
      }
    });
  }

  void _deleteGoal(String id) {
    setState(() {
      final goals = List<_GoalItem>.from(_goals);
      goals.removeWhere((g) => g.id == id);
      _goalsByDate[_dateKey] = goals;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final goals = _goals;
    final completedCount = goals.where((g) => g.isCompleted).length;
    final progress = goals.isEmpty ? 0.0 : completedCount / goals.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outline),
        boxShadow: AppShadows.layeredCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với progress
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mục tiêu hôm nay',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$completedCount/${goals.length}',
                style: tt.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppSpacing.vGap8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: cs.outline.withValues(alpha: 0.2),
              minHeight: 6,
            ),
          ),

          AppSpacing.vGap16,

          // Goals list or empty state
          if (goals.isEmpty && !_isAdding)
            _EmptyGoals(onAdd: () => setState(() => _isAdding = true))
          else ...[
            // Goals
            ...List.generate(goals.length, (index) {
              final goal = goals[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < goals.length - 1 ? AppSpacing.sm : 0,
                ),
                child: _GoalTile(
                  goal: goal,
                  onToggle: () => _toggleGoal(goal.id),
                  onDelete: () => _deleteGoal(goal.id),
                ),
              );
            }),

            // Add input or button
            AppSpacing.vGap12,
            if (_isAdding)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      style: tt.bodyLarge,
                      maxLines: 2,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Viết mục tiêu của bạn...',
                        hintStyle: tt.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: cs.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(color: cs.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(color: cs.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide(color: cs.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      onSubmitted: (_) => _addGoal(),
                    ),
                    AppSpacing.vGap12,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() {
                            _isAdding = false;
                            _controller.clear();
                          }),
                          child: Text(
                            'Huỷ',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                        AppSpacing.hGap8,
                        FilledButton.icon(
                          onPressed: _addGoal,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              InkWell(
                onTap: () => setState(() => _isAdding = true),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, size: 18, color: cs.primary),
                      AppSpacing.hGap4,
                      Text(
                        'Thêm mục tiêu',
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _GoalItem {
  _GoalItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  _GoalItem copyWith({bool? isCompleted}) {
    return _GoalItem(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.goal,
    required this.onToggle,
    required this.onDelete,
  });

  final _GoalItem goal;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.errorContainer, cs.error.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(Icons.delete_outline, size: 22, color: cs.onError),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: goal.isCompleted
              ? cs.primaryContainer.withValues(alpha: 0.3)
              : cs.surface,
          border: Border.all(
            color: goal.isCompleted
                ? cs.primary.withValues(alpha: 0.3)
                : cs.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: goal.isCompleted ? cs.primary : Colors.transparent,
                      border: Border.all(
                        color: goal.isCompleted ? cs.primary : cs.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: goal.isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Text(
                      goal.title,
                      style: tt.bodyMedium?.copyWith(
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: goal.isCompleted
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                        fontWeight: goal.isCompleted ? null : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (goal.isCompleted)
                    Icon(
                      Icons.celebration,
                      size: 16,
                      color: cs.primary.withValues(alpha: 0.6),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: cs.outline),
          AppSpacing.hGap12,
          Expanded(
            child: Text(
              'Chưa có mục tiêu. Thêm ngay!',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: onAdd,
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

