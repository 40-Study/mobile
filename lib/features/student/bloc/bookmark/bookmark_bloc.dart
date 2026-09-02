import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_event.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  BookmarkBloc(this._storage) : super(const BookmarkInitial()) {
    on<BookmarkStarted>(_onStarted);
    on<BookmarkFilterChanged>(_onFilterChanged);
    on<BookmarkRemoved>(_onRemoved);
  }

  final BookmarkStorage _storage;

  Future<void> _onStarted(
    BookmarkStarted event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(const BookmarkInProgress());

    try {
      final bookmarks = await _storage.getAll();
      emit(BookmarkSuccess(bookmarks: bookmarks));
    } catch (e) {
      emit(BookmarkFailure(e.toString()));
    }
  }

  void _onFilterChanged(
    BookmarkFilterChanged event,
    Emitter<BookmarkState> emit,
  ) {
    final current = state;
    if (current is! BookmarkSuccess) return;

    emit(BookmarkSuccess(
      bookmarks: current.bookmarks,
      filter: event.filter,
    ));
  }

  Future<void> _onRemoved(
    BookmarkRemoved event,
    Emitter<BookmarkState> emit,
  ) async {
    final current = state;
    if (current is! BookmarkSuccess) return;

    // Optimistic update
    final updated = current.bookmarks.where((b) => b.id != event.id).toList();
    emit(BookmarkSuccess(bookmarks: updated, filter: current.filter));

    // Persist
    await _storage.remove(event.id);
  }
}
