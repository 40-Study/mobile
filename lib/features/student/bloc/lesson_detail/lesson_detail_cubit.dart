import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/lesson_detail_model.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'lesson_detail_state.dart';

class LessonDetailCubit extends Cubit<LessonDetailState> {
  LessonDetailCubit({
    required StudentRepository repository,
    required this.lessonId,
  })  : _repository = repository,
        super(const LessonDetailInitial());

  final StudentRepository _repository;
  final String lessonId;

  Future<void> load() async {
    emit(const LessonDetailLoading());
    try {
      final detail = await _repository.getLessonDetail(lessonId);
      emit(LessonDetailLoaded(detail: detail));
    } catch (e) {
      emit(LessonDetailFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    await load();
  }
}
