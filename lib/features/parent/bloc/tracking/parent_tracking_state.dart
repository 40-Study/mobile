import 'package:equatable/equatable.dart';
import 'package:study/features/parent/data/models/models.dart';

sealed class ParentTrackingState extends Equatable {
  const ParentTrackingState();

  @override
  List<Object?> get props => [];
}

final class ParentTrackingInitial extends ParentTrackingState {
  const ParentTrackingInitial();
}

final class ParentTrackingLoading extends ParentTrackingState {
  const ParentTrackingLoading();
}

final class ParentTrackingLoaded extends ParentTrackingState {
  const ParentTrackingLoaded({
    required this.focusTracking,
    required this.assignmentProgress,
    required this.performanceOverview,
    required this.attendanceSummary,
    this.teacherInfo,
    required this.childId,
  });

  final FocusTrackingModel focusTracking;
  final AssignmentProgressModel assignmentProgress;
  final PerformanceOverviewModel performanceOverview;
  final AttendanceSummaryModel attendanceSummary;
  final TeacherInfoModel? teacherInfo;
  final String childId;

  @override
  List<Object?> get props => [
        focusTracking,
        assignmentProgress,
        performanceOverview,
        attendanceSummary,
        teacherInfo,
        childId,
      ];
}

final class ParentTrackingFailure extends ParentTrackingState {
  const ParentTrackingFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
