import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc(this._repository) : super(const ScheduleInitial()) {
    on<ScheduleStarted>(_onStarted);
    on<ScheduleDateSelected>(_onDateSelected);
    on<ScheduleMonthChanged>(_onMonthChanged);
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
        // Mock event dates for demo
        final eventDates = <DateTime>{
          today,
          today.add(const Duration(days: 2)),
          today.add(const Duration(days: 5)),
          today.add(const Duration(days: 7)),
        };

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

    result.when(
      success: (items) {
        emit(currentState.copyWith(
          selectedDate: selectedDate,
          selectedDateItems: items,
          isLoadingDay: false,
        ));
      },
      failure: (error) {
        emit(currentState.copyWith(
          selectedDate: selectedDate,
          selectedDateItems: [],
          isLoadingDay: false,
        ));
      },
    );
  }

  void _onMonthChanged(
    ScheduleMonthChanged event,
    Emitter<ScheduleState> emit,
  ) {
    final currentState = state;
    if (currentState is! ScheduleSuccess) return;

    emit(currentState.copyWith(
      currentMonth: DateTime(event.month.year, event.month.month),
    ));

    // TODO: Load event dates for new month from API
  }
}
