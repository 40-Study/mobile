import 'package:equatable/equatable.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/course/data/models/course_model.dart';

sealed class CourseDetailState extends Equatable {
  const CourseDetailState();

  @override
  List<Object?> get props => [];
}

final class CourseDetailInitial extends CourseDetailState {
  const CourseDetailInitial();
}

final class CourseDetailInProgress extends CourseDetailState {
  const CourseDetailInProgress();
}

final class CourseDetailSuccess extends CourseDetailState {
  const CourseDetailSuccess({
    required this.enrollment,
    this.expandedSections = const {},
  });

  final EnrollmentModel enrollment;
  final Set<String> expandedSections;

  CourseModel? get course => enrollment.course;
  List<SectionModel> get sections => course?.sections ?? [];

  @override
  List<Object?> get props => [enrollment, expandedSections];

  CourseDetailSuccess copyWith({
    EnrollmentModel? enrollment,
    Set<String>? expandedSections,
  }) {
    return CourseDetailSuccess(
      enrollment: enrollment ?? this.enrollment,
      expandedSections: expandedSections ?? this.expandedSections,
    );
  }
}

final class CourseDetailFailure extends CourseDetailState {
  const CourseDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
