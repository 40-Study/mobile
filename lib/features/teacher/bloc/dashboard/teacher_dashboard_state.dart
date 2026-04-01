part of 'teacher_dashboard_cubit.dart';

@immutable
sealed class TeacherDashboardState extends Equatable {
  const TeacherDashboardState();

  @override
  List<Object?> get props => [];
}

final class TeacherDashboardInitial extends TeacherDashboardState {
  const TeacherDashboardInitial();
}

final class TeacherDashboardLoading extends TeacherDashboardState {
  const TeacherDashboardLoading();
}

final class TeacherDashboardLoaded extends TeacherDashboardState {
  const TeacherDashboardLoaded({
    required this.stats,
    required this.wallet,
    required this.notifications,
    required this.schedules,
    required this.courses,
    required this.pendingAssignments,
    required this.activities,
    this.teacherName = 'Giảng viên',
    this.avatarUrl,
  });

  final TeacherStatsModel stats;
  final TeacherWalletModel wallet;
  final List<TeacherNotificationModel> notifications;
  final List<TeacherScheduleModel> schedules;
  final List<CourseModel> courses;
  final List<PendingAssignmentModel> pendingAssignments;
  final List<TeacherActivityModel> activities;
  final String teacherName;
  final String? avatarUrl;

  @override
  List<Object?> get props => [
        stats,
        wallet,
        notifications,
        schedules,
        courses,
        pendingAssignments,
        activities,
        teacherName,
        avatarUrl,
      ];
}

final class TeacherDashboardFailure extends TeacherDashboardState {
  const TeacherDashboardFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
