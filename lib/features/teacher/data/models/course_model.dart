import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

enum CourseStatus { published, draft, archived, active, pendingReview }

/// Course model theo API DOCS - GET /courses
/// Response: CourseResponseDTO
@freezed
abstract class CourseModel with _$CourseModel {
  const factory CourseModel({
    required String id,
    @JsonKey(name: 'instructor_id') String? instructorId,
    @JsonKey(name: 'category_id') String? categoryId,
    String? title,
    String? slug,
    @JsonKey(name: 'short_description') String? shortDescription,
    String? description,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'preview_video_url') String? previewVideoUrl,
    @Default('beginner') String level, // beginner|intermediate|advanced|all_levels
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
    @Default('draft') String status, // draft|pending_review|published|archived
    @JsonKey(name: 'published_at') String? publishedAt,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'is_free') @Default(false) bool isFree,
    CourseInstructorDto? instructor,
    CourseCategoryDto? category,
    @Default([]) List<CourseTagDto> tags,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    // Legacy fields for backward compatibility
    String? name,
    @JsonKey(name: 'thumbnail') String? thumbnail,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'max_students') @Default(0) int maxStudents,
    @JsonKey(name: 'student_count') @Default(0) int studentCount,
    @JsonKey(name: 'teacher_count') @Default(0) int teacherCount,
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @JsonKey(name: 'category_name') String? categoryName,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'original_price') double? originalPrice,
    @JsonKey(name: 'discount_percent') @Default(0) int discountPercent,
    @JsonKey(name: 'class_count') @Default(0) int classCount,
    @JsonKey(name: 'progress_percent') @Default(0) int progressPercent,
    @JsonKey(name: 'is_on_sale') @Default(false) bool isOnSale,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}

@freezed
abstract class CourseInstructorDto with _$CourseInstructorDto {
  const factory CourseInstructorDto({
    required String id,
    required String name,
    String? avatar,
    String? bio,
  }) = _CourseInstructorDto;

  factory CourseInstructorDto.fromJson(Map<String, dynamic> json) =>
      _$CourseInstructorDtoFromJson(json);
}

@freezed
abstract class CourseCategoryDto with _$CourseCategoryDto {
  const factory CourseCategoryDto({
    required String id,
    @JsonKey(name: 'parent_id') String? parentId,
    required String name,
    required String slug,
    String? description,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'display_order') @Default(0) int displayOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _CourseCategoryDto;

  factory CourseCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CourseCategoryDtoFromJson(json);
}

@freezed
abstract class CourseTagDto with _$CourseTagDto {
  const factory CourseTagDto({
    required String id,
    required String name,
    required String slug,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _CourseTagDto;

  factory CourseTagDto.fromJson(Map<String, dynamic> json) =>
      _$CourseTagDtoFromJson(json);
}

extension CourseModelX on CourseModel {
  /// Get display title (title or name for legacy).
  String get displayTitle => title ?? name ?? 'Untitled';

  /// Get thumbnail URL.
  String? get displayThumbnail => thumbnailUrl ?? thumbnail;

  /// Get display category name.
  String? get displayCategory => category?.name ?? categoryName;

  /// Get instructor name.
  String? get instructorName => instructor?.name;

  /// Get price as double value (API returns string, legacy returns double)
  double get priceValue => double.tryParse(price) ?? 0.0;

  /// Get discount price as double value
  double get discountPriceValue =>
      double.tryParse(discountPrice ?? '') ?? 0.0;

  /// Get average rating as double value
  double get averageRatingValue => double.tryParse(averageRating) ?? rating;

  CourseStatus get courseStatus {
    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
        return CourseStatus.published;
      case 'pending_review':
        return CourseStatus.pendingReview;
      case 'archived':
        return CourseStatus.archived;
      default:
        return CourseStatus.draft;
    }
  }

  bool get isPublished =>
      courseStatus == CourseStatus.published ||
      courseStatus == CourseStatus.active;
  bool get isDraft => courseStatus == CourseStatus.draft;
  bool get isArchived => courseStatus == CourseStatus.archived;
  bool get isPendingReview => courseStatus == CourseStatus.pendingReview;
}
