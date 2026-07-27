import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class LearningBloc extends Bloc<LearningEvent, LearningState> {
  LearningBloc(this._repository) : super(const LearningInitial()) {
    on<LearningStarted>(_onStarted);
    on<LearningRefreshed>(_onRefreshed);
    on<LearningFilterChanged>(_onFilterChanged);
    on<LearningSearchChanged>(_onSearchChanged);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(
    LearningStarted event,
    Emitter<LearningState> emit,
  ) async {
    emit(const LearningInProgress());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    LearningRefreshed event,
    Emitter<LearningState> emit,
  ) async {
    final currentState = state;
    await _loadData(
      emit,
      preserveFilter: currentState is LearningSuccess ? currentState : null,
    );
  }

  Future<void> _loadData(
    Emitter<LearningState> emit, {
    LearningSuccess? preserveFilter,
  }) async {
    final result = await _repository.getActiveEnrollments();

    result.when(
      success: (enrollments) {
        emit(LearningSuccess(
          enrollments: enrollments,
          filter: preserveFilter?.filter ?? EnrollmentFilter.inProgress,
          searchQuery: preserveFilter?.searchQuery ?? '',
        ));
      },
      failure: (error) {
        emit(LearningFailure(error.message ?? 'Loi khong xac dinh'));
      },
    );
  }

  void _onFilterChanged(
    LearningFilterChanged event,
    Emitter<LearningState> emit,
  ) {
    final currentState = state;
    if (currentState is LearningSuccess) {
      emit(currentState.copyWith(filter: event.filter));
    }
  }

  void _onSearchChanged(
    LearningSearchChanged event,
    Emitter<LearningState> emit,
  ) {
    final currentState = state;
    if (currentState is LearningSuccess) {
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }
}
