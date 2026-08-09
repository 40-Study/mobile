import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_stats_model.freezed.dart';
part 'student_stats_model.g.dart';

@freezed
abstract class StudentStatsModel with _$StudentStatsModel {
  const factory StudentStatsModel({
    @Default(0) int level,
    @JsonKey(name: 'current_xp') @Default(0) int currentXp,
    @JsonKey(name: 'next_level_xp') @Default(100) int nextLevelXp,
    @JsonKey(name: 'streak_days') @Default(0) int streakDays,
    @JsonKey(name: 'total_courses') @Default(0) int totalCourses,
    @JsonKey(name: 'completed_courses') @Default(0) int completedCourses,
    @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
    @JsonKey(name: 'completed_lessons') @Default(0) int completedLessons,
    @JsonKey(name: 'total_quiz_score') @Default(0) double totalQuizScore,
    @JsonKey(name: 'total_study_hours') @Default(0) double totalStudyHours,
    @JsonKey(name: 'weekly_study_hours') List<double>? weeklyStudyHours,
  }) = _StudentStatsModel;

  factory StudentStatsModel.fromJson(Map<String, dynamic> json) =>
      _$StudentStatsModelFromJson(json);
}
