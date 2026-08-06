import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/course/data/models/course_model.dart';

part 'enrollment_model.freezed.dart';
part 'enrollment_model.g.dart';

@freezed
abstract class EnrollmentModel with _$EnrollmentModel {
  const factory EnrollmentModel({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'course_id') String? courseId,
    CourseModel? course,
    String? status,
    @JsonKey(name: 'progress_percentage') @Default(0) double progressPercentage,
    @JsonKey(name: 'completed_lessons') @Default(0) int completedLessons,
    @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
    @JsonKey(name: 'last_accessed_at') DateTime? lastAccessedAt,
    @JsonKey(name: 'enrolled_at') DateTime? enrolledAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _EnrollmentModel;

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      _$EnrollmentModelFromJson(json);
}
