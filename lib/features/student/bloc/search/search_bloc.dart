import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/bloc/search/search_event.dart';
import 'package:study/features/student/bloc/search/search_state.dart';
import 'package:study/features/student/data/models/recommended_course_item.dart';
import 'package:study/features/student/domain/search_recommendation_engine.dart';
import 'package:study/features/student/repository/student_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    this._repository, {
    this.recEngine = const SearchRecommendationEngine(),
  }) : super(const SearchInitial(
          recentSearches: ['Flutter', 'Bloc', 'UI Design'],
          isLoadingRecommendations: true,
        )) {
    on<SearchInitRequested>(_onInitRequested);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFilterChanged>(_onFilterChanged);
    on<SearchCleared>(_onCleared);
    on<SearchRecentRemoved>(_onRecentRemoved);
    on<SearchRecentCleared>(_onRecentCleared);
  }

  final StudentRepository _repository;
  final SearchRecommendationEngine recEngine;

  List<String> _recentSearches = ['Flutter', 'Bloc', 'UI Design'];
  List<RecommendedCourseItem> _cachedRecommendations = [];

  Future<void> _onInitRequested(
    SearchInitRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (_cachedRecommendations.isNotEmpty) {
      emit(SearchInitial(
        recentSearches: _recentSearches,
        recommendedCourses: _cachedRecommendations,
        isLoadingRecommendations: false,
      ));
      return;
    }

    emit(SearchInitial(
      recentSearches: _recentSearches,
      recommendedCourses: const [],
      isLoadingRecommendations: true,
    ));

    final coursesResult = await _repository.getAllCourses();
    final enrollmentsResult = await _repository.getActiveEnrollments();

    var allCourses = <CourseModel>[];
    coursesResult.when(
      success: (c) => allCourses = c,
      failure: (_) {},
    );

    var activeEnrollments = <EnrollmentModel>[];
    enrollmentsResult.when(
      success: (e) => activeEnrollments = e,
      failure: (_) {},
    );

    _cachedRecommendations = recEngine.generateRecommendations(
      allCourses: allCourses,
      activeEnrollments: activeEnrollments,
      recentSearches: _recentSearches,
    );

    emit(SearchInitial(
      recentSearches: _recentSearches,
      recommendedCourses: _cachedRecommendations,
      isLoadingRecommendations: false,
    ));
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(SearchInitial(
        recentSearches: _recentSearches,
        recommendedCourses: _cachedRecommendations,
        isLoadingRecommendations: false,
      ));
      return;
    }

    final currentFilter = state is SearchSuccess
        ? (state as SearchSuccess).filter
        : SearchFilter.all;

    emit(SearchInProgress(query: query, filter: currentFilter));

    // Thêm từ khóa vào danh sách tìm kiếm gần đây nếu hợp lệ
    if (query.length >= 2 && !_recentSearches.contains(query)) {
      _recentSearches = [
        query,
        ..._recentSearches.where((s) => s.toLowerCase() != query.toLowerCase()),
      ].take(8).toList();
    }

    final result = await _repository.searchCourses(query);

    result.when(
      success: (courses) {
        final lowerQuery = query.toLowerCase();
        final filtered = courses.where((course) {
          final title = course.title.toLowerCase();
          final category = (course.categoryName ?? '').toLowerCase();
          final instructor = (course.instructorName ?? '').toLowerCase();
          return title.contains(lowerQuery) ||
              category.contains(lowerQuery) ||
              instructor.contains(lowerQuery);
        }).toList();

        final results = filtered
            .map((course) => SearchResult(
                  id: course.id,
                  title: course.title,
                  subtitle:
                      '${course.categoryName ?? 'Khóa học'} · ${course.totalLessons} bài',
                  type: SearchFilter.course,
                  imageUrl: course.thumbnailUrl,
                ))
            .toList();

        if (results.isEmpty) {
          emit(SearchEmpty(query: query));
        } else {
          emit(SearchSuccess(
            query: query,
            filter: currentFilter,
            results: results,
          ));
        }
      },
      failure: (_) {
        emit(SearchEmpty(query: query));
      },
    );
  }

  void _onFilterChanged(
    SearchFilterChanged event,
    Emitter<SearchState> emit,
  ) {
    final current = state;
    if (current is SearchSuccess) {
      emit(SearchSuccess(
        query: current.query,
        filter: event.filter,
        results: current.results,
      ));
    }
  }

  void _onCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial(
      recentSearches: _recentSearches,
      recommendedCourses: _cachedRecommendations,
      isLoadingRecommendations: false,
    ));
  }

  void _onRecentRemoved(
    SearchRecentRemoved event,
    Emitter<SearchState> emit,
  ) {
    _recentSearches = _recentSearches.where((s) => s != event.query).toList();
    emit(SearchInitial(
      recentSearches: _recentSearches,
      recommendedCourses: _cachedRecommendations,
      isLoadingRecommendations: false,
    ));
  }

  void _onRecentCleared(
    SearchRecentCleared event,
    Emitter<SearchState> emit,
  ) {
    _recentSearches = [];
    emit(SearchInitial(
      recentSearches: const [],
      recommendedCourses: _cachedRecommendations,
      isLoadingRecommendations: false,
    ));
  }
}
