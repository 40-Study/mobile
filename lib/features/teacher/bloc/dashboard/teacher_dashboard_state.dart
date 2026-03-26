part of 'teacher_dashboard_cubit.dart';

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
    required this.notifications,
    required this.schedules,
    required this.courses,
    this.teacherName = 'Giáo viên',
  });

  final TeacherStatsModel stats;
  final List<TeacherNotificationModel> notifications;
  final List<TeacherScheduleModel> schedules;
  final List<CourseModel> courses;
  final String teacherName;

  @override
  List<Object?> get props => [
        stats,
        notifications,
        schedules,
        courses,
        teacherName,
      ];
}

final class TeacherDashboardFailure extends TeacherDashboardState {
  const TeacherDashboardFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
