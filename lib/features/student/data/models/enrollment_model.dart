import 'package:freezed_annotation/freezed_annotation.dart';

part 'enrollment_model.freezed.dart';
part 'enrollment_model.g.dart';

enum EnrollmentStatus { active, completed, dropped, paused, pending }

@freezed
abstract class EnrollmentModel with _$EnrollmentModel {
  const factory EnrollmentModel({
    required String id,
    @JsonKey(name: 'course_id') required String courseId,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'course_thumbnail') String? courseThumbnail,
    @JsonKey(name: 'instructor_name') String? instructorName,
    @Default(0) int progress,
    @JsonKey(name: 'last_learned') String? lastLearned,
    @JsonKey(name: 'next_lesson') String? nextLesson,
    @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
    @JsonKey(name: 'completed_lessons') @Default(0) int completedLessons,
    @Default('active') String status,
    @JsonKey(name: 'enrolled_at') String? enrolledAt,
    @JsonKey(name: 'completed_at') String? completedAt,
  }) = _EnrollmentModel;

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      _$EnrollmentModelFromJson(json);
}

extension EnrollmentModelX on EnrollmentModel {
  EnrollmentStatus get enrollmentStatus {
    switch (status.toLowerCase()) {
      case 'completed':
        return EnrollmentStatus.completed;
      case 'dropped':
        return EnrollmentStatus.dropped;
      case 'paused':
        return EnrollmentStatus.paused;
      case 'pending':
        return EnrollmentStatus.pending;
      default:
        return EnrollmentStatus.active;
    }
  }

  bool get isActive => enrollmentStatus == EnrollmentStatus.active;
  bool get isCompleted => enrollmentStatus == EnrollmentStatus.completed;
  bool get isPending => enrollmentStatus == EnrollmentStatus.pending;

  String get progressText => '$completedLessons/$totalLessons bai hoc';

  String get lastLearnedDisplay {
    if (lastLearned == null) return 'Chua bat dau';
    // Parse and format date if needed
    return lastLearned!;
  }
}
