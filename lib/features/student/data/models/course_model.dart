import 'package:freezed_annotation/freezed_annotation.dart';

part 'course_model.freezed.dart';
part 'course_model.g.dart';

@freezed
abstract class CourseModel with _$CourseModel {
  const factory CourseModel({
    required String id,
    required String title,
    String? description,
    String? thumbnail,
    @JsonKey(name: 'instructor_name') String? instructorName,
    @JsonKey(name: 'instructor_avatar') String? instructorAvatar,
    String? category,
    String? level,
    @Default(0.0) double price,
    @JsonKey(name: 'original_price') double? originalPrice,
    @Default(0.0) double rating,
    @JsonKey(name: 'rating_count') @Default(0) int ratingCount,
    @JsonKey(name: 'student_count') @Default(0) int studentCount,
    @JsonKey(name: 'lesson_count') @Default(0) int lessonCount,
    @JsonKey(name: 'total_duration') int? totalDuration,
    @JsonKey(name: 'is_trending') @Default(false) bool isTrending,
    @JsonKey(name: 'is_bestseller') @Default(false) bool isBestseller,
    @JsonKey(name: 'is_new') @Default(false) bool isNew,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _CourseModel;

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
}

extension CourseModelX on CourseModel {
  String get durationDisplay {
    if (totalDuration == null) return '';
    final hours = totalDuration! ~/ 60;
    final minutes = totalDuration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get studentCountDisplay {
    if (studentCount >= 1000) {
      return '${(studentCount / 1000).toStringAsFixed(1)}K';
    }
    return '$studentCount';
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return ((1 - price / originalPrice!) * 100).toInt();
  }
}
