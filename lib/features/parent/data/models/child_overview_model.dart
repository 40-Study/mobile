import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_overview_model.freezed.dart';
part 'child_overview_model.g.dart';

@freezed
class ChildOverviewModel with _$ChildOverviewModel {
  const factory ChildOverviewModel({
    required String childId,
    @Default(0) double progressPercent,
    @Default(0) double avgQuizScore,
    @Default(0) double studyHoursWeek,
    @Default(0) double attendanceRate,
    @Default(0) int totalCourses,
  }) = _ChildOverviewModel;

  factory ChildOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$ChildOverviewModelFromJson(json);
}
