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
  });

  final EnrollmentModel? continueLearning;
  final List<ScheduleItemModel> scheduleItems;
  final List<AssignmentModel> assignments;

  @override
  List<Object?> get props => [continueLearning, scheduleItems, assignments];

  HomeSuccess copyWith({
    EnrollmentModel? continueLearning,
    List<ScheduleItemModel>? scheduleItems,
    List<AssignmentModel>? assignments,
  }) {
    return HomeSuccess(
      continueLearning: continueLearning ?? this.continueLearning,
      scheduleItems: scheduleItems ?? this.scheduleItems,
      assignments: assignments ?? this.assignments,
    );
  }
}

final class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
