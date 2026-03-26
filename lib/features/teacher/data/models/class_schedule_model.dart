import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_schedule_model.freezed.dart';
part 'class_schedule_model.g.dart';

@freezed
abstract class ClassScheduleModel with _$ClassScheduleModel {
  const factory ClassScheduleModel({
    required String id,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'day_of_week') @Default(1) int dayOfWeek,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    String? room,
    String? note,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ClassScheduleModel;

  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ClassScheduleModelFromJson(json);
}

extension ClassScheduleModelX on ClassScheduleModel {
  /// Get day of week name in Vietnamese.
  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Thu Hai';
      case 2:
        return 'Thu Ba';
      case 3:
        return 'Thu Tu';
      case 4:
        return 'Thu Nam';
      case 5:
        return 'Thu Sau';
      case 6:
        return 'Thu Bay';
      case 7:
        return 'Chu Nhat';
      default:
        return 'Khong xac dinh';
    }
  }

  /// Get formatted time range.
  String get timeRange {
    if (startTime == null && endTime == null) return 'Chua xac dinh';
    if (startTime != null && endTime != null) {
      return '$startTime - $endTime';
    }
    return startTime ?? endTime ?? '';
  }

  /// Get display text (day + time).
  String get displayText => '$dayName: $timeRange';
}
