import 'package:equatable/equatable.dart';
import 'package:study/features/student/bloc/search/search_event.dart';

class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  final String id;
  final String title;
  final String subtitle;
  final SearchFilter type;
}

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

final class SearchInitial extends SearchState {
  const SearchInitial({this.recentSearches = const []});

  final List<String> recentSearches;

  @override
  List<Object?> get props => [recentSearches];
}

final class SearchInProgress extends SearchState {
  const SearchInProgress({required this.query, required this.filter});

  final String query;
  final SearchFilter filter;

  @override
  List<Object?> get props => [query, filter];
}

final class SearchSuccess extends SearchState {
  const SearchSuccess({
    required this.query,
    required this.filter,
    required this.results,
  });

  final String query;
  final SearchFilter filter;
  final List<SearchResult> results;

  List<SearchResult> get filteredResults {
    if (filter == SearchFilter.all) return results;
    return results.where((r) => r.type == filter).toList();
  }

  @override
  List<Object?> get props => [query, filter, results];
}

final class SearchEmpty extends SearchState {
  const SearchEmpty({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}
