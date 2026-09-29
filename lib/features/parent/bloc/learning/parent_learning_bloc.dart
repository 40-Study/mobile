import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/learning/parent_learning_event.dart';
import 'package:study/features/parent/bloc/learning/parent_learning_state.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';

class ParentLearningBloc
    extends Bloc<ParentLearningEvent, ParentLearningState> {
  ParentLearningBloc(this._learningRepo) : super(const ParentLearningState()) {
    on<ParentLearningStarted>(_onStarted);
    on<ParentLearningChildSelected>(_onChildSelected);
    on<ParentLearningRefreshed>(_onRefreshed);
  }

  final ParentLearningRepository _learningRepo;

  Future<void> _onStarted(
    ParentLearningStarted event,
    Emitter<ParentLearningState> emit,
  ) async {
    emit(state.copyWith(status: ParentLearningStatus.loading));

    try {
      final children = await _learningRepo.getChildren();
      final allHubData = await _learningRepo.getAllLearningHubData();

      // Mặc định chọn con đầu tiên nếu có,
      // hoặc giữ null nếu phụ huynh muốn xem tất cả
      final selectedId =
          children.isNotEmpty ? children.first.id : null;
      final hubData = selectedId != null ? allHubData[selectedId] : null;

      emit(state.copyWith(
        status: ParentLearningStatus.success,
        children: children,
        selectedChildId: () => selectedId,
        hubData: () => hubData,
        allHubData: allHubData,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ParentLearningStatus.failure,
        errorMessage: e.toString,
      ));
    }
  }

  Future<void> _onChildSelected(
    ParentLearningChildSelected event,
    Emitter<ParentLearningState> emit,
  ) async {
    final selectedId = event.childId;

    if (selectedId == null) {
      // Chế độ "Tất cả các con"
      emit(state.copyWith(
        selectedChildId: () => null,
        hubData: () => null,
      ));
      return;
    }

    // Chọn 1 con cụ thể
    var hubData = state.allHubData[selectedId];
    if (hubData == null) {
      try {
        hubData = await _learningRepo.getLearningHubData(selectedId);
      } catch (_) {
        // Giữ nguyên fallback nếu có
      }
    }

    emit(state.copyWith(
      selectedChildId: () => selectedId,
      hubData: () => hubData,
    ));
  }

  Future<void> _onRefreshed(
    ParentLearningRefreshed event,
    Emitter<ParentLearningState> emit,
  ) async {
    try {
      final children = await _learningRepo.getChildren();
      final allHubData = await _learningRepo.getAllLearningHubData();
      final currentSelectedId = state.selectedChildId ??
          (children.isNotEmpty ? children.first.id : null);
      final hubData =
          currentSelectedId != null ? allHubData[currentSelectedId] : null;

      emit(state.copyWith(
        status: ParentLearningStatus.success,
        children: children,
        selectedChildId: () => currentSelectedId,
        hubData: () => hubData,
        allHubData: allHubData,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ParentLearningStatus.failure,
        errorMessage: e.toString,
      ));
    }
  }
}
