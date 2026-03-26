import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_enrollment_model.freezed.dart';
part 'child_enrollment_model.g.dart';

@freezed
abstract class ChildEnrollmentModel with _$ChildEnrollmentModel {
  const factory ChildEnrollmentModel({
    required String id,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'course_description') String? courseDescription,
    @JsonKey(name: 'progress_percentage') @Default(0.0) double progress,
    @JsonKey(name: 'enrolled_at') String? enrolledAt,
    @JsonKey(name: 'last_accessed_at') String? lastAccessedAt,
    @Default('active') String status,
  }) = _ChildEnrollmentModel;

  factory ChildEnrollmentModel.fromJson(Map<String, dynamic> json) =>
      _$ChildEnrollmentModelFromJson(json);
}

extension ChildEnrollmentModelX on ChildEnrollmentModel {
  String get progressDisplay => '${progress.toStringAsFixed(0)}%';
  bool get isCompleted => progress >= 100;
}
