import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'student_dashboard_state.dart';

class StudentDashboardCubit extends Cubit<StudentDashboardState> {
  StudentDashboardCubit({required StudentRepository repository})
      : _repository = repository,
        super(const StudentDashboardInitial());

  final StudentRepository _repository;

  Future<void> loadDashboard() async {
    emit(const StudentDashboardLoading());

    try {
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getTodaySchedule(),
        _repository.getEnrollments(pageSize: 5),
        _repository.getTrendingCourses(limit: 10),
        _repository.getCompetitions(pageSize: 5),
        _repository.getFeaturedDiscussions(limit: 5),
        _repository.getPendingAssignments(limit: 10),
        _repository.getWeekSchedules(),
      ]);

      emit(StudentDashboardLoaded(
        stats: results[0] as StudentStatsModel,
        todaySchedules: results[1] as List<StudentScheduleModel>,
        enrollments: results[2] as List<EnrollmentModel>,
        studentName: 'Nguyen Van Hoc Sinh', // TODO: Get from auth/profile
        trendingCourses: results[3] as List<CourseModel>,
        competitions: results[4] as List<CompetitionModel>,
        featuredPosts: results[5] as List<ForumPostModel>,
        pendingAssignments: results[6] as List<AssignmentModel>,
        weekSchedules: results[7] as List<StudentScheduleModel>,
      ));
    } catch (e) {
      emit(StudentDashboardFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
