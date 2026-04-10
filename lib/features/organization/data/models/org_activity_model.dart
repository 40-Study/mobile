import 'package:freezed_annotation/freezed_annotation.dart';

part 'org_activity_model.freezed.dart';
part 'org_activity_model.g.dart';

enum OrgActivityType {
  @JsonValue('new_teacher')
  newTeacher,
  @JsonValue('new_student')
  newStudent,
  @JsonValue('course_created')
  courseCreated,
  @JsonValue('course_purchase')
  coursePurchase,
  @JsonValue('payout')
  payout,
  @JsonValue('review')
  review,
}

@freezed
abstract class OrgActivityModel with _$OrgActivityModel {
  const factory OrgActivityModel({
    required String id,
    required String title,
    String? subtitle,
    required OrgActivityType type,
    @JsonKey(name: 'created_at') required String createdAt,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) = _OrgActivityModel;

  factory OrgActivityModel.fromJson(Map<String, dynamic> json) =>
      _$OrgActivityModelFromJson(json);
}
