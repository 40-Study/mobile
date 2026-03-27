import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/course_detail_model.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'course_detail_state.dart';

class CourseDetailCubit extends Cubit<CourseDetailState> {
  CourseDetailCubit({
    required StudentRepository repository,
    required this.enrollmentId,
    required this.courseId,
  })  : _repository = repository,
        super(const CourseDetailInitial());

  final StudentRepository _repository;
  final String enrollmentId;
  final String courseId;

  Future<void> load() async {
    emit(const CourseDetailLoading());
    try {
      final detail = await _repository.getCourseDetail(
        enrollmentId: enrollmentId,
        courseId: courseId,
      );
      emit(CourseDetailLoaded(detail: detail));
    } catch (e) {
      emit(CourseDetailFailure(message: e.toString()));
    }
  }

  Future<void> refresh() async {
    await load();
  }
}
