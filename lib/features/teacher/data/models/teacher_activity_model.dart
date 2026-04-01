import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_activity_model.freezed.dart';
part 'teacher_activity_model.g.dart';

enum ActivityType {
  @JsonValue('withdrawal')
  withdrawal,
  @JsonValue('new_student')
  newStudent,
  @JsonValue('course_purchase')
  coursePurchase,
  @JsonValue('review')
  review,
  @JsonValue('livestream')
  livestream,
}

@freezed
abstract class TeacherActivityModel with _$TeacherActivityModel {
  const factory TeacherActivityModel({
    required String id,
    required String title,
    String? subtitle,
    required ActivityType type,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
  }) = _TeacherActivityModel;

  factory TeacherActivityModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherActivityModelFromJson(json);
}
