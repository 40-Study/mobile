import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
        _repository.getNotifications(),
        _repository.getUpcomingSchedule(),
        _repository.getCourses(pageSize: 10),
      ]);

      emit(TeacherDashboardLoaded(
        stats: results[0] as TeacherStatsModel,
        notifications: results[1] as List<TeacherNotificationModel>,
        schedules: results[2] as List<TeacherScheduleModel>,
        courses: results[3] as List<CourseModel>,
        teacherName: 'Nguyễn Văn A', // TODO: Get from auth/profile
      ));
    } catch (e) {
      emit(TeacherDashboardFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
