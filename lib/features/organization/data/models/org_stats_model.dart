import 'package:freezed_annotation/freezed_annotation.dart';

part 'org_stats_model.freezed.dart';
part 'org_stats_model.g.dart';

@freezed
abstract class OrgStatsModel with _$OrgStatsModel {
  const factory OrgStatsModel({
    @JsonKey(name: 'total_teachers') @Default(0) int totalTeachers,
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'total_courses') @Default(0) int totalCourses,
    @JsonKey(name: 'active_courses') @Default(0) int activeCourses,
    @JsonKey(name: 'monthly_revenue') @Default(0) double monthlyRevenue,
    @JsonKey(name: 'revenue_change_percent') @Default(0) double revenueChangePercent,
    @JsonKey(name: 'new_students_this_month') @Default(0) int newStudentsThisMonth,
    @JsonKey(name: 'new_teachers_this_month') @Default(0) int newTeachersThisMonth,
    // Cash flow analytics
    @JsonKey(name: 'total_income') @Default(0) double totalIncome,
    @JsonKey(name: 'total_expense') @Default(0) double totalExpense,
    @JsonKey(name: 'net_profit') @Default(0) double netProfit,
    @JsonKey(name: 'profit_margin') @Default(0) double profitMargin,
    @JsonKey(name: 'pending_payments') @Default(0) double pendingPayments,
  }) = _OrgStatsModel;

  factory OrgStatsModel.fromJson(Map<String, dynamic> json) =>
      _$OrgStatsModelFromJson(json);
}

/// Doanh thu theo khóa học
@freezed
abstract class CourseRevenueModel with _$CourseRevenueModel {
  const factory CourseRevenueModel({
    required String courseId,
    required String courseName,
    @JsonKey(name: 'teacher_name') String? teacherName,
    @JsonKey(name: 'total_revenue') @Default(0) double totalRevenue,
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'revenue_change') @Default(0) double revenueChange,
    @JsonKey(name: 'is_trending') @Default(false) bool isTrending,
  }) = _CourseRevenueModel;

  factory CourseRevenueModel.fromJson(Map<String, dynamic> json) =>
      _$CourseRevenueModelFromJson(json);
}

/// Doanh thu theo giáo viên
@freezed
abstract class TeacherRevenueModel with _$TeacherRevenueModel {
  const factory TeacherRevenueModel({
    required String teacherId,
    required String teacherName,
    String? avatarUrl,
    @JsonKey(name: 'total_revenue') @Default(0) double totalRevenue,
    @JsonKey(name: 'total_courses') @Default(0) int totalCourses,
    @JsonKey(name: 'total_students') @Default(0) int totalStudents,
    @JsonKey(name: 'commission_rate') @Default(0.7) double commissionRate,
    @JsonKey(name: 'pending_payout') @Default(0) double pendingPayout,
    @JsonKey(name: 'revenue_change') @Default(0) double revenueChange,
    @JsonKey(name: 'is_top_performer') @Default(false) bool isTopPerformer,
  }) = _TeacherRevenueModel;

  factory TeacherRevenueModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherRevenueModelFromJson(json);
}

/// Cảnh báo tài chính
@freezed
abstract class FinanceAlertModel with _$FinanceAlertModel {
  const factory FinanceAlertModel({
    required String id,
    required String title,
    required String message,
    required FinanceAlertType type,
    required FinanceAlertSeverity severity,
    @JsonKey(name: 'related_id') String? relatedId,
    @JsonKey(name: 'related_name') String? relatedName,
    double? amount,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _FinanceAlertModel;

  factory FinanceAlertModel.fromJson(Map<String, dynamic> json) =>
      _$FinanceAlertModelFromJson(json);
}

enum FinanceAlertType {
  @JsonValue('low_revenue')
  lowRevenue,
  @JsonValue('high_expense')
  highExpense,
  @JsonValue('pending_payout')
  pendingPayout,
  @JsonValue('refund_spike')
  refundSpike,
  @JsonValue('course_underperform')
  courseUnderperform,
}

enum FinanceAlertSeverity {
  @JsonValue('info')
  info,
  @JsonValue('warning')
  warning,
  @JsonValue('critical')
  critical,
}
