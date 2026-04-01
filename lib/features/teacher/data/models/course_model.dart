import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

enum CourseStatus { published, draft, archived, active }

@freezed
abstract class CourseModel with _$CourseModel {
  const factory CourseModel({
    required String id,
    String? name,
    String? title,
    String? description,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'thumbnail') String? thumbnail,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'max_students') @Default(0) int maxStudents,
    @JsonKey(name: 'student_count') @Default(0) int studentCount,
    @JsonKey(name: 'teacher_count') @Default(0) int teacherCount,
    @Default(0.0) double rating,
    @JsonKey(name: 'review_count') @Default(0) int reviewCount,
    @Default('draft') String status,
    @JsonKey(name: 'category_name') String? categoryName,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @Default(0.0) double price,
    @JsonKey(name: 'original_price') double? originalPrice,
    @JsonKey(name: 'discount_percent') @Default(0) int discountPercent,
    @JsonKey(name: 'class_count') @Default(0) int classCount,
    @JsonKey(name: 'progress_percent') @Default(0) int progressPercent,
    @JsonKey(name: 'is_on_sale') @Default(false) bool isOnSale,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}

extension CourseModelX on CourseModel {
  /// Get display title (name or title).
  String get displayTitle => name ?? title ?? 'Untitled';

  /// Get thumbnail URL.
  String? get displayThumbnail => thumbnailUrl ?? thumbnail;

  CourseStatus get courseStatus {
    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
        return CourseStatus.published;
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
}
