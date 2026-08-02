import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

final class BookmarkStarted extends BookmarkEvent {
  const BookmarkStarted();
}

final class BookmarkFilterChanged extends BookmarkEvent {
  const BookmarkFilterChanged(this.filter);

  final BookmarkType? filter;

  @override
  List<Object?> get props => [filter];
}

final class BookmarkRemoved extends BookmarkEvent {
  const BookmarkRemoved(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
