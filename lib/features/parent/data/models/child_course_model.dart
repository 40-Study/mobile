import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_course_model.freezed.dart';
part 'child_course_model.g.dart';

@freezed
abstract class ChildCourseModel with _$ChildCourseModel {
  const factory ChildCourseModel({
    required String id,
    @JsonKey(name: 'course_id') required String courseId,
    @JsonKey(name: 'course_name') required String courseName,
    @JsonKey(name: 'course_thumbnail') String? courseThumbnail,
    @JsonKey(name: 'instructor_name') String? instructorName,
    @JsonKey(name: 'progress_percent') @Default(0) double progressPercent,
    @JsonKey(name: 'enrolled_at') DateTime? enrolledAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _ChildCourseModel;

  factory ChildCourseModel.fromJson(Map<String, dynamic> json) =>
      _$ChildCourseModelFromJson(json);
}
