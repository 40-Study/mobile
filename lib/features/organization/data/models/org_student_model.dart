import 'package:freezed_annotation/freezed_annotation.dart';

part 'org_student_model.freezed.dart';
part 'org_student_model.g.dart';

@freezed
abstract class OrgStudentModel with _$OrgStudentModel {
  const factory OrgStudentModel({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? avatarUrl,

    // === ENROLLMENT METRICS ===
    @JsonKey(name: 'enrolled_courses') @Default(0) int enrolledCourses,
    @JsonKey(name: 'completed_courses') @Default(0) int completedCourses,
    @JsonKey(name: 'in_progress_courses') @Default(0) int inProgressCourses,
    @JsonKey(name: 'dropped_courses') @Default(0) int droppedCourses,
    @JsonKey(name: 'avg_completion_rate') @Default(0) double avgCompletionRate,

    // === LEARNING METRICS ===
    @JsonKey(name: 'total_learning_hours') @Default(0) double totalLearningHours,
    @JsonKey(name: 'avg_daily_learning_minutes') @Default(0) int avgDailyLearningMinutes,
    @JsonKey(name: 'current_streak_days') @Default(0) int currentStreakDays,
    @JsonKey(name: 'longest_streak_days') @Default(0) int longestStreakDays,
    @JsonKey(name: 'lessons_completed') @Default(0) int lessonsCompleted,
    @JsonKey(name: 'quizzes_completed') @Default(0) int quizzesCompleted,
    @JsonKey(name: 'avg_quiz_score') @Default(0) double avgQuizScore,
    @JsonKey(name: 'certificates_earned') @Default(0) int certificatesEarned,

    // === FINANCIAL METRICS ===
    @JsonKey(name: 'total_spent') @Default(0) double totalSpent,
    @JsonKey(name: 'monthly_spending') @Default(0) double monthlySpending,
    @JsonKey(name: 'lifetime_value') @Default(0) double lifetimeValue,
    @JsonKey(name: 'avg_order_value') @Default(0) double avgOrderValue,
    @JsonKey(name: 'total_orders') @Default(0) int totalOrders,
    @JsonKey(name: 'refund_count') @Default(0) int refundCount,
    @JsonKey(name: 'has_subscription') @Default(false) bool hasSubscription,
    @JsonKey(name: 'subscription_plan') String? subscriptionPlan,

    // === ENGAGEMENT METRICS ===
    @JsonKey(name: 'engagement_score') @Default(0) double engagementScore,
    @JsonKey(name: 'total_comments') @Default(0) int totalComments,
    @JsonKey(name: 'total_questions') @Default(0) int totalQuestions,
    @JsonKey(name: 'reviews_given') @Default(0) int reviewsGiven,
    @JsonKey(name: 'avg_rating_given') @Default(0) double avgRatingGiven,
    @JsonKey(name: 'forum_posts') @Default(0) int forumPosts,
    @JsonKey(name: 'helpful_votes_received') @Default(0) int helpfulVotesReceived,

    // === PROGRESS ===
    @JsonKey(name: 'average_progress') @Default(0) double averageProgress,
    @JsonKey(name: 'weekly_progress_change') @Default(0) double weeklyProgressChange,

    // === RISK METRICS ===
    @JsonKey(name: 'churn_risk') @Default('low') String churnRisk,
    @JsonKey(name: 'days_since_last_activity') @Default(0) int daysSinceLastActivity,
    @JsonKey(name: 'is_at_risk') @Default(false) bool isAtRisk,

    // === STATUS ===
    @JsonKey(name: 'status') @Default('active') String status,
    @JsonKey(name: 'membership_tier') @Default('free') String membershipTier,
    @JsonKey(name: 'joined_at') String? joinedAt,
    @JsonKey(name: 'last_active_at') String? lastActiveAt,
    @JsonKey(name: 'last_purchase_at') String? lastPurchaseAt,

    // === CHART DATA ===
    @JsonKey(name: 'learning_hours_trend') @Default([]) List<double> learningHoursTrend,
    @JsonKey(name: 'progress_trend') @Default([]) List<double> progressTrend,
    @JsonKey(name: 'spending_trend') @Default([]) List<double> spendingTrend,
    @JsonKey(name: 'chart_labels') @Default([]) List<String> chartLabels,

    // === FAVORITE CATEGORIES ===
    @JsonKey(name: 'favorite_categories') @Default([]) List<String> favoriteCategories,
    @JsonKey(name: 'recommended_courses') @Default([]) List<String> recommendedCourses,
  }) = _OrgStudentModel;

  factory OrgStudentModel.fromJson(Map<String, dynamic> json) =>
      _$OrgStudentModelFromJson(json);
}

/// Extension for calculated metrics
extension OrgStudentModelX on OrgStudentModel {
  /// Student health score (0-100)
  double get healthScore {
    double score = 0;
    // Engagement (max 30)
    score += (engagementScore / 100) * 30;
    // Progress (max 30)
    score += (averageProgress / 100) * 30;
    // Completion (max 20)
    if (enrolledCourses > 0) {
      score += (completedCourses / enrolledCourses) * 20;
    }
    // Activity recency (max 20)
    if (daysSinceLastActivity <= 1) score += 20;
    else if (daysSinceLastActivity <= 7) score += 15;
    else if (daysSinceLastActivity <= 14) score += 10;
    else if (daysSinceLastActivity <= 30) score += 5;
    return score.clamp(0, 100);
  }

  /// Student segment
  String get segment {
    if (totalSpent >= 10000000 && engagementScore >= 80) return 'Champion';
    if (totalSpent >= 5000000 && engagementScore >= 60) return 'Loyal';
    if (engagementScore >= 70) return 'Engaged';
    if (daysSinceLastActivity > 30) return 'At Risk';
    if (totalSpent == 0) return 'New';
    return 'Active';
  }
}

@freezed
abstract class StudentSummaryStats with _$StudentSummaryStats {
  const factory StudentSummaryStats({
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'active_students') @Default(0) int activeStudents,
    @JsonKey(name: 'new_students_this_month') @Default(0) int newStudentsThisMonth,
    @JsonKey(name: 'churned_students') @Default(0) int churnedStudents,
    @JsonKey(name: 'at_risk_students') @Default(0) int atRiskStudents,
    @JsonKey(name: 'total_revenue') @Default(0) double totalRevenue,
    @JsonKey(name: 'avg_ltv') @Default(0) double avgLtv,
    @JsonKey(name: 'avg_engagement') @Default(0) double avgEngagement,
    @JsonKey(name: 'avg_completion_rate') @Default(0) double avgCompletionRate,
    @JsonKey(name: 'subscribers_count') @Default(0) int subscribersCount,

    // === SEGMENT BREAKDOWN ===
    @JsonKey(name: 'champions_count') @Default(0) int championsCount,
    @JsonKey(name: 'loyal_count') @Default(0) int loyalCount,
    @JsonKey(name: 'engaged_count') @Default(0) int engagedCount,
    @JsonKey(name: 'at_risk_count') @Default(0) int atRiskCount,
    @JsonKey(name: 'new_count') @Default(0) int newCount,
  }) = _StudentSummaryStats;

  factory StudentSummaryStats.fromJson(Map<String, dynamic> json) =>
      _$StudentSummaryStatsFromJson(json);
}
