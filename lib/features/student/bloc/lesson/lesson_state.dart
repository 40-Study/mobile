import 'package:equatable/equatable.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';

sealed class LessonState extends Equatable {
  const LessonState();

  @override
  List<Object?> get props => [];
}

final class LessonInitial extends LessonState {
  const LessonInitial();
}

final class LessonInProgress extends LessonState {
  const LessonInProgress();
}

final class LessonSuccess extends LessonState {
  const LessonSuccess({
    required this.lesson,
    this.selectedTab = LessonContentTab.video,
    this.isCompleted = false,
  });

  final LessonModel lesson;
  final LessonContentTab selectedTab;
  final bool isCompleted;

  String? get videoUrl {
    final videoContent = lesson.contents?.firstWhere(
      (c) => c.type == 'video',
      orElse: () => const LessonContentModel(id: '', type: '', title: ''),
    );
    return videoContent?.videoUrl;
  }

  double get progressPercentage => lesson.progress?.progressPercentage ?? 0;

  @override
  List<Object?> get props => [lesson, selectedTab, isCompleted];

  LessonSuccess copyWith({
    LessonModel? lesson,
    LessonContentTab? selectedTab,
    bool? isCompleted,
  }) {
    return LessonSuccess(
      lesson: lesson ?? this.lesson,
      selectedTab: selectedTab ?? this.selectedTab,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

final class LessonFailure extends LessonState {
  const LessonFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
