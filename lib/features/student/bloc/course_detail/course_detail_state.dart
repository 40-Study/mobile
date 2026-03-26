part of 'course_detail_cubit.dart';

@immutable
sealed class CourseDetailState extends Equatable {
  const CourseDetailState();

  @override
  List<Object?> get props => [];
}

final class CourseDetailInitial extends CourseDetailState {
  const CourseDetailInitial();
}

final class CourseDetailLoading extends CourseDetailState {
  const CourseDetailLoading();
}

final class CourseDetailLoaded extends CourseDetailState {
  const CourseDetailLoaded({required this.detail});

  final CourseDetailModel detail;

  @override
  List<Object?> get props => [detail];
}

final class CourseDetailFailure extends CourseDetailState {
  const CourseDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
