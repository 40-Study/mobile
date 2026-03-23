import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_schedule_model.freezed.dart';
part 'teacher_schedule_model.g.dart';

@freezed
abstract class TeacherScheduleModel with _$TeacherScheduleModel {
  const factory TeacherScheduleModel({
    required String id,
    required String title,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') String? endTime,
    @JsonKey(name: 'meeting_type') @Default('online') String meetingType,
    @JsonKey(name: 'student_count') @Default(0) int studentCount,
    @JsonKey(name: 'course_name') String? courseName,
  }) = _TeacherScheduleModel;

  factory TeacherScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherScheduleModelFromJson(json);
}
