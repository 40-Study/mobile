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
            anchorWeekDate: DateTime.now(),
          ),
        ) {
    on<ParentScheduleStarted>(_onStarted);
    on<ParentScheduleChildChanged>(_onChildChanged);
    on<ParentScheduleTabChanged>(_onTabChanged);
    on<ParentScheduleDateSelected>(_onDateSelected);
    on<ParentScheduleWeekChanged>(_onWeekChanged);
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
      final targetDate = event.selectedDate ?? now;
      final children = await _repository.getChildren();

      // Mặc định chọn con đầu tiên nếu có danh sách con
      final effectiveChildId = event.childId ??
          (children.isNotEmpty ? children.first.id : null);

      final eventDates = await _repository.getEventDates(
        childId: effectiveChildId,
        anchorDate: targetDate,
      );

      final sessions = await _repository.getScheduleSessions(
        childId: effectiveChildId,
        date: targetDate,
        tab: event.tab,
      );

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          children: children,
          selectedChildId: effectiveChildId,
          selectedTab: event.tab,
          selectedDate: targetDate,
          anchorWeekDate: targetDate,
          eventDates: eventDates,
          sessions: sessions,
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
        _repository.getEventDates(
          childId: event.childId,
          anchorDate: state.anchorWeekDate,
        ),
        _repository.getScheduleSessions(
          childId: event.childId,
          date: state.selectedDate,
          tab: state.selectedTab,
        ),
      ]);

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          eventDates: results[0] as List<DateTime>,
          sessions: results[1] as List<ParentScheduleSession>,
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

  Future<void> _onTabChanged(
    ParentScheduleTabChanged event,
    Emitter<ParentScheduleState> emit,
  ) async {
    final now = DateTime.now();
    DateTime targetDate;
    if (event.tab == ParentScheduleTab.today) {
      targetDate = now;
    } else {
      targetDate = state.selectedDate;
    }

    emit(
      state.copyWith(
        status: ParentScheduleStatus.loading,
        selectedTab: event.tab,
        selectedDate: targetDate,
      ),
    );

    try {
      final sessions = await _repository.getScheduleSessions(
        childId: state.selectedChildId,
        date: targetDate,
        tab: event.tab,
      );

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          sessions: sessions,
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
    emit(
      state.copyWith(
        status: ParentScheduleStatus.loading,
        selectedDate: event.date,
      ),
    );

    try {
      final sessions = await _repository.getScheduleSessions(
        childId: state.selectedChildId,
        date: event.date,
        tab: state.selectedTab,
      );

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          sessions: sessions,
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

  Future<void> _onWeekChanged(
    ParentScheduleWeekChanged event,
    Emitter<ParentScheduleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ParentScheduleStatus.loading,
        anchorWeekDate: event.anchorDate,
      ),
    );

    try {
      final eventDates = await _repository.getEventDates(
        childId: state.selectedChildId,
        anchorDate: event.anchorDate,
      );

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          eventDates: eventDates,
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

  Future<void> _onRefreshed(
    ParentScheduleRefreshed event,
    Emitter<ParentScheduleState> emit,
  ) async {
    try {
      final results = await Future.wait([
        _repository.getChildren(),
        _repository.getEventDates(
          childId: state.selectedChildId,
          anchorDate: state.anchorWeekDate,
        ),
        _repository.getScheduleSessions(
          childId: state.selectedChildId,
          date: state.selectedDate,
          tab: state.selectedTab,
        ),
      ]);

      emit(
        state.copyWith(
          status: ParentScheduleStatus.success,
          children: results[0] as List<FamilyScopeChild>,
          eventDates: results[1] as List<DateTime>,
          sessions: results[2] as List<ParentScheduleSession>,
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
