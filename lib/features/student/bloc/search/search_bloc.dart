import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/search/search_event.dart';
import 'package:study/features/student/bloc/search/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchInitial(recentSearches: ['Flutter', 'Bloc', 'UI Design'])) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFilterChanged>(_onFilterChanged);
    on<SearchCleared>(_onCleared);
  }

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

    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Mock search
    final allResults = [
      const SearchResult(
        id: '1',
        title: 'Flutter Advanced',
        subtitle: 'Khoa hoc - 24 bai',
        type: SearchFilter.course,
      ),
      const SearchResult(
        id: '2',
        title: 'State Management voi Bloc',
        subtitle: 'Bai hoc - Flutter Advanced',
        type: SearchFilter.lesson,
      ),
      const SearchResult(
        id: '3',
        title: 'Flutter Widgets Quiz',
        subtitle: 'Quiz - 20 cau hoi',
        type: SearchFilter.quiz,
      ),
      const SearchResult(
        id: '4',
        title: 'UI/UX Design Basics',
        subtitle: 'Khoa hoc - 18 bai',
        type: SearchFilter.course,
      ),
      const SearchResult(
        id: '5',
        title: 'Navigation trong Flutter',
        subtitle: 'Bai hoc - Flutter Basics',
        type: SearchFilter.lesson,
      ),
    ];

    final results = allResults
        .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
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
