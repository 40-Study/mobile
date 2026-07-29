import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  LessonBloc(this._repository) : super(const LessonInitial()) {
    on<LessonStarted>(_onStarted);
    on<LessonContentTabChanged>(_onTabChanged);
    on<LessonCompleted>(_onCompleted);
    on<LessonVideoProgressUpdated>(_onVideoProgress);
  }

  final StudentRepository _repository;
  String? _lessonId;

  Future<void> _onStarted(
    LessonStarted event,
    Emitter<LessonState> emit,
  ) async {
    _lessonId = event.lessonId;
    emit(const LessonInProgress());

    final result = await _repository.getLessonDetail(event.lessonId);

    result.when(
      success: (lesson) {
        final isCompleted = lesson.progress?.status == 'completed';
        emit(LessonSuccess(lesson: lesson, isCompleted: isCompleted));
      },
      failure: (error) {
        emit(LessonFailure(error.message ?? 'Loi khong xac dinh'));
      },
    );
  }

  void _onTabChanged(
    LessonContentTabChanged event,
    Emitter<LessonState> emit,
  ) {
    final currentState = state;
    if (currentState is LessonSuccess) {
      emit(currentState.copyWith(selectedTab: event.tab));
    }
  }

  Future<void> _onCompleted(
    LessonCompleted event,
    Emitter<LessonState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LessonSuccess || _lessonId == null) return;

    await _repository.markLessonComplete(_lessonId!);
    emit(currentState.copyWith(isCompleted: true));
  }

  void _onVideoProgress(
    LessonVideoProgressUpdated event,
    Emitter<LessonState> emit,
  ) {
    // Track video progress locally
    // TODO: Sync với server nếu cần
  }
}
