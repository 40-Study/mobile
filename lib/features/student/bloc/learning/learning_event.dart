import 'package:equatable/equatable.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';

sealed class LearningEvent extends Equatable {
  const LearningEvent();

  @override
  List<Object?> get props => [];
}

final class LearningStarted extends LearningEvent {
  const LearningStarted();
}

final class LearningRefreshed extends LearningEvent {
  const LearningRefreshed();
}

final class LearningFilterChanged extends LearningEvent {
  const LearningFilterChanged(this.filter);

  final EnrollmentFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class LearningSearchChanged extends LearningEvent {
  const LearningSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
