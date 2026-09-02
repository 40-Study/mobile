import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/search/search_event.dart';
import 'package:study/features/student/bloc/search/search_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository)
      : super(const SearchInitial(recentSearches: ['Flutter', 'Bloc', 'UI Design'])) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFilterChanged>(_onFilterChanged);
    on<SearchCleared>(_onCleared);
  }

  final StudentRepository _repository;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchInitial(recentSearches: ['Flutter', 'Bloc', 'UI Design']));
      return;
    }

    final currentFilter = state is SearchSuccess
        ? (state as SearchSuccess).filter
        : SearchFilter.all;

    emit(SearchInProgress(query: query, filter: currentFilter));

    final result = await _repository.searchCourses(query);

    result.when(
      success: (courses) {
        final results = courses.map((course) => SearchResult(
          id: course.id,
          title: course.title,
          subtitle: '${course.categoryName ?? 'Khoa hoc'} - ${course.totalLessons ?? 0} bai',
          type: SearchFilter.course,
        )).toList();

        if (results.isEmpty) {
          emit(SearchEmpty(query: query));
        } else {
          emit(SearchSuccess(query: query, filter: currentFilter, results: results));
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
    emit(const SearchInitial(recentSearches: ['Flutter', 'Bloc', 'UI Design']));
  }
}
