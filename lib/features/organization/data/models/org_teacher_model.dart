import 'package:freezed_annotation/freezed_annotation.dart';

part 'org_teacher_model.freezed.dart';
part 'org_teacher_model.g.dart';

@freezed
abstract class OrgTeacherModel with _$OrgTeacherModel {
  const factory OrgTeacherModel({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    @JsonKey(name: 'specialization') @Default([]) List<String> specialization,

    // === COURSE METRICS ===
    @JsonKey(name: 'total_courses') @Default(0) int totalCourses,
    @JsonKey(name: 'active_courses') @Default(0) int activeCourses,
    @JsonKey(name: 'draft_courses') @Default(0) int draftCourses,
    @JsonKey(name: 'avg_course_rating') @Default(0) double avgCourseRating,
    @JsonKey(name: 'total_reviews') @Default(0) int totalReviews,

    // === STUDENT METRICS ===
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'active_students') @Default(0) int activeStudents,
    @JsonKey(name: 'new_students_this_month') @Default(0) int newStudentsThisMonth,
    @JsonKey(name: 'student_retention_rate') @Default(0) double studentRetentionRate,
    @JsonKey(name: 'avg_completion_rate') @Default(0) double avgCompletionRate,

    // === REVENUE METRICS ===
    @JsonKey(name: 'monthly_revenue') @Default(0) double monthlyRevenue,
    @JsonKey(name: 'total_revenue') @Default(0) double totalRevenue,
    @JsonKey(name: 'pending_payout') @Default(0) double pendingPayout,
    @JsonKey(name: 'total_payout') @Default(0) double totalPayout,
    @JsonKey(name: 'revenue_change') @Default(0) double revenueChange,
    @JsonKey(name: 'avg_revenue_per_course') @Default(0) double avgRevenuePerCourse,
    @JsonKey(name: 'avg_revenue_per_student') @Default(0) double avgRevenuePerStudent,

    // === PERFORMANCE METRICS ===
    @JsonKey(name: 'rating') @Default(0) double rating,
    @JsonKey(name: 'response_rate') @Default(0) double responseRate,
    @JsonKey(name: 'avg_response_time') @Default(0) int avgResponseTimeMinutes,
    @JsonKey(name: 'engagement_score') @Default(0) double engagementScore,
    @JsonKey(name: 'content_quality_score') @Default(0) double contentQualityScore,

    // === ACTIVITY METRICS ===
    @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
    @JsonKey(name: 'total_content_hours') @Default(0) double totalContentHours,
    @JsonKey(name: 'lessons_this_month') @Default(0) int lessonsThisMonth,
    @JsonKey(name: 'last_content_update') String? lastContentUpdate,

    // === STATUS ===
    @JsonKey(name: 'status') @Default('active') String status,
    @JsonKey(name: 'verification_status') @Default('pending') String verificationStatus,
    @JsonKey(name: 'joined_at') String? joinedAt,
    @JsonKey(name: 'last_active_at') String? lastActiveAt,

    // === CHART DATA ===
    @JsonKey(name: 'revenue_trend') @Default([]) List<double> revenueTrend,
    @JsonKey(name: 'students_trend') @Default([]) List<int> studentsTrend,
    @JsonKey(name: 'chart_labels') @Default([]) List<String> chartLabels,
  }) = _OrgTeacherModel;

  factory OrgTeacherModel.fromJson(Map<String, dynamic> json) =>
      _$OrgTeacherModelFromJson(json);
}

/// Extension for calculated metrics
extension OrgTeacherModelX on OrgTeacherModel {
  /// Overall performance score (0-100)
  double get performanceScore {
    double score = 0;
    // Rating (max 25)
    score += (rating / 5) * 25;
    // Completion rate (max 25)
    score += (avgCompletionRate / 100) * 25;
    // Response rate (max 25)
    score += (responseRate / 100) * 25;
    // Engagement (max 25)
    score += (engagementScore / 100) * 25;
    return score.clamp(0, 100);
  }

  /// Teacher tier based on revenue and performance
  String get tier {
    if (totalRevenue >= 500000000 && performanceScore >= 80) return 'Diamond';
    if (totalRevenue >= 200000000 && performanceScore >= 70) return 'Platinum';
    if (totalRevenue >= 100000000 && performanceScore >= 60) return 'Gold';
    if (totalRevenue >= 50000000 && performanceScore >= 50) return 'Silver';
    return 'Bronze';
  }
}

@freezed
abstract class TeacherSummaryStats with _$TeacherSummaryStats {
  const factory TeacherSummaryStats({
    @JsonKey(name: 'total_teachers') @Default(0) int totalTeachers,
    @JsonKey(name: 'active_teachers') @Default(0) int activeTeachers,
    @JsonKey(name: 'inactive_teachers') @Default(0) int inactiveTeachers,
    @JsonKey(name: 'pending_verification') @Default(0) int pendingVerification,
    @JsonKey(name: 'total_revenue') @Default(0) double totalRevenue,
    @JsonKey(name: 'total_pending_payout') @Default(0) double totalPendingPayout,
    @JsonKey(name: 'avg_rating') @Default(0) double avgRating,
    @JsonKey(name: 'avg_courses_per_teacher') @Default(0) double avgCoursesPerTeacher,
    @JsonKey(name: 'top_performers') @Default([]) List<String> topPerformers,
  }) = _TeacherSummaryStats;

  factory TeacherSummaryStats.fromJson(Map<String, dynamic> json) =>
      _$TeacherSummaryStatsFromJson(json);
}
