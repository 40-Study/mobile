import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_stats_model.freezed.dart';
part 'student_stats_model.g.dart';

@freezed
abstract class StudentStatsModel with _$StudentStatsModel {
  const StudentStatsModel._();

  const factory StudentStatsModel({
    @Default(0) int level,
    @JsonKey(name: 'total_points') @Default(0) int currentXp,
    @JsonKey(name: 'level_progress') @Default(0) int nextLevelXp,
    @JsonKey(name: 'current_streak') @Default(0) int streakDays,
    @JsonKey(name: 'total_courses') @Default(0) int totalCourses,
    @JsonKey(name: 'courses_completed') @Default(0) int completedCourses,
    @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
    @JsonKey(name: 'lessons_completed') @Default(0) int completedLessons,
    @JsonKey(name: 'total_quiz_score') @Default(0) double totalQuizScore,
    @JsonKey(name: 'total_study_time_minutes') @Default(0) int totalStudyMinutes,
    @JsonKey(name: 'weekly_study_hours') List<double>? weeklyStudyHours,
  }) = _StudentStatsModel;

  // Convert minutes to hours for display
  double get totalStudyHours => totalStudyMinutes / 60.0;

  factory StudentStatsModel.fromJson(Map<String, dynamic> json) =>
      _$StudentStatsModelFromJson(json);
}
