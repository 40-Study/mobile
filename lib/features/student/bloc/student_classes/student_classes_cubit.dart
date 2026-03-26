import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'student_classes_state.dart';

class StudentClassesCubit extends Cubit<StudentClassesState> {
  StudentClassesCubit({required StudentRepository repository})
      : _repository = repository,
        super(const StudentClassesInitial());

  final StudentRepository _repository;
  int _currentPage = 1;
  static const _pageSize = 20;

  Future<void> loadClasses({String? filter}) async {
    emit(const StudentClassesLoading());
    _currentPage = 1;

    try {
      final status = filter == 'all' ? null : filter;
      final classes = await _repository.getClasses(
        status: status,
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(StudentClassesLoaded(
        classes: classes,
        selectedFilter: filter ?? 'all',
        hasMore: classes.length >= _pageSize,
      ));
    } catch (e) {
      emit(StudentClassesFailure(message: e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! StudentClassesLoaded || !currentState.hasMore) return;

    _currentPage++;

    try {
      final status =
          currentState.selectedFilter == 'all' ? null : currentState.selectedFilter;
      final newClasses = await _repository.getClasses(
        status: status,
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(currentState.copyWith(
        classes: [...currentState.classes, ...newClasses],
        hasMore: newClasses.length >= _pageSize,
      ));
    } catch (e) {
      _currentPage--;
      // Keep current state on load more failure
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    final filter = currentState is StudentClassesLoaded
        ? currentState.selectedFilter
        : 'all';
    await loadClasses(filter: filter);
  }

  Future<void> changeFilter(String filter) async {
    await loadClasses(filter: filter);
  }
}
