import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/parent/data/models/models.dart';

@immutable
sealed class ChildDetailState extends Equatable {
  const ChildDetailState();

  @override
  List<Object?> get props => [];
}

final class ChildDetailInitial extends ChildDetailState {
  const ChildDetailInitial();
}

final class ChildDetailLoading extends ChildDetailState {
  const ChildDetailLoading();
}

final class ChildDetailLoaded extends ChildDetailState {
  const ChildDetailLoaded({
    required this.child,
    required this.classes,
    required this.attendances,
    required this.enrollments,
    this.selectedTabIndex = 0,
  });

  final ChildModel child;
  final List<ChildClassModel> classes;
  final List<ChildAttendanceModel> attendances;
  final List<ChildEnrollmentModel> enrollments;
  final int selectedTabIndex;

  ChildDetailLoaded copyWith({
    ChildModel? child,
    List<ChildClassModel>? classes,
    List<ChildAttendanceModel>? attendances,
    List<ChildEnrollmentModel>? enrollments,
    int? selectedTabIndex,
  }) {
    return ChildDetailLoaded(
      child: child ?? this.child,
      classes: classes ?? List.of(this.classes),
      attendances: attendances ?? List.of(this.attendances),
      enrollments: enrollments ?? List.of(this.enrollments),
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  List<Object?> get props => [
        child,
        classes,
        attendances,
        enrollments,
        selectedTabIndex,
      ];
}

final class ChildDetailFailure extends ChildDetailState {
  const ChildDetailFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
