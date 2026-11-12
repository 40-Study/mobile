import 'package:equatable/equatable.dart';

enum SearchFilter { all, course, lesson, quiz }

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Khởi tạo màn hình tìm kiếm và tải đề xuất thông minh
final class SearchInitRequested extends SearchEvent {
  const SearchInitRequested();
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

/// Xóa một từ khóa khỏi lịch sử tìm kiếm gần đây
final class SearchRecentRemoved extends SearchEvent {
  const SearchRecentRemoved(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Xóa toàn bộ lịch sử tìm kiếm gần đây
final class SearchRecentCleared extends SearchEvent {
  const SearchRecentCleared();
}
