import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

final class HomeClassCourseRequested extends HomeEvent {
  const HomeClassCourseRequested(this.classId);

  final String classId;

  @override
  List<Object?> get props => [classId];
}

final class HomeClassCourseNavigationHandled extends HomeEvent {
  const HomeClassCourseNavigationHandled();
}
