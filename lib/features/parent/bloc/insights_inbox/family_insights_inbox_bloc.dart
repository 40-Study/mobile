import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/features/parent/bloc/insights_inbox/family_insights_inbox_event.dart';
import 'package:study/features/parent/bloc/insights_inbox/family_insights_inbox_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/repository/family_insights_repository.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';

class FamilyInsightsInboxBloc
    extends Bloc<FamilyInsightsInboxEvent, FamilyInsightsInboxState> {
  FamilyInsightsInboxBloc({
    required FamilyInsightsRepository insightsRepository,
    required ParentHomeRepository homeRepository,
  })  : _insightsRepo = insightsRepository,
        _homeRepo = homeRepository,
        super(const FamilyInsightsInboxInitial()) {
    on<FamilyInsightsInboxStarted>(_onStarted);
    on<FamilyInsightsInboxChildFilterChanged>(_onFilterChanged);
    on<FamilyInsightsInboxMarkAllAsRead>(_onMarkAllAsRead);
    on<FamilyInsightsInboxSendEncouraged>(_onSendEncouraged);
    on<FamilyInsightsInboxRefreshed>(_onRefreshed);
  }

  final FamilyInsightsRepository _insightsRepo;
  final ParentHomeRepository _homeRepo;
  String? _currentChildId;

  Future<void> _onStarted(
    FamilyInsightsInboxStarted event,
    Emitter<FamilyInsightsInboxState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    FamilyInsightsInboxRefreshed event,
    Emitter<FamilyInsightsInboxState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onFilterChanged(
    FamilyInsightsInboxChildFilterChanged event,
    Emitter<FamilyInsightsInboxState> emit,
  ) async {
    _currentChildId = event.childId;
    final currentState = state;
    if (currentState is FamilyInsightsInboxSuccess) {
      final filtered = _filterInsights(
        currentState.allInsights,
        _currentChildId,
      );
      emit(
        currentState.copyWith(
          selectedChildId: _currentChildId,
          clearSelectedChild: _currentChildId == null,
          insights: filtered,
        ),
      );
    }
  }

  Future<void> _onMarkAllAsRead(
    FamilyInsightsInboxMarkAllAsRead event,
    Emitter<FamilyInsightsInboxState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FamilyInsightsInboxSuccess) return;

    try {
      await _insightsRepo.markAllAsRead();
      final updatedAll = currentState.allInsights
          .map((i) => i.copyWith(isRead: true))
          .toList();
      final updatedFiltered = currentState.insights
          .map((i) => i.copyWith(isRead: true))
          .toList();

      emit(
        currentState.copyWith(
          allInsights: updatedAll,
          insights: updatedFiltered,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onSendEncouraged(
    FamilyInsightsInboxSendEncouraged event,
    Emitter<FamilyInsightsInboxState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FamilyInsightsInboxSuccess) return;

    try {
      await _insightsRepo.sendEncouragement(event.insightId);
      final newEncouraged = Set<String>.from(currentState.encouragedIds)
        ..add(event.insightId);

      final updatedAll = currentState.allInsights.map((item) {
        if (item.id == event.insightId) {
          return item.copyWith(hasEncouraged: true);
        }
        return item;
      }).toList();

      final updatedFiltered = currentState.insights.map((item) {
        if (item.id == event.insightId) {
          return item.copyWith(hasEncouraged: true);
        }
        return item;
      }).toList();

      emit(
        currentState.copyWith(
          encouragedIds: newEncouraged,
          allInsights: updatedAll,
          insights: updatedFiltered,
        ),
      );
    } catch (_) {}
  }

  Future<void> _loadData(Emitter<FamilyInsightsInboxState> emit) async {
    emit(const FamilyInsightsInboxLoading());
    try {
      final results = await Future.wait([
        _homeRepo.getChildren(),
        _insightsRepo.getInsights(),
      ]);

      final childrenList = results[0] as List<FamilyScopeChild>;
      final insightsList = results[1] as List<FamilyInsightItem>;

      final filtered = _filterInsights(insightsList, _currentChildId);

      emit(
        FamilyInsightsInboxSuccess(
          allInsights: insightsList,
          insights: filtered,
          children: childrenList,
          selectedChildId: _currentChildId,
        ),
      );
    } catch (e) {
      emit(FamilyInsightsInboxFailure(_formatErrorMessage(e)));
    }
  }

  List<FamilyInsightItem> _filterInsights(
    List<FamilyInsightItem> all,
    String? childId,
  ) {
    if (childId == null) return all;
    return all.where((item) => item.childId == childId).toList();
  }

  String _formatErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'Kết nối mạng quá thời gian. Vui lòng thử lại.';
    }
    if (error is Failure) {
      return error.message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
    return 'Không thể tải danh sách phân tích. Vui lòng thử lại.';
  }
}
