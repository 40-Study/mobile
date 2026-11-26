import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/config/preview_flags.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_state.dart';
import 'package:study/features/student/data/mock/mock_course_detail_data.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  LessonBloc(this._repository) : super(const LessonInitial()) {
    on<LessonStarted>(_onStarted);
    on<LessonContentTabChanged>(_onTabChanged);
    on<LessonCompleted>(_onCompleted);
  }

  final StudentRepository _repository;
  String? _lessonId;

  Future<void> _onStarted(
    LessonStarted event,
    Emitter<LessonState> emit,
  ) async {
    _lessonId = event.lessonId;
    emit(const LessonInProgress());

    if (kPreviewDataEnabled &&
        MockCourseDetailData.isMockLessonId(event.lessonId)) {
      final mockLesson = MockCourseDetailData.getMockLesson(event.lessonId);
      emit(LessonSuccess(
        lesson: mockLesson,
        isCompleted: true,
        quizzes: const [],
      ));
      return;
    }

    final result = await _repository.getLessonDetail(event.lessonId);

    await result.when(
      success: (lesson) async {
        final isCompleted = lesson.progress?.status == 'completed';
        // Fetch quizzes for this lesson
        final quizzesResult = await _repository.getQuizzesByLesson(event.lessonId);
        final quizzes = quizzesResult.when(
          success: (q) => q,
          failure: (_) => <QuizModel>[],
        );
        emit(LessonSuccess(
          lesson: lesson,
          isCompleted: isCompleted,
          quizzes: quizzes,
        ));
      },
      failure: (error) {
        emit(LessonFailure(error.message ?? 'Không tải được bài học'));
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
    // Đã completed thì không gửi lại
    if (currentState is! LessonSuccess || _lessonId == null) return;
    if (currentState.isCompleted) return;

    final result = await _repository.markLessonComplete(
      _lessonId!,
      playedRanges: event.playedRanges,
      durationSeconds: event.durationSeconds,
    );
    // Dùng state mới nhất: response cũ về muộn không được hạ trạng thái completed
    final latest = state;
    if (latest is! LessonSuccess) return;
    emit(result.when(
      success: (r) => latest.copyWith(
        isCompleted: latest.isCompleted || r.lessonCompleted,
        courseCompleted: latest.courseCompleted || r.courseCompleted,
      ),
      failure: (error) => latest.isCompleted
          ? latest
          : latest.copyWith(
              completionError:
                  error.message ?? 'Không lưu được tiến độ bài học',
            ),
    ));
  }
}
