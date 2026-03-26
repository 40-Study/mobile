import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/lesson_detail/lesson_detail_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/widgets/schedule/schedule_widgets.dart';

class LearningScheduleTab extends StatefulWidget {
  const LearningScheduleTab({super.key});

  @override
  State<LearningScheduleTab> createState() => _LearningScheduleTabState();
}

class _LearningScheduleTabState extends State<LearningScheduleTab> {
  List<StudentScheduleModel> _schedules = [];
  bool _loading = true;
  late int _selectedDayIndex;
  String _selectedFilter = 'all';
  late final List<CalendarDayItem> _weekDays;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = DateTime.now().weekday - 1;
    _weekDays = _buildWeekDays();
    _loadSchedules();
  }

  List<CalendarDayItem> _buildWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      return CalendarDayItem(
        label: dayLabels[i],
        day: date.day,
        date: date,
        isToday: date.day == now.day &&
            date.month == now.month &&
            date.year == now.year,
      );
    });
  }

  Future<void> _loadSchedules() async {
    setState(() => _loading = true);
    try {
      final repo = context.read<StudentRepository>();
      final data = await repo.getTodaySchedule();
      if (mounted) {
        setState(() {
          _schedules = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<StudentScheduleModel> get _filteredSchedules {
    if (_selectedFilter == 'all') return _schedules;
    return _schedules
        .where((s) => s.className == _selectedFilter)
        .toList();
  }

  List<String> get _courseFilters {
    return _schedules
        .map((s) => s.className ?? '')
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList();
  }

  void _openLesson(StudentScheduleModel schedule) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => LessonDetailCubit(lessonId: schedule.id),
          child: LessonDetailScreen(
            lessonId: schedule.id,
            lessonTitle: schedule.title ?? schedule.className ?? '',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScheduleCalendarStrip(
          days: _weekDays,
          selectedIndex: _selectedDayIndex,
          onSelected: (i) => setState(() => _selectedDayIndex = i),
        ),
        const SizedBox(height: AppSpacing.lg),
        ScheduleFilterChips(
          filters: _courseFilters,
          selected: _selectedFilter,
          onSelected: (f) => setState(() => _selectedFilter = f),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filteredSchedules.isEmpty
                  ? const ScheduleEmptyState()
                  : ScheduleTimeline(
                      schedules: _filteredSchedules,
                      onTap: _openLesson,
                    ),
        ),
      ],
    );
  }
}
