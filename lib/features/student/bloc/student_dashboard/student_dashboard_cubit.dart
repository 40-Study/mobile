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
      ]);

      emit(StudentDashboardLoaded(
        stats: results[0] as StudentStatsModel,
        todaySchedules: results[1] as List<StudentScheduleModel>,
        enrollments: results[2] as List<EnrollmentModel>,
        studentName: 'Nguyen Van Hoc Sinh', // TODO: Get from auth/profile
      ));
    } catch (e) {
      emit(StudentDashboardFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
