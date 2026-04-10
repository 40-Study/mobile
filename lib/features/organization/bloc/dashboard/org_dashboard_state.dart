part of 'org_dashboard_cubit.dart';

@immutable
sealed class OrgDashboardState extends Equatable {
  const OrgDashboardState();

  @override
  List<Object?> get props => [];
}

final class OrgDashboardInitial extends OrgDashboardState {
  const OrgDashboardInitial();
}

final class OrgDashboardLoading extends OrgDashboardState {
  const OrgDashboardLoading();
}

final class OrgDashboardLoaded extends OrgDashboardState {
  const OrgDashboardLoaded({
    required this.stats,
    required this.activities,
    this.organizationName = 'Tổ chức của bạn',
    this.avatarUrl,
    this.topCourses = const [],
    this.topTeachers = const [],
    this.financeAlerts = const [],
  });

  final OrgStatsModel stats;
  final List<OrgActivityModel> activities;
  final String organizationName;
  final String? avatarUrl;
  // Cash flow analytics
  final List<CourseRevenueModel> topCourses;
  final List<TeacherRevenueModel> topTeachers;
  final List<FinanceAlertModel> financeAlerts;

  @override
  List<Object?> get props => [
        stats,
        activities,
        organizationName,
        avatarUrl,
        topCourses,
        topTeachers,
        financeAlerts,
      ];
}

final class OrgDashboardFailure extends OrgDashboardState {
  const OrgDashboardFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
