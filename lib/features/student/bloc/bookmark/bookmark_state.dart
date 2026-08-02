import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

final class BookmarkInitial extends BookmarkState {
  const BookmarkInitial();
}

final class BookmarkInProgress extends BookmarkState {
  const BookmarkInProgress();
}

final class BookmarkSuccess extends BookmarkState {
  const BookmarkSuccess({
    required this.bookmarks,
    this.filter,
  });

  final List<BookmarkModel> bookmarks;
  final BookmarkType? filter;

  List<BookmarkModel> get filteredBookmarks {
    if (filter == null) return bookmarks;
    return bookmarks.where((b) => b.type == filter).toList();
  }

  @override
  List<Object?> get props => [bookmarks, filter];
}

final class BookmarkFailure extends BookmarkState {
  const BookmarkFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
