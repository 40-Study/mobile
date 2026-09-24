import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:study/features/parent/bloc/schedule/parent_schedule_event.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_state.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/repository/parent_schedule_repository.dart';

class ParentScheduleBloc
    extends Bloc<ParentScheduleEvent, ParentScheduleState> {
  ParentScheduleBloc(this._repository)
      : super(
          ParentScheduleState(
            selectedDate: DateTime.now(),
            currentMonth: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              1,
            ),
          ),
        ) {
    on<ParentScheduleStarted>(_onStarted);
    on<ParentScheduleChildChanged>(_onChildChanged);
    on<ParentScheduleDateSelected>(_onDateSelected);
    on<ParentScheduleMonthChanged>(_onMonthChanged);
    on<ParentScheduleCalendarModeToggled>(_onCalendarModeToggled);
    on<ParentScheduleRefreshed>(_onRefreshed);
  }

  final ParentScheduleRepository _repository;

  Future<void> _onStarted(
    ParentScheduleStarted event,
    Emitter<ParentScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ParentScheduleStatus.loading));
    try {
      final now = DateTime.now();
      final targetDate = event.initialDate ?? now;
      final currentMonth = DateTime(targetDate.year, targetDate.month, 1);
      final children = await _repository.getChildren();

      final effectiveChildId = event.childId;

      final results = await Future.wait([
        _repository.getSessionsForDate(
          childId: effectiveChildId,
          date: targetDate,
        ),
        _repository.getEventsMapByMonth(
          childId: effectiveChildId,
          month: currentMonth,
        ),
        _repository.getSessionCountForWeek(
          childId: effectiveChildId,
          anchorDate: targetDate,
        ),
      ]);

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          children: children,
          selectedChildId: effectiveChildId,
          selectedDate: targetDate,
          currentMonth: currentMonth,
          sessions: results[0] as List<ParentScheduleSession>,
          eventsMap: results[1] as Map<DateTime, List<String>>,
          totalSessionsInWeek: results[2] as int,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ParentScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onChildChanged(
    ParentScheduleChildChanged event,
    Emitter<ParentScheduleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ParentScheduleStatus.loading,
        selectedChildId: event.childId,
        clearSelectedChild: event.childId == null,
      ),
    );
    try {
      final results = await Future.wait([
        _repository.getSessionsForDate(
          childId: event.childId,
          date: state.selectedDate,
        ),
        _repository.getEventsMapByMonth(
          childId: event.childId,
          month: state.currentMonth,
        ),
        _repository.getSessionCountForWeek(
          childId: event.childId,
          anchorDate: state.selectedDate,
        ),
      ]);

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          sessions: results[0] as List<ParentScheduleSession>,
          eventsMap: results[1] as Map<DateTime, List<String>>,
          totalSessionsInWeek: results[2] as int,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ParentScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDateSelected(
    ParentScheduleDateSelected event,
    Emitter<ParentScheduleState> emit,
  ) async {
    final newDate = event.date;
    final isMonthChanged = newDate.year != state.currentMonth.year ||
        newDate.month != state.currentMonth.month;
    final updatedMonth = isMonthChanged
        ? DateTime(newDate.year, newDate.month, 1)
        : state.currentMonth;

    emit(
      state.copyWith(
        status: ParentScheduleStatus.loading,
        selectedDate: newDate,
        currentMonth: updatedMonth,
      ),
    );

    try {
      final futures = <Future<dynamic>>[
        _repository.getSessionsForDate(
          childId: state.selectedChildId,
          date: newDate,
        ),
        _repository.getSessionCountForWeek(
          childId: state.selectedChildId,
          anchorDate: newDate,
        ),
      ];

      if (isMonthChanged) {
        futures.add(
          _repository.getEventsMapByMonth(
            childId: state.selectedChildId,
            month: updatedMonth,
          ),
        );
      }

      final results = await Future.wait(futures);

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          sessions: results[0] as List<ParentScheduleSession>,
          totalSessionsInWeek: results[1] as int,
          eventsMap: isMonthChanged
              ? (results[2] as Map<DateTime, List<String>>)
              : null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ParentScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMonthChanged(
    ParentScheduleMonthChanged event,
    Emitter<ParentScheduleState> emit,
  ) async {
    final newMonth = DateTime(event.month.year, event.month.month, 1);
    emit(
      state.copyWith(
        status: ParentScheduleStatus.loading,
        currentMonth: newMonth,
      ),
    );

    try {
      final eventsMap = await _repository.getEventsMapByMonth(
        childId: state.selectedChildId,
        month: newMonth,
      );

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          eventsMap: eventsMap,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ParentScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onCalendarModeToggled(
    ParentScheduleCalendarModeToggled event,
    Emitter<ParentScheduleState> emit,
  ) {
    emit(
      state.copyWith(
        isCalendarExpanded: !state.isCalendarExpanded,
      ),
    );
  }

  Future<void> _onRefreshed(
    ParentScheduleRefreshed event,
    Emitter<ParentScheduleState> emit,
  ) async {
    try {
      final results = await Future.wait([
        _repository.getChildren(),
        _repository.getSessionsForDate(
          childId: state.selectedChildId,
          date: state.selectedDate,
        ),
        _repository.getEventsMapByMonth(
          childId: state.selectedChildId,
          month: state.currentMonth,
        ),
        _repository.getSessionCountForWeek(
          childId: state.selectedChildId,
          anchorDate: state.selectedDate,
        ),
      ]);

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          children: results[0] as List<FamilyScopeChild>,
          sessions: results[1] as List<ParentScheduleSession>,
          eventsMap: results[2] as Map<DateTime, List<String>>,
          totalSessionsInWeek: results[3] as int,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ParentScheduleStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
