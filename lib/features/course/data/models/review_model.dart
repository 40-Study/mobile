import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
abstract class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'user_avatar') String? userAvatar,
    @JsonKey(name: 'course_id') String? courseId,
    required int rating,
    String? comment,
    @JsonKey(name: 'helpful_count') @Default(0) int helpfulCount,
    @JsonKey(name: 'not_helpful_count') @Default(0) int notHelpfulCount,
    @JsonKey(name: 'user_reaction') String? userReaction,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
}
