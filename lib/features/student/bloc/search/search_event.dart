import 'package:equatable/equatable.dart';

enum SearchFilter { all, course, lesson, quiz }

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchFilterChanged extends SearchEvent {
  const SearchFilterChanged(this.filter);

  final SearchFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class SearchCleared extends SearchEvent {
  const SearchCleared();
}
