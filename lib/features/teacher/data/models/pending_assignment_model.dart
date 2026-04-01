import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_assignment_model.freezed.dart';
part 'pending_assignment_model.g.dart';

@freezed
abstract class PendingAssignmentModel with _$PendingAssignmentModel {
  const factory PendingAssignmentModel({
    required String id,
    @JsonKey(name: 'student_name') required String studentName,
    @JsonKey(name: 'student_avatar') String? studentAvatar,
    @JsonKey(name: 'assignment_title') required String assignmentTitle,
    @JsonKey(name: 'submitted_at') required String submittedAt,
    @JsonKey(name: 'course_name') String? courseName,
  }) = _PendingAssignmentModel;

  factory PendingAssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$PendingAssignmentModelFromJson(json);
}
