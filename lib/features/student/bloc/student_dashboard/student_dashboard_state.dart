part of 'student_dashboard_cubit.dart';

@immutable
sealed class StudentDashboardState extends Equatable {
  const StudentDashboardState();

  @override
  List<Object?> get props => [];
}

final class StudentDashboardInitial extends StudentDashboardState {
  const StudentDashboardInitial();
}

final class StudentDashboardLoading extends StudentDashboardState {
  const StudentDashboardLoading();
}

final class StudentDashboardLoaded extends StudentDashboardState {
  const StudentDashboardLoaded({
    required this.stats,
    required this.todaySchedules,
    required this.enrollments,
    this.studentName = 'Hoc sinh',
  });

  final StudentStatsModel stats;
  final List<StudentScheduleModel> todaySchedules;
  final List<EnrollmentModel> enrollments;
  final String studentName;

  @override
  List<Object?> get props => [stats, todaySchedules, enrollments, studentName];
}

final class StudentDashboardFailure extends StudentDashboardState {
  const StudentDashboardFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
