import 'package:equatable/equatable.dart';

sealed class CourseDetailEvent extends Equatable {
  const CourseDetailEvent();

  @override
  List<Object?> get props => [];
}

final class CourseDetailStarted extends CourseDetailEvent {
  const CourseDetailStarted(this.id, {this.isEnrollment = true});

  final String id;
  final bool isEnrollment;

  @override
  List<Object?> get props => [id, isEnrollment];
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
