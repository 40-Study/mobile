import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/tracking/parent_tracking_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';

class ParentTrackingCubit extends Cubit<ParentTrackingState> {
  ParentTrackingCubit({
    required ParentRepository repository,
  })  : _repository = repository,
        super(const ParentTrackingInitial());

  final ParentRepository _repository;

  Future<void> loadTracking(String childId) async {
    emit(const ParentTrackingLoading());

    try {
      final trackingOverview = await _repository.getTrackingOverview(childId);

      emit(ParentTrackingLoaded(
        focusTracking: trackingOverview.focusTracking,
        assignmentProgress: trackingOverview.assignmentProgress,
        performanceOverview: trackingOverview.performanceOverview,
        attendanceSummary: trackingOverview.attendanceSummary,
        teacherInfo: trackingOverview.teacherInfo,
        childId: childId,
      ));
    } catch (e) {
      emit(ParentTrackingFailure(message: e.toString()));
    }
  }

  Future<void> refresh(String childId) async {
    try {
      final trackingOverview = await _repository.getTrackingOverview(childId);

      emit(ParentTrackingLoaded(
        focusTracking: trackingOverview.focusTracking,
        assignmentProgress: trackingOverview.assignmentProgress,
        performanceOverview: trackingOverview.performanceOverview,
        attendanceSummary: trackingOverview.attendanceSummary,
        teacherInfo: trackingOverview.teacherInfo,
        childId: childId,
      ));
    } catch (e) {
      emit(ParentTrackingFailure(message: e.toString()));
    }
  }
}
