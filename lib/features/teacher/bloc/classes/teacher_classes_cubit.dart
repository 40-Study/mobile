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
  List<ClassModel> _allClasses = [];

  Future<void> loadClasses() async {
    emit(TeacherClassesLoading(
      statusFilter: state.statusFilter,
      courseFilter: state.courseFilter,
      dayFilter: state.dayFilter,
      sortBy: state.sortBy,
      searchQuery: state.searchQuery,
    ));

    try {
      _allClasses = await _repository.getClasses();

      // Extract unique course names for filter dropdown
      final courses = _allClasses
          .where((c) => c.courseName != null)
          .map((c) => c.courseName!)
          .toSet()
          .toList();

      final filtered = _applyFilters(_allClasses);
      emit(TeacherClassesLoaded(
        classes: filtered,
        statusFilter: state.statusFilter,
        courseFilter: state.courseFilter,
        dayFilter: state.dayFilter,
        sortBy: state.sortBy,
        searchQuery: state.searchQuery,
        availableCourses: courses,
      ));
    } catch (e) {
      emit(TeacherClassesFailure(
        message: e.toString(),
        statusFilter: state.statusFilter,
        courseFilter: state.courseFilter,
        dayFilter: state.dayFilter,
        sortBy: state.sortBy,
        searchQuery: state.searchQuery,
      ));
    }
  }

  List<ClassModel> _applyFilters(List<ClassModel> classes) {
    var result = List<ClassModel>.from(classes);

    // Apply status filter
    if (state.statusFilter != ClassStatusFilter.all) {
      result = result.where((c) {
        return switch (state.statusFilter) {
          ClassStatusFilter.active => c.classStatus == ClassStatus.active,
          ClassStatusFilter.completed => c.classStatus == ClassStatus.completed,
          ClassStatusFilter.cancelled => c.classStatus == ClassStatus.cancelled,
          ClassStatusFilter.all => true,
        };
      }).toList();
    }

    // Apply course filter
    if (state.courseFilter != null && state.courseFilter!.isNotEmpty) {
      result = result.where((c) => c.courseName == state.courseFilter).toList();
    }

    // Apply day filter
    if (state.dayFilter != DayFilter.all) {
      result = result.where((c) {
        if (c.nextScheduleDate == null) return false;
        final date = DateTime.tryParse(c.nextScheduleDate!);
        if (date == null) return false;
        return date.weekday == state.dayFilter.weekday;
      }).toList();
    }

    // Apply search
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      result = result.where((c) {
        return c.displayName.toLowerCase().contains(q) ||
            (c.courseName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Apply sort
    switch (state.sortBy) {
      case ClassSortBy.newest:
        result.sort((a, b) {
          final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(2000);
          final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
      case ClassSortBy.oldest:
        result.sort((a, b) {
          final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(2000);
          final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(2000);
          return aDate.compareTo(bDate);
        });
      case ClassSortBy.mostStudents:
        result.sort((a, b) => b.studentCount.compareTo(a.studentCount));
      case ClassSortBy.alphabetical:
        result.sort((a, b) => a.displayName.compareTo(b.displayName));
      case ClassSortBy.startingSoon:
        result.sort((a, b) {
          final aDate =
              DateTime.tryParse(a.nextScheduleDate ?? '') ?? DateTime(2100);
          final bDate =
              DateTime.tryParse(b.nextScheduleDate ?? '') ?? DateTime(2100);
          return aDate.compareTo(bDate);
        });
    }

    return result;
  }

  void _emitFiltered() {
    if (state is TeacherClassesLoaded) {
      final currentState = state as TeacherClassesLoaded;
      final filtered = _applyFilters(_allClasses);
      emit(currentState.copyWith(classes: filtered));
    }
  }

  void changeStatusFilter(ClassStatusFilter filter) {
    if (state is TeacherClassesLoaded) {
      final currentState = state as TeacherClassesLoaded;
      emit(currentState.copyWith(statusFilter: filter));
      _emitFiltered();
    }
  }

  void changeCourseFilter(String? course) {
    if (state is TeacherClassesLoaded) {
      final currentState = state as TeacherClassesLoaded;
      emit(currentState.copyWith(courseFilter: course));
      _emitFiltered();
    }
  }

  void changeDayFilter(DayFilter day) {
    if (state is TeacherClassesLoaded) {
      final currentState = state as TeacherClassesLoaded;
      emit(currentState.copyWith(dayFilter: day));
      _emitFiltered();
    }
  }

  void changeSortBy(ClassSortBy sortBy) {
    if (state is TeacherClassesLoaded) {
      final currentState = state as TeacherClassesLoaded;
      emit(currentState.copyWith(sortBy: sortBy));
      _emitFiltered();
    }
  }

  void search(String query) {
    if (state is TeacherClassesLoaded) {
      final currentState = state as TeacherClassesLoaded;
      emit(currentState.copyWith(searchQuery: query));
      _emitFiltered();
    }
  }

  Future<void> deleteClass(String id) async {
    final currentState = state;
    if (currentState is! TeacherClassesLoaded) return;

    try {
      await _repository.deleteClass(id);
      _allClasses = _allClasses.where((c) => c.id != id).toList();
      _emitFiltered();
    } catch (e) {
      debugPrint('deleteClass error: $e');
    }
  }

  Future<void> refresh() async {
    await loadClasses();
  }
}
