import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'assignment_state.dart';

class AssignmentCubit extends Cubit<AssignmentState> {
  AssignmentCubit({required StudentRepository repository})
      : _repository = repository,
        super(const AssignmentInitial());

  final StudentRepository _repository;
  int _currentPage = 1;
  static const _pageSize = 20;
  String? _classId;

  Future<void> loadAssignments({String? classId}) async {
    emit(const AssignmentLoading());
    _currentPage = 1;
    _classId = classId;

    try {
      final assignments = await _repository.getAssignments(
        classId: classId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(AssignmentLoaded(
        assignments: assignments,
        hasMore: assignments.length >= _pageSize,
      ));
    } catch (e) {
      debugPrint('loadAssignments error: $e');
      emit(AssignmentFailure(message: e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! AssignmentLoaded || !currentState.hasMore) return;

    _currentPage++;

    try {
      final newAssignments = await _repository.getAssignments(
        classId: _classId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(currentState.copyWith(
        assignments: [...currentState.assignments, ...newAssignments],
        hasMore: newAssignments.length >= _pageSize,
      ));
    } catch (e) {
      _currentPage--;
    }
  }

  Future<void> refresh() async {
    await loadAssignments(classId: _classId);
  }
}

class AssignmentDetailCubit extends Cubit<AssignmentDetailState> {
  AssignmentDetailCubit({
    required StudentRepository repository,
    required this.assignmentId,
  })  : _repository = repository,
        super(const AssignmentDetailInitial());

  final StudentRepository _repository;
  final String assignmentId;

  Future<void> load() async {
    emit(const AssignmentDetailLoading());

    try {
      final sandbox = await _repository.getAssignmentSandbox(assignmentId);
      emit(AssignmentDetailLoaded(sandbox: sandbox));
    } catch (e) {
      debugPrint('loadAssignmentSandbox error: $e');
      emit(AssignmentDetailFailure(message: e.toString()));
    }
  }

  Future<void> runCode({
    required String language,
    required String code,
  }) async {
    final currentState = state;
    if (currentState is! AssignmentDetailLoaded) return;

    emit(currentState.copyWith(isRunning: true));

    try {
      final result = await _repository.runCode(
        assignmentId: assignmentId,
        language: language,
        code: code,
      );
      emit(currentState.copyWith(
        isRunning: false,
        runResult: result,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isRunning: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> submitCode({
    required String language,
    required String code,
  }) async {
    final currentState = state;
    if (currentState is! AssignmentDetailLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));

    try {
      final submission = await _repository.submitAssignment(
        assignmentId: assignmentId,
        language: language,
        code: code,
      );
      emit(currentState.copyWith(
        isSubmitting: false,
        lastSubmission: submission,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
