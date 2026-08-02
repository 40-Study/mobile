import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_event.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_state.dart';
import 'package:study/features/student/data/models/models.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  BookmarkBloc() : super(const BookmarkInitial()) {
    on<BookmarkStarted>(_onStarted);
    on<BookmarkFilterChanged>(_onFilterChanged);
    on<BookmarkRemoved>(_onRemoved);
  }

  Future<void> _onStarted(
    BookmarkStarted event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(const BookmarkInProgress());

    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Mock data
    final now = DateTime.now();
    final bookmarks = [
      BookmarkModel(
        id: '1',
        itemId: 'course-1',
        type: BookmarkType.course,
        title: 'Flutter Advanced',
        subtitle: '24 bai hoc',
        savedAt: now.subtract(const Duration(days: 1)),
      ),
      BookmarkModel(
        id: '2',
        itemId: 'lesson-1',
        type: BookmarkType.lesson,
        title: 'State Management voi Bloc',
        subtitle: 'Flutter Advanced - Bai 5',
        savedAt: now.subtract(const Duration(days: 2)),
      ),
      BookmarkModel(
        id: '3',
        itemId: 'doc-1',
        type: BookmarkType.document,
        title: 'Bloc Pattern Cheatsheet',
        subtitle: 'PDF - 2.5MB',
        savedAt: now.subtract(const Duration(days: 3)),
      ),
      BookmarkModel(
        id: '4',
        itemId: 'course-2',
        type: BookmarkType.course,
        title: 'UI/UX Design',
        subtitle: '18 bai hoc',
        savedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    emit(BookmarkSuccess(bookmarks: bookmarks));
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

  void _onRemoved(
    BookmarkRemoved event,
    Emitter<BookmarkState> emit,
  ) {
    final current = state;
    if (current is! BookmarkSuccess) return;

    final updated = current.bookmarks.where((b) => b.id != event.id).toList();

    emit(BookmarkSuccess(
      bookmarks: updated,
      filter: current.filter,
    ));
  }
}
