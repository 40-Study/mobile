part of 'create_course_cubit.dart';

@immutable
class CreateCourseState extends Equatable {
  const CreateCourseState({
    this.currentStep = 0,
    this.courseData = const CreateCourseModel(),
    this.categories = const [],
    this.isSubmitting = false,
    this.isCompleted = false,
    this.error,
  });

  final int currentStep;
  final CreateCourseModel courseData;
  final List<CourseCategoryModel> categories;
  final bool isSubmitting;
  final bool isCompleted;
  final String? error;

  CreateCourseState copyWith({
    int? currentStep,
    CreateCourseModel? courseData,
    List<CourseCategoryModel>? categories,
    bool? isSubmitting,
    bool? isCompleted,
    String? error,
  }) {
    return CreateCourseState(
      currentStep: currentStep ?? this.currentStep,
      courseData: courseData ?? this.courseData,
      categories: categories ?? this.categories,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        courseData,
        categories,
        isSubmitting,
        isCompleted,
        error,
      ];
}
