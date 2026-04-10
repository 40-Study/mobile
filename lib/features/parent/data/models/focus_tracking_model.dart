import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_tracking_model.freezed.dart';
part 'focus_tracking_model.g.dart';

@freezed
abstract class FocusTrackingModel with _$FocusTrackingModel {
  const factory FocusTrackingModel({
    @Default([]) List<FocusSessionModel> sessions,
    @JsonKey(name: 'average_focus') @Default(0.0) double averageFocus,
    @JsonKey(name: 'best_session') FocusSessionModel? bestSession,
    @JsonKey(name: 'worst_session') FocusSessionModel? worstSession,
    @JsonKey(name: 'total_sessions') @Default(0) int totalSessions,
  }) = _FocusTrackingModel;

  factory FocusTrackingModel.fromJson(Map<String, dynamic> json) =>
      _$FocusTrackingModelFromJson(json);
}

@freezed
abstract class FocusSessionModel with _$FocusSessionModel {
  const factory FocusSessionModel({
    required String id,
    required String date,
    @JsonKey(name: 'class_name') required String className,
    @JsonKey(name: 'focus_score') required double focusScore,
    @JsonKey(name: 'duration_minutes') @Default(0) int durationMinutes,
    @JsonKey(name: 'session_type') String? sessionType,
    String? note,
  }) = _FocusSessionModel;

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) =>
      _$FocusSessionModelFromJson(json);
}

@freezed
abstract class TrackingOverviewModel with _$TrackingOverviewModel {
  const factory TrackingOverviewModel({
    required FocusTrackingModel focusTracking,
    @JsonKey(name: 'assignment_progress') required AssignmentProgressModel assignmentProgress,
    @JsonKey(name: 'performance_overview') required PerformanceOverviewModel performanceOverview,
    @JsonKey(name: 'attendance_summary') required AttendanceSummaryModel attendanceSummary,
    @JsonKey(name: 'teacher_info') TeacherInfoModel? teacherInfo,
  }) = _TrackingOverviewModel;

  factory TrackingOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingOverviewModelFromJson(json);
}

@freezed
abstract class AssignmentProgressModel with _$AssignmentProgressModel {
  const factory AssignmentProgressModel({
    @JsonKey(name: 'total_assignments') @Default(0) int totalAssignments,
    @JsonKey(name: 'completed_count') @Default(0) int completedCount,
    @JsonKey(name: 'missing_count') @Default(0) int missingCount,
    @JsonKey(name: 'late_count') @Default(0) int lateCount,
    @JsonKey(name: 'pending_count') @Default(0) int pendingCount,
    @Default([]) List<ChildAssignmentModel> assignments,
  }) = _AssignmentProgressModel;

  factory AssignmentProgressModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentProgressModelFromJson(json);
}

@freezed
abstract class PerformanceOverviewModel with _$PerformanceOverviewModel {
  const factory PerformanceOverviewModel({
    @JsonKey(name: 'average_score') @Default(0.0) double averageScore,
    @JsonKey(name: 'highest_score') @Default(0.0) double highestScore,
    @JsonKey(name: 'lowest_score') @Default(0.0) double lowestScore,
    @Default([]) List<ChildPerformanceModel> performances,
  }) = _PerformanceOverviewModel;

  factory PerformanceOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$PerformanceOverviewModelFromJson(json);
}

@freezed
abstract class AttendanceSummaryModel with _$AttendanceSummaryModel {
  const factory AttendanceSummaryModel({
    @JsonKey(name: 'total_sessions') @Default(0) int totalSessions,
    @JsonKey(name: 'present_count') @Default(0) int presentCount,
    @JsonKey(name: 'absent_count') @Default(0) int absentCount,
    @JsonKey(name: 'late_count') @Default(0) int lateCount,
    @JsonKey(name: 'excused_count') @Default(0) int excusedCount,
    @JsonKey(name: 'attendance_rate') @Default(0.0) double attendanceRate,
  }) = _AttendanceSummaryModel;

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryModelFromJson(json);
}

@freezed
abstract class TeacherInfoModel with _$TeacherInfoModel {
  const factory TeacherInfoModel({
    required String id,
    required String name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? email,
    String? phone,
    @JsonKey(name: 'years_of_experience') int? yearsOfExperience,
    String? specialization,
  }) = _TeacherInfoModel;

  factory TeacherInfoModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherInfoModelFromJson(json);
}

// Child Assignment Model
@freezed
abstract class ChildAssignmentModel with _$ChildAssignmentModel {
  const factory ChildAssignmentModel({
    required String id,
    required String title,
    @JsonKey(name: 'class_name') String? className,
    required AssignmentStatus status,
    double? score,
    @JsonKey(name: 'max_score') double? maxScore,
    @JsonKey(name: 'due_date') String? dueDate,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'teacher_feedback') String? teacherFeedback,
    @JsonKey(name: 'assignment_type') @Default(AssignmentType.assignment) AssignmentType type,
  }) = _ChildAssignmentModel;

  factory ChildAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$ChildAssignmentModelFromJson(json);
}

@JsonEnum()
enum AssignmentStatus {
  @JsonValue('completed')
  completed,
  @JsonValue('missing')
  missing,
  @JsonValue('late')
  late,
  @JsonValue('pending')
  pending,
}

@JsonEnum()
enum AssignmentType {
  @JsonValue('assignment')
  assignment,
  @JsonValue('project')
  project,
  @JsonValue('test')
  test,
}

// Child Performance Model
@freezed
abstract class ChildPerformanceModel with _$ChildPerformanceModel {
  const factory ChildPerformanceModel({
    required String id,
    required String title,
    required double score,
    @JsonKey(name: 'max_score') @Default(10.0) double maxScore,
    @JsonKey(name: 'class_name') String? className,
    required String date,
  }) = _ChildPerformanceModel;

  factory ChildPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$ChildPerformanceModelFromJson(json);
}
