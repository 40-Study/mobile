import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_model.freezed.dart';
part 'child_model.g.dart';

@freezed
class ChildModel with _$ChildModel {
  const factory ChildModel({
    required String id,
    required String fullName,
    String? avatarUrl,
    String? className,
    @Default(0) int enrolledCourses,
    @Default(0) double progressPercent,
  }) = _ChildModel;

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);
}
