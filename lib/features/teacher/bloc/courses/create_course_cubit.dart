import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/models/create_course_model.dart';

part 'create_course_state.dart';

class CreateCourseCubit extends Cubit<CreateCourseState> {
  CreateCourseCubit() : super(const CreateCourseState());

  void updateCourseName(String name) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(name: name),
    ));
  }

  void updateTeachingFormat(TeachingFormat format) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(teachingFormat: format),
    ));
  }

  void updateCategory(String? categoryId) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(categoryId: categoryId),
    ));
  }

  void updateLevel(CourseLevel level) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(level: level),
    ));
  }

  void updateShortDescription(String description) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(shortDescription: description),
    ));
  }

  void updateThumbnail(String? url) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(thumbnailUrl: url),
    ));
  }

  void updateFullDescription(String description) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(fullDescription: description),
    ));
  }

  void updatePrice(double price) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(price: price),
    ));
  }

  void updateDiscountPrice(double? price) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(discountPrice: price),
    ));
  }

  void updateIsFree(bool isFree) {
    emit(state.copyWith(
      courseData: state.courseData.copyWith(isFree: isFree),
    ));
  }

  void nextStep() {
    if (state.currentStep < 3) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      emit(state.copyWith(currentStep: step));
    }
  }

  bool validateCurrentStep() {
    switch (state.currentStep) {
      case 0:
        return state.courseData.name.isNotEmpty;
      case 1:
        return true;
      case 2:
        return state.courseData.isFree || state.courseData.price > 0;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> submitCourse() async {
    emit(state.copyWith(isSubmitting: true));

    try {
      // TODO: Call API to create course
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(state.copyWith(
        isSubmitting: false,
        isCompleted: true,
      ));
    } catch (e) {
      debugPrint('submitCourse error: $e');
      emit(state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      ));
    }
  }

  void reset() {
    emit(const CreateCourseState());
  }
}
