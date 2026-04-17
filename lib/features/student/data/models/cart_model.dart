import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_model.freezed.dart';
part 'cart_model.g.dart';

@freezed
abstract class CartModel with _$CartModel {
  const factory CartModel({
    @Default([]) List<CartItemModel> items,
    @Default(0) double total,
    @JsonKey(name: 'total_item') @Default(0) int totalItem,
  }) = _CartModel;

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);
}

@freezed
abstract class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String id,
    @JsonKey(name: 'course_id') required String courseId,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'created_at') String? createdAt,
    CartCourseModel? course,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}

@freezed
abstract class CartCourseModel with _$CartCourseModel {
  const factory CartCourseModel({
    required String id,
    required String title,
    String? slug,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @Default(0) double price,
    @JsonKey(name: 'discount_price') double? discountPrice,
    String? level,
    @JsonKey(name: 'instructor_name') String? instructorName,
    @JsonKey(name: 'total_duration_mins') int? totalDurationMins,
    @JsonKey(name: 'total_lessons') int? totalLessons,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'total_students') int? totalStudents,
  }) = _CartCourseModel;

  factory CartCourseModel.fromJson(Map<String, dynamic> json) =>
      _$CartCourseModelFromJson(json);
}
