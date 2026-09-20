import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_schedule_model.freezed.dart';
part 'child_schedule_model.g.dart';

@freezed
abstract class ChildScheduleModel with _$ChildScheduleModel {
  const factory ChildScheduleModel({
    required String id,
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'class_name') String? className,
    @JsonKey(name: 'session_number') @Default(0) int sessionNumber,
    @Default('') String topic,
    required DateTime date,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
  }) = _ChildScheduleModel;

  factory ChildScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ChildScheduleModelFromJson(json);
}
