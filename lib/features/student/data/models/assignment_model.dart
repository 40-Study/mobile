import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_model.freezed.dart';
part 'assignment_model.g.dart';

@freezed
abstract class AssignmentModel with _$AssignmentModel {
  const factory AssignmentModel({
    required String id,
    required String title,
    required String type,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'lesson_id') String? lessonId,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'question_count') @Default(0) int questionCount,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'submitted_at') DateTime? submittedAt,
    double? score,
  }) = _AssignmentModel;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModelFromJson(json);
}
