import 'package:equatable/equatable.dart';

enum LessonContentTab { video, documents, quiz, notes }
enum LessonNavDirection { prev, next }

sealed class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object?> get props => [];
}

final class LessonStarted extends LessonEvent {
  const LessonStarted(this.lessonId);

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

final class LessonContentTabChanged extends LessonEvent {
  const LessonContentTabChanged(this.tab);

  final LessonContentTab tab;

  @override
  List<Object?> get props => [tab];
}

final class LessonCompleted extends LessonEvent {
  const LessonCompleted();
}

final class LessonVideoProgressUpdated extends LessonEvent {
  const LessonVideoProgressUpdated(this.watchedSeconds);

  final int watchedSeconds;

  @override
  List<Object?> get props => [watchedSeconds];
}
