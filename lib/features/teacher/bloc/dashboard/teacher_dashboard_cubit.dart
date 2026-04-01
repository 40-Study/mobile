import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';

part 'teacher_dashboard_state.dart';

class TeacherDashboardCubit extends Cubit<TeacherDashboardState> {
  TeacherDashboardCubit({required TeacherRepository repository})
      : _repository = repository,
        super(const TeacherDashboardInitial());

  final TeacherRepository _repository;

  Future<void> loadDashboard() async {
    emit(const TeacherDashboardLoading());

    try {
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getWallet(),
        _repository.getNotifications(),
        _repository.getUpcomingSchedule(),
        _repository.getCourses(pageSize: 10),
        _repository.getPendingAssignments(),
        _repository.getActivities(),
      ]);

      emit(TeacherDashboardLoaded(
        stats: results[0] as TeacherStatsModel,
        wallet: results[1] as TeacherWalletModel,
        notifications: results[2] as List<TeacherNotificationModel>,
        schedules: results[3] as List<TeacherScheduleModel>,
        courses: results[4] as List<CourseModel>,
        pendingAssignments: results[5] as List<PendingAssignmentModel>,
        activities: results[6] as List<TeacherActivityModel>,
        teacherName: 'Giảng viên', // TODO: Get from auth/profile
      ));
    } catch (e) {
      emit(TeacherDashboardFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
