import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_item_model.freezed.dart';
part 'schedule_item_model.g.dart';

@freezed
abstract class ScheduleItemModel with _$ScheduleItemModel {
  const factory ScheduleItemModel({
    required String id,
    required String title,
    required String type,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'lesson_id') String? lessonId,
    @JsonKey(name: 'instructor_name') String? instructorName,
    String? location,
    @JsonKey(name: 'livestream_id') String? livestreamId,
  }) = _ScheduleItemModel;

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleItemModelFromJson(json);
}
