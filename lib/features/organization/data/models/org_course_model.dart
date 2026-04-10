import 'package:freezed_annotation/freezed_annotation.dart';

part 'org_course_model.freezed.dart';
part 'org_course_model.g.dart';

/// Course model theo API DOCS - GET /courses
/// ORG_OWNER có thể tạo và quản lý khóa học
@freezed
abstract class OrgCourseModel with _$OrgCourseModel {
  const factory OrgCourseModel({
    required String id,
    @JsonKey(name: 'instructor_id') required String instructorId,
    @JsonKey(name: 'category_id') String? categoryId,
    required String title,
    required String slug,
    @JsonKey(name: 'short_description') String? shortDescription,
    String? description,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'preview_video_url') String? previewVideoUrl,
    @Default('beginner') String level, // beginner | intermediate | advanced | all_levels
    @Default('vi') String language,
    @Default('0') String price,
    @JsonKey(name: 'discount_price') String? discountPrice,
    @JsonKey(name: 'discount_expires_at') String? discountExpiresAt,
    @JsonKey(name: 'total_duration_minutes') @Default(0) int totalDurationMinutes,
    @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'average_rating') @Default('0') String averageRating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,
    @Default([]) List<String> requirements,
    @Default([]) List<String> objectives,
    @JsonKey(name: 'target_audience') @Default([]) List<String> targetAudience,
    @Default('draft') String status, // draft | pending | published | archived
    @JsonKey(name: 'published_at') String? publishedAt,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'is_free') @Default(false) bool isFree,
    OrgCourseInstructor? instructor,
    OrgCourseCategory? category,
    @Default([]) List<OrgCourseTag> tags,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _OrgCourseModel;

  factory OrgCourseModel.fromJson(Map<String, dynamic> json) =>
      _$OrgCourseModelFromJson(json);
}

@freezed
abstract class OrgCourseInstructor with _$OrgCourseInstructor {
  const factory OrgCourseInstructor({
    required String id,
    required String name,
    String? avatar,
    String? bio,
  }) = _OrgCourseInstructor;

  factory OrgCourseInstructor.fromJson(Map<String, dynamic> json) =>
      _$OrgCourseInstructorFromJson(json);
}

@freezed
abstract class OrgCourseCategory with _$OrgCourseCategory {
  const factory OrgCourseCategory({
    required String id,
    @JsonKey(name: 'parent_id') String? parentId,
    required String name,
    required String slug,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _OrgCourseCategory;

  factory OrgCourseCategory.fromJson(Map<String, dynamic> json) =>
      _$OrgCourseCategoryFromJson(json);
}

@freezed
abstract class OrgCourseTag with _$OrgCourseTag {
  const factory OrgCourseTag({
    required String id,
    required String name,
    required String slug,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _OrgCourseTag;

  factory OrgCourseTag.fromJson(Map<String, dynamic> json) =>
      _$OrgCourseTagFromJson(json);
}

/// Class model theo API DOCS - ORG_OWNER có thể tạo lớp học
@freezed
abstract class OrgClassModel with _$OrgClassModel {
  const factory OrgClassModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'teacher_id') required String teacherId,
    @JsonKey(name: 'teacher_name') String? teacherName,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'max_students') int? maxStudents,
    @Default('active') String status, // active | archived | completed
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    String? schedule, // e.g., "T2, T4, T6 - 19:00"
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _OrgClassModel;

  factory OrgClassModel.fromJson(Map<String, dynamic> json) =>
      _$OrgClassModelFromJson(json);
}

/// Livestream session cho ORG_OWNER host
@freezed
abstract class OrgLivestreamModel with _$OrgLivestreamModel {
  const factory OrgLivestreamModel({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'host_id') required String hostId,
    @JsonKey(name: 'host_name') String? hostName,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'class_name') String? className,
    @JsonKey(name: 'room_name') String? roomName,
    @Default('scheduled') String status, // scheduled | live | ended | cancelled
    @JsonKey(name: 'started_at') String? startedAt,
    @JsonKey(name: 'ended_at') String? endedAt,
    @JsonKey(name: 'scheduled_at') String? scheduledAt,
    @JsonKey(name: 'max_viewers') @Default(1000) int maxViewers,
    @JsonKey(name: 'active_participants') @Default(0) int activeParticipants,
    @JsonKey(name: 'is_recorded') @Default(true) bool isRecorded,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _OrgLivestreamModel;

  factory OrgLivestreamModel.fromJson(Map<String, dynamic> json) =>
      _$OrgLivestreamModelFromJson(json);
}
