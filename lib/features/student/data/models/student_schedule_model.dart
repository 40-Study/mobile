import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_schedule_model.freezed.dart';
part 'student_schedule_model.g.dart';

enum ScheduleStatus { upcoming, live, completed }

@freezed
abstract class StudentScheduleModel with _$StudentScheduleModel {
  const factory StudentScheduleModel({
    required String id,
    String? title,
    @JsonKey(name: 'class_name') String? className,
    @JsonKey(name: 'teacher_name') String? teacherName,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    @JsonKey(name: 'meeting_url') String? meetingUrl,
    @Default('upcoming') String status,
    @JsonKey(name: 'is_livestream') @Default(false) bool isLivestream,
  }) = _StudentScheduleModel;

  factory StudentScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$StudentScheduleModelFromJson(json);
}

extension StudentScheduleModelX on StudentScheduleModel {
  ScheduleStatus get scheduleStatus {
    switch (status.toLowerCase()) {
      case 'live':
      case 'ongoing':
        return ScheduleStatus.live;
      case 'completed':
      case 'ended':
        return ScheduleStatus.completed;
      default:
        return ScheduleStatus.upcoming;
    }
  }

  bool get isLive => scheduleStatus == ScheduleStatus.live;
  bool get isUpcoming => scheduleStatus == ScheduleStatus.upcoming;

  String get timeDisplay {
    if (startTime == null) return '';
    // Parse time and format
    try {
      final dt = DateTime.parse(startTime!);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return startTime ?? '';
    }
  }
}
