import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_cubit.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_state.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_event.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/repository/parent_repository.dart';

class ParentDashboardBloc
    extends Bloc<ParentDashboardEvent, ParentDashboardState> {
  ParentDashboardBloc(this._repository, this._childSelector)
      : super(const ParentDashboardInitial()) {
    on<ParentDashboardStarted>(_onStarted);
    on<ParentDashboardRefreshed>(_onRefreshed);

    // Reload khi đổi child
    _childSubscription = _childSelector.stream.listen(_onChildChanged);
  }

  final ParentRepository _repository;
  final ChildSelectorCubit _childSelector;
  StreamSubscription<ChildSelectorState>? _childSubscription;
  String? _lastChildId;

  void _onChildChanged(ChildSelectorState state) {
    final newChildId = state.selectedChild?.id;
    if (newChildId != null && newChildId != _lastChildId) {
      _lastChildId = newChildId;
      add(ParentDashboardRefreshed());
    }
  }

  @override
  Future<void> close() {
    _childSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    ParentDashboardStarted event,
    Emitter<ParentDashboardState> emit,
  ) async {
    _lastChildId = _childSelector.state.selectedChild?.id;
    emit(const ParentDashboardLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    ParentDashboardRefreshed event,
    Emitter<ParentDashboardState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<ParentDashboardState> emit) async {
    final children = _childSelector.state.children;
    if (children.isEmpty) {
      emit(const ParentDashboardFailure('Chưa có thông tin con'));
      return;
    }

    final selectedChild = _childSelector.state.selectedChild ?? children.first;

    // Load all data in parallel
    final results = await Future.wait([
      _repository.getAlerts(),
      _repository.getChildSchedule(selectedChild.id),
      _repository.getChildCourses(selectedChild.id),
      ...children.map((c) => _repository.getChildOverview(c.id)),
    ]);

    final alertsResult = results[0] as ApiResult<List<ParentAlertModel>>;
    final scheduleResult = results[1] as ApiResult<List<ChildScheduleModel>>;
    final coursesResult = results[2] as ApiResult<List<ChildCourseModel>>;
    final overviewResults = results.skip(3).cast<ApiResult<ChildOverviewModel>>();

    final overviews = overviewResults
        .where((r) => r.isSuccess)
        .map((r) => r.valueOrNull!)
        .toList();

    // Calculate monthly stats
    final stats = MonthlyStats(
      totalCourses: children.fold(0, (sum, c) => sum + c.enrolledCourses),
      totalStudyHours: overviews.fold(0.0, (sum, o) => sum + o.studyHoursWeek),
      avgAttendance: overviews.isEmpty
          ? 0
          : overviews.fold(0.0, (sum, o) => sum + o.attendanceRate) /
              overviews.length,
      totalExpenses: 0,
    );

    emit(ParentDashboardSuccess(
      alerts: alertsResult.valueOrNull ?? [],
      childOverviews: overviews,
      monthlyStats: stats,
      schedule: scheduleResult.valueOrNull ?? [],
      courses: coursesResult.valueOrNull ?? [],
    ));
  }
}
