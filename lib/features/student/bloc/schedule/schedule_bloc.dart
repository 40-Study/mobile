import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc(this._repository) : super(const ScheduleInitial()) {
    on<ScheduleStarted>(_onStarted);
    on<ScheduleDateSelected>(_onDateSelected);
    on<ScheduleMonthChanged>(_onMonthChanged);
    on<ScheduleNoteSaved>(_onNoteSaved);
    on<ScheduleNoteDeleted>(_onNoteDeleted);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(
    ScheduleStarted event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleInProgress());

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Load today's schedule
    final result = await _repository.getTodaySchedule();

    result.when(
      success: (items) {
        final currentMonth = DateTime(now.year, now.month);
        final eventDates = _generateMockEventDates(currentMonth);

        emit(ScheduleSuccess(
          currentMonth: DateTime(now.year, now.month),
          selectedDate: today,
          eventDates: eventDates,
          selectedDateItems: items,
        ));
      },
      failure: (error) {
        emit(ScheduleFailure(error.message ?? 'Loi khong xac dinh'));
      },
    );
  }

  Future<void> _onDateSelected(
    ScheduleDateSelected event,
    Emitter<ScheduleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ScheduleSuccess) return;

    final selectedDate = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );

    // Show loading
    emit(currentState.copyWith(
      selectedDate: selectedDate,
      isLoadingDay: true,
    ));

    // Load schedule for selected date
    final result = await _repository.getScheduleByDate(selectedDate);

    // Get fresh state after async
    final freshState = state;
    if (freshState is! ScheduleSuccess) return;

    result.when(
      success: (items) {
        emit(freshState.copyWith(
          selectedDate: selectedDate,
          selectedDateItems: items,
          isLoadingDay: false,
        ));
      },
      failure: (error) {
        emit(freshState.copyWith(
          selectedDate: selectedDate,
          selectedDateItems: const [],
          isLoadingDay: false,
        ));
      },
    );
  }

  Future<void> _onMonthChanged(
    ScheduleMonthChanged event,
    Emitter<ScheduleState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ScheduleSuccess) return;

    final newMonth = DateTime(event.month.year, event.month.month);

    // Mock event dates cho tháng mới
    final eventDates = _generateMockEventDates(newMonth);

    emit(currentState.copyWith(
      currentMonth: newMonth,
      eventDates: eventDates,
    ));
  }

  void _onNoteSaved(
    ScheduleNoteSaved event,
    Emitter<ScheduleState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScheduleSuccess) return;

    final key = ScheduleSuccess.dateKey(event.date);
    final updatedNotes = Map<String, String>.from(currentState.dailyNotes);

    if (event.note.trim().isEmpty) {
      updatedNotes.remove(key);
    } else {
      updatedNotes[key] = event.note.trim();
    }

    emit(currentState.copyWith(dailyNotes: updatedNotes));
  }

  void _onNoteDeleted(
    ScheduleNoteDeleted event,
    Emitter<ScheduleState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScheduleSuccess) return;

    final key = ScheduleSuccess.dateKey(event.date);
    final updatedNotes = Map<String, String>.from(currentState.dailyNotes)
      ..remove(key);

    emit(currentState.copyWith(dailyNotes: updatedNotes));
  }

  /// Mock event dates - thay bằng API call sau
  Set<DateTime> _generateMockEventDates(DateTime month) {
    final dates = <DateTime>{};
    // Tạo vài ngày có lịch trong tháng
    for (var i = 0; i < 28; i += 3) {
      if (i + 1 <= 28) {
        dates.add(DateTime(month.year, month.month, i + 1));
      }
    }
    // Thêm ngày hôm nay nếu trong tháng này
    final now = DateTime.now();
    if (now.year == month.year && now.month == month.month) {
      dates.add(DateTime(now.year, now.month, now.day));
    }
    return dates;
  }
}
