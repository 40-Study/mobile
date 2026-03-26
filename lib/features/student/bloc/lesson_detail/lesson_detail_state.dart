part of 'lesson_detail_cubit.dart';

@immutable
sealed class LessonDetailState extends Equatable {
  const LessonDetailState();

  @override
  List<Object?> get props => [];
}

final class LessonDetailInitial extends LessonDetailState {
  const LessonDetailInitial();
}

final class LessonDetailLoading extends LessonDetailState {
  const LessonDetailLoading();
}

final class LessonDetailLoaded extends LessonDetailState {
  const LessonDetailLoaded({required this.detail});

  final LessonDetailModel detail;

  @override
  List<Object?> get props => [detail];
}

final class LessonDetailFailure extends LessonDetailState {
  const LessonDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
