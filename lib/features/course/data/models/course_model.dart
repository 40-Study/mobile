import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

@freezed
abstract class CourseModel with _$CourseModel {
  const factory CourseModel({
    required String id,
    String? slug,
    required String title,
    @JsonKey(name: 'short_description') String? shortDescription,
    String? description,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'preview_video_url') String? previewVideoUrl,
    @JsonKey(name: 'instructor_id') String? instructorId,
    @JsonKey(name: 'instructor_name') String? instructorName,
    @JsonKey(name: 'instructor_avatar') String? instructorAvatar,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'category_name') String? categoryName,
    @Default(0) double price,
    @JsonKey(name: 'discount_price') double? discountPrice,
    @JsonKey(name: 'discount_expires_at') DateTime? discountExpiresAt,
    String? level,
    String? language,
    @JsonKey(name: 'is_free') @Default(false) bool isFree,
    @JsonKey(name: 'is_published') @Default(false) bool isPublished,
    String? status,
    @JsonKey(name: 'average_rating') @Default(0) double averageRating,
    @JsonKey(name: 'total_ratings') @Default(0) int totalRatings,
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
    @JsonKey(name: 'total_sections') @Default(0) int totalSections,
    @JsonKey(name: 'total_duration_mins') @Default(0) int totalDurationMins,
    List<String>? requirements,
    List<String>? objectives,
    @JsonKey(name: 'target_audience') List<String>? targetAudience,
    List<TagModel>? tags,
    List<SectionModel>? sections,
    @JsonKey(name: 'is_enrolled') @Default(false) bool isEnrolled,
    @JsonKey(name: 'enrollment_progress') double? enrollmentProgress,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}

@freezed
abstract class SectionModel with _$SectionModel {
  const factory SectionModel({
    required String id,
    @JsonKey(name: 'course_id') String? courseId,
    required String title,
    String? description,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
    @JsonKey(name: 'total_duration_mins') @Default(0) int totalDurationMins,
    List<LessonModel>? lessons,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SectionModel;

  factory SectionModel.fromJson(Map<String, dynamic> json) =>
      _$SectionModelFromJson(json);
}

@freezed
abstract class LessonModel with _$LessonModel {
  const factory LessonModel({
    required String id,
    @JsonKey(name: 'section_id') String? sectionId,
    required String title,
    String? description,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'duration_minutes') @Default(0) int durationMinutes,
    @JsonKey(name: 'is_preview') @Default(false) bool isPreview,
    @JsonKey(name: 'is_mandatory') @Default(true) bool isMandatory,
    List<LessonContentModel>? contents,
    LessonProgressModel? progress,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _LessonModel;

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}

@freezed
abstract class LessonContentModel with _$LessonContentModel {
  const factory LessonContentModel({
    required String id,
    @JsonKey(name: 'lesson_id') String? lessonId,
    required String type,
    required String title,
    @JsonKey(name: 'video_url') String? videoUrl,
    @Default(0) int duration,
    @JsonKey(name: 'exercise_id') String? exerciseId,
    @JsonKey(name: 'is_mandatory') @Default(true) bool isMandatory,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _LessonContentModel;

  factory LessonContentModel.fromJson(Map<String, dynamic> json) =>
      _$LessonContentModelFromJson(json);
}

@freezed
abstract class LessonProgressModel with _$LessonProgressModel {
  const factory LessonProgressModel({
    String? status,
    @JsonKey(name: 'progress_percentage') @Default(0) double progressPercentage,
    @JsonKey(name: 'video_watched_seconds') @Default(0) int videoWatchedSeconds,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _LessonProgressModel;

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressModelFromJson(json);
}

@freezed
abstract class TagModel with _$TagModel {
  const factory TagModel({
    required String id,
    required String name,
    String? slug,
    String? description,
  }) = _TagModel;

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);
}
