import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';

part 'teacher_classes_state.dart';

class TeacherClassesCubit extends Cubit<TeacherClassesState> {
  TeacherClassesCubit({required TeacherRepository repository})
      : _repository = repository,
        super(const TeacherClassesInitial());

  final TeacherRepository _repository;

  Future<void> loadClasses({String? status, String? searchQuery}) async {
    final filter = status ?? state.selectedFilter;
    final query = searchQuery ?? state.searchQuery;

    emit(TeacherClassesLoading(
      selectedFilter: filter,
      searchQuery: query,
    ));

    try {
      final classes = await _repository.getClasses(
        status: filter == 'all' ? null : filter,
        searchQuery: query.isEmpty ? null : query,
      );
      emit(TeacherClassesLoaded(
        classes: classes,
        selectedFilter: filter,
        searchQuery: query,
      ));
    } catch (e) {
      emit(TeacherClassesFailure(
        message: e.toString(),
        selectedFilter: filter,
        searchQuery: query,
      ));
    }
  }

  Future<void> changeFilter(String filter) async {
    await loadClasses(status: filter);
  }

  Future<void> search(String query) async {
    await loadClasses(searchQuery: query);
  }

  Future<void> deleteClass(String id) async {
    final currentState = state;
    if (currentState is! TeacherClassesLoaded) return;

    try {
      await _repository.deleteClass(id);
      final updatedClasses =
          currentState.classes.where((c) => c.id != id).toList();
      emit(currentState.copyWith(classes: updatedClasses));
    } catch (e) {
      debugPrint('deleteClass error: $e');
    }
  }

  Future<void> refresh() async {
    await loadClasses();
  }
}
