import 'package:freezed_annotation/freezed_annotation.dart';

part 'enrollment_model.freezed.dart';
part 'enrollment_model.g.dart';

enum EnrollmentStatus { active, completed, dropped, paused, pending }

/// Enrollment model theo API DOCS - GET /enrollments
/// Response: EnrollmentListResponseDTO
@freezed
abstract class EnrollmentModel with _$EnrollmentModel {
  const factory EnrollmentModel({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'course_id') required String courseId,
    @JsonKey(name: 'enrolled_at') String? enrolledAt,
    @JsonKey(name: 'progress_percentage') @Default('0') String progressPercentage,
    @JsonKey(name: 'completed_at') String? completedAt,
    @JsonKey(name: 'last_accessed_at') String? lastAccessedAt,
    // Course info from API
    @JsonKey(name: 'course_title') String? courseTitle,
    @JsonKey(name: 'course_slug') String? courseSlug,
    @JsonKey(name: 'course_thumbnail') String? courseThumbnail,
    @JsonKey(name: 'course_category') String? courseCategory,
    // Legacy fields for backward compatibility
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'instructor_name') String? instructorName,
    @Default(0) int progress,
    @JsonKey(name: 'last_learned') String? lastLearned,
    @JsonKey(name: 'next_lesson') String? nextLesson,
    @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
    @JsonKey(name: 'completed_lessons') @Default(0) int completedLessons,
    @Default('active') String status,
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

  /// Display name - prefer API field, fallback to legacy
  String get displayCourseName => courseTitle ?? courseName ?? 'Untitled';

  /// Progress value as double (from API progressPercentage or legacy progress)
  double get progressValue {
    final parsed = double.tryParse(progressPercentage);
    if (parsed != null && parsed > 0) return parsed;
    return progress.toDouble();
  }

  String get progressText => '$completedLessons/$totalLessons bai hoc';

  String get lastLearnedDisplay {
    // Prefer API field
    if (lastAccessedAt != null) {
      // TODO: Format date properly
      return lastAccessedAt!;
    }
    if (lastLearned == null) return 'Chua bat dau';
    return lastLearned!;
  }
}
