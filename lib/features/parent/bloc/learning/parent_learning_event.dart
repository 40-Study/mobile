import 'package:equatable/equatable.dart';

abstract class ParentLearningEvent extends Equatable {
  const ParentLearningEvent();

  @override
  List<Object?> get props => [];
}

class ParentLearningStarted extends ParentLearningEvent {
  const ParentLearningStarted();
}

class ParentLearningChildSelected extends ParentLearningEvent {
  const ParentLearningChildSelected(this.childId);

  final String? childId;

  @override
  List<Object?> get props => [childId];
}

class ParentLearningRefreshed extends ParentLearningEvent {
  const ParentLearningRefreshed();
}
