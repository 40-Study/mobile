import 'package:equatable/equatable.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeInProgress extends HomeState {
  const HomeInProgress();
}

final class HomeSuccess extends HomeState {
  const HomeSuccess({
    this.continueLearning,
    this.scheduleItems = const [],
    this.assignments = const [],
    this.classCourseNavigation,
  });

  final EnrollmentModel? continueLearning;
  final List<ScheduleItemModel> scheduleItems;
  final List<AssignmentModel> assignments;
  // Navigation intent: enrollment to navigate to, or error message
  final ClassCourseNavigation? classCourseNavigation;

  @override
  List<Object?> get props => [continueLearning, scheduleItems, assignments, classCourseNavigation];

  HomeSuccess copyWith({
    EnrollmentModel? continueLearning,
    List<ScheduleItemModel>? scheduleItems,
    List<AssignmentModel>? assignments,
    ClassCourseNavigation? classCourseNavigation,
    bool clearNavigation = false,
  }) {
    return HomeSuccess(
      continueLearning: continueLearning ?? this.continueLearning,
      scheduleItems: scheduleItems ?? this.scheduleItems,
      assignments: assignments ?? this.assignments,
      classCourseNavigation: clearNavigation ? null : (classCourseNavigation ?? this.classCourseNavigation),
    );
  }
}

/// Result of class->course lookup for navigation
sealed class ClassCourseNavigation extends Equatable {
  const ClassCourseNavigation();
}

final class ClassCourseNavigationLoading extends ClassCourseNavigation {
  const ClassCourseNavigationLoading();

  @override
  List<Object?> get props => [];
}

final class ClassCourseNavigationSuccess extends ClassCourseNavigation {
  const ClassCourseNavigationSuccess(this.enrollment);

  final EnrollmentModel enrollment;

  @override
  List<Object?> get props => [enrollment];
}

final class ClassCourseNavigationError extends ClassCourseNavigation {
  const ClassCourseNavigationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
