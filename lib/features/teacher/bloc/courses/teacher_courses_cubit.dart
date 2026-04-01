import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';

part 'teacher_courses_state.dart';

class TeacherCoursesCubit extends Cubit<TeacherCoursesState> {
  TeacherCoursesCubit({required TeacherRepository repository})
      : _repository = repository,
        super(const TeacherCoursesInitial());

  final TeacherRepository _repository;

  List<CourseModel> _allCourses = [];

  Future<void> loadCourses() async {
    emit(TeacherCoursesLoading(
      selectedFilter: state.selectedFilter,
      sortBy: state.sortBy,
      searchQuery: state.searchQuery,
    ));

    try {
      _allCourses = await _repository.getCourses();
      _emitFilteredCourses();
    } catch (e) {
      emit(TeacherCoursesFailure(
        message: e.toString(),
        selectedFilter: state.selectedFilter,
        sortBy: state.sortBy,
        searchQuery: state.searchQuery,
      ));
    }
  }

  void changeFilter(CourseFilter filter) {
    if (state.selectedFilter == filter) return;
    _emitFilteredCourses(filter: filter);
  }

  void changeSortBy(CourseSortBy sortBy) {
    if (state.sortBy == sortBy) return;
    _emitFilteredCourses(sortBy: sortBy);
  }

  void search(String query) {
    _emitFilteredCourses(searchQuery: query);
  }

  void _emitFilteredCourses({
    CourseFilter? filter,
    CourseSortBy? sortBy,
    String? searchQuery,
  }) {
    final currentFilter = filter ?? state.selectedFilter;
    final currentSortBy = sortBy ?? state.sortBy;
    final currentSearch = searchQuery ?? state.searchQuery;

    var filteredCourses = List<CourseModel>.from(_allCourses);

    // Apply filter
    filteredCourses = switch (currentFilter) {
      CourseFilter.all => filteredCourses,
      CourseFilter.published =>
        filteredCourses.where((c) => c.status == 'published').toList(),
      CourseFilter.onSale => filteredCourses
          .where((c) => c.isPublished && c.studentCount > 0)
          .toList(),
      CourseFilter.draft =>
        filteredCourses.where((c) => c.status == 'draft').toList(),
      CourseFilter.archived =>
        filteredCourses.where((c) => c.status == 'archived').toList(),
    };

    // Apply search
    if (currentSearch.isNotEmpty) {
      final query = currentSearch.toLowerCase();
      filteredCourses = filteredCourses
          .where((c) => c.displayTitle.toLowerCase().contains(query))
          .toList();
    }

    // Apply sort
    filteredCourses = _sortCourses(filteredCourses, currentSortBy);

    emit(TeacherCoursesLoaded(
      courses: filteredCourses,
      selectedFilter: currentFilter,
      sortBy: currentSortBy,
      searchQuery: currentSearch,
    ));
  }

  List<CourseModel> _sortCourses(List<CourseModel> courses, CourseSortBy sortBy) {
    final sorted = List<CourseModel>.from(courses);
    switch (sortBy) {
      case CourseSortBy.newest:
        sorted.sort((a, b) => b.id.compareTo(a.id));
      case CourseSortBy.oldest:
        sorted.sort((a, b) => a.id.compareTo(b.id));
      case CourseSortBy.mostClasses:
        sorted.sort((a, b) => b.classCount.compareTo(a.classCount));
      case CourseSortBy.mostStudents:
        sorted.sort((a, b) => b.studentCount.compareTo(a.studentCount));
      case CourseSortBy.highestRevenue:
        sorted.sort((a, b) {
          final revenueA = a.studentCount * a.price;
          final revenueB = b.studentCount * b.price;
          return revenueB.compareTo(revenueA);
        });
      case CourseSortBy.highestRating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case CourseSortBy.bestSelling:
        sorted.sort((a, b) => b.studentCount.compareTo(a.studentCount));
    }
    return sorted;
  }

  Future<void> deleteCourse(String id) async {
    final currentState = state;
    if (currentState is! TeacherCoursesLoaded) return;

    try {
      await _repository.deleteCourse(id);
      _allCourses.removeWhere((c) => c.id == id);
      _emitFilteredCourses();
    } catch (e) {
      debugPrint('Delete course error: $e');
    }
  }

  Future<void> refresh() async {
    await loadCourses();
  }
}
