import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_stats_model.freezed.dart';
part 'student_stats_model.g.dart';

@freezed
abstract class StudentStatsModel with _$StudentStatsModel {
  const factory StudentStatsModel({
    @JsonKey(name: 'total_classes') @Default(0) int totalClasses,
    @JsonKey(name: 'total_courses') @Default(0) int totalCourses,
    @JsonKey(name: 'today_livestreams') @Default(0) int todayLivestreams,
    @JsonKey(name: 'overall_progress') @Default(0) double overallProgress,
    @JsonKey(name: 'attendance_rate') @Default(0) double attendanceRate,
    @JsonKey(name: 'average_score') @Default(0) double averageScore,
  }) = _StudentStatsModel;

  factory StudentStatsModel.fromJson(Map<String, dynamic> json) =>
      _$StudentStatsModelFromJson(json);
}
