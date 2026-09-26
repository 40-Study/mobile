import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/home/home_event.dart';
import 'package:study/features/student/bloc/home/home_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeClassCourseRequested>(_onClassCourseRequested);
    on<HomeClassCourseNavigationHandled>(_onNavigationHandled);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeInProgress());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    // Fetch all data in parallel
    final (continueLearning, schedule, assignments) = await (
      _repository.getContinueLearning(),
      _repository.getTodaySchedule(),
      _repository.getPendingAssignments(),
    ).wait;

    // Check any failure
    if (continueLearning.isFailure ||
        schedule.isFailure ||
        assignments.isFailure) {
      final message = continueLearning.errorOrNull?.message ??
          schedule.errorOrNull?.message ??
          assignments.errorOrNull?.message ??
          'Loi khong xac dinh';
      emit(HomeFailure(message));
      return;
    }

    emit(HomeSuccess(
      continueLearning: continueLearning.valueOrNull,
      scheduleItems: schedule.valueOrNull ?? [],
      assignments: assignments.valueOrNull ?? [],
    ));
  }

  Future<void> _onClassCourseRequested(
    HomeClassCourseRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeSuccess) return;

    // Emit loading
    emit(currentState.copyWith(
      classCourseNavigation: const ClassCourseNavigationLoading(),
    ));

    // Get course from class
    final classResult = await _repository.getCourseIdFromClass(event.classId);
    final courseId = classResult.valueOrNull;

    if (courseId == null) {
      emit(currentState.copyWith(
        classCourseNavigation: const ClassCourseNavigationError('course_not_found'),
      ));
      return;
    }

    // Get enrollments
    final enrollmentsResult = await _repository.getActiveEnrollments();
    final enrollments = enrollmentsResult.valueOrNull ?? [];
    final enrollment = enrollments.where((e) => e.courseId == courseId).firstOrNull;

    if (enrollment != null) {
      emit(currentState.copyWith(
        classCourseNavigation: ClassCourseNavigationSuccess(enrollment),
      ));
    } else {
      emit(currentState.copyWith(
        classCourseNavigation: const ClassCourseNavigationError('not_enrolled'),
      ));
    }
  }

  void _onNavigationHandled(
    HomeClassCourseNavigationHandled event,
    Emitter<HomeState> emit,
  ) {
    final currentState = state;
    if (currentState is HomeSuccess) {
      emit(currentState.copyWith(clearNavigation: true));
    }
  }
}
