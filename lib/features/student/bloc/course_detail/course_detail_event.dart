import 'package:equatable/equatable.dart';

sealed class CourseDetailEvent extends Equatable {
  const CourseDetailEvent();

  @override
  List<Object?> get props => [];
}

final class CourseDetailStarted extends CourseDetailEvent {
  const CourseDetailStarted(this.enrollmentId);

  final String enrollmentId;

  @override
  List<Object?> get props => [enrollmentId];
}

final class CourseDetailRefreshed extends CourseDetailEvent {
  const CourseDetailRefreshed();
}

final class CourseDetailSectionToggled extends CourseDetailEvent {
  const CourseDetailSectionToggled(this.sectionId);

  final String sectionId;

  @override
  List<Object?> get props => [sectionId];
}
