import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_stats_model.freezed.dart';
part 'teacher_stats_model.g.dart';

@freezed
abstract class TeacherStatsModel with _$TeacherStatsModel {
  const factory TeacherStatsModel({
    @JsonKey(name: 'monthly_revenue') @Default(0) double monthlyRevenue,
    @JsonKey(name: 'new_students') @Default(0) int newStudents,
    @JsonKey(name: 'completion_rate') @Default(0) double completionRate,
    @JsonKey(name: 'total_courses') @Default(0) int totalCourses,
    @JsonKey(name: 'active_courses') @Default(0) int activeCourses,
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'revenue_data') @Default([]) List<double> revenueData,
  }) = _TeacherStatsModel;

  factory TeacherStatsModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherStatsModelFromJson(json);
}
