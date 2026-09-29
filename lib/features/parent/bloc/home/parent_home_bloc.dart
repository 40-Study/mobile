import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/features/parent/bloc/home/parent_home_event.dart';
import 'package:study/features/parent/bloc/home/parent_home_state.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';

class ParentHomeBloc extends Bloc<ParentHomeEvent, ParentHomeState> {
  ParentHomeBloc(this._repository) : super(const ParentHomeInitial()) {
    on<ParentHomeStarted>(_onStarted);
    on<ParentHomeChildSelected>(_onChildSelected);
    on<ParentHomeRefreshed>(_onRefreshed);
    on<ParentHomeSectionRetried>(_onSectionRetried);
  }

  final ParentHomeRepository _repository;
  String? _selectedChildId;

  Future<void> _onStarted(
    ParentHomeStarted event,
    Emitter<ParentHomeState> emit,
  ) async {
    await _initializeDashboard(emit);
  }

  Future<void> _onChildSelected(
    ParentHomeChildSelected event,
    Emitter<ParentHomeState> emit,
  ) async {
    _selectedChildId = event.childId;
    final currentState = state;
    if (currentState is ParentHomeSuccess) {
      emit(
        currentState.copyWith(
          selectedChildId: _selectedChildId,
          clearSelectedChild: _selectedChildId == null,
          alertsStatus: HomeSectionStatus.loading,
          schedulesStatus: HomeSectionStatus.loading,
          analyticsStatus: HomeSectionStatus.loading,
        ),
      );
      await _loadSectionsIndependently(emit);
    } else {
      await _initializeDashboard(emit);
    }
  }

  Future<void> _onRefreshed(
    ParentHomeRefreshed event,
    Emitter<ParentHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is ParentHomeSuccess) {
      emit(
        currentState.copyWith(
          alertsStatus: HomeSectionStatus.loading,
          schedulesStatus: HomeSectionStatus.loading,
          analyticsStatus: HomeSectionStatus.loading,
        ),
      );
      await _loadSectionsIndependently(emit);
    } else {
      await _initializeDashboard(emit);
    }
  }

  Future<void> _onSectionRetried(
    ParentHomeSectionRetried event,
    Emitter<ParentHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ParentHomeSuccess) return;

    switch (event.section) {
      case ParentHomeSection.alerts:
        emit(
          currentState.copyWith(
            alertsStatus: HomeSectionStatus.loading,
            alertsErrorMessage: null,
          ),
        );
        await _fetchAlerts(emit);
      case ParentHomeSection.schedules:
        emit(
          currentState.copyWith(
            schedulesStatus: HomeSectionStatus.loading,
            schedulesErrorMessage: null,
          ),
        );
        await _fetchSchedules(emit);
      case ParentHomeSection.analytics:
        emit(
          currentState.copyWith(
            analyticsStatus: HomeSectionStatus.loading,
            analyticsErrorMessage: null,
          ),
        );
        await _fetchAnalytics(emit);
    }
  }

  Future<void> _initializeDashboard(Emitter<ParentHomeState> emit) async {
    emit(const ParentHomeLoading());
    try {
      final children = await _repository.getChildren();
      emit(
        ParentHomeSuccess(
          children: children,
          selectedChildId: _selectedChildId,
          alertsStatus: HomeSectionStatus.loading,
          schedulesStatus: HomeSectionStatus.loading,
          analyticsStatus: HomeSectionStatus.loading,
        ),
      );
      await _loadSectionsIndependently(emit);
    } catch (e) {
      emit(ParentHomeFailure(_formatErrorMessage(e)));
    }
  }

  Future<void> _loadSectionsIndependently(Emitter<ParentHomeState> emit) async {
    // Tải song song cả 3 khối, lỗi ở khối nào xử lý riêng ở khối đó
    await Future.wait([
      _fetchAlerts(emit),
      _fetchSchedules(emit),
      _fetchAnalytics(emit),
    ]);
  }

  Future<void> _fetchAlerts(Emitter<ParentHomeState> emit) async {
    try {
      final alerts = await _repository.getAlerts(childId: _selectedChildId);
      final current = state;
      if (current is ParentHomeSuccess) {
        emit(
          current.copyWith(
            alerts: alerts,
            alertsStatus: HomeSectionStatus.success,
            alertsErrorMessage: null,
          ),
        );
      }
    } catch (e) {
      final current = state;
      if (current is ParentHomeSuccess) {
        emit(
          current.copyWith(
            alertsStatus: HomeSectionStatus.failure,
            alertsErrorMessage: _formatErrorMessage(e),
          ),
        );
      }
    }
  }

  Future<void> _fetchSchedules(Emitter<ParentHomeState> emit) async {
    try {
      final schedules =
          await _repository.getSchedules(childId: _selectedChildId);
      final current = state;
      if (current is ParentHomeSuccess) {
        emit(
          current.copyWith(
            schedules: schedules,
            schedulesStatus: HomeSectionStatus.success,
            schedulesErrorMessage: null,
          ),
        );
      }
    } catch (e) {
      final current = state;
      if (current is ParentHomeSuccess) {
        emit(
          current.copyWith(
            schedulesStatus: HomeSectionStatus.failure,
            schedulesErrorMessage: _formatErrorMessage(e),
          ),
        );
      }
    }
  }

  Future<void> _fetchAnalytics(Emitter<ParentHomeState> emit) async {
    try {
      final analyticsList =
          await _repository.getAnalyticsList(childId: _selectedChildId);
      final singleAnalytics = analyticsList.firstOrNull;
      final current = state;
      if (current is ParentHomeSuccess) {
        emit(
          current.copyWith(
            analytics: singleAnalytics,
            analyticsList: analyticsList,
            analyticsStatus: HomeSectionStatus.success,
            analyticsErrorMessage: null,
          ),
        );
      }
    } catch (e) {
      final current = state;
      if (current is ParentHomeSuccess) {
        emit(
          current.copyWith(
            analyticsStatus: HomeSectionStatus.failure,
            analyticsErrorMessage: _formatErrorMessage(e),
          ),
        );
      }
    }
  }


  /// Chuyển đổi lỗi thành thông báo thân thiện bằng tiếng Việt trên giao diện
  String _formatErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'Kết nối quá thời gian. Vui lòng kiểm tra lại mạng và thử lại.';
    }
    if (error is Failure) {
      return error.message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('kết nối') ||
        text.contains('Failed host lookup')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.';
    }
    if (text.contains('401') || text.contains('Unauthorized')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }
    return 'Không thể tải dữ liệu lúc này.';
  }
}
