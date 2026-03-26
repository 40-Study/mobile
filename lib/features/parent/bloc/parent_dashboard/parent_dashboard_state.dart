import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/parent/data/models/models.dart';

@immutable
sealed class ParentDashboardState extends Equatable {
  const ParentDashboardState();

  @override
  List<Object?> get props => [];
}

final class ParentDashboardInitial extends ParentDashboardState {
  const ParentDashboardInitial();
}

final class ParentDashboardLoading extends ParentDashboardState {
  const ParentDashboardLoading();
}

final class ParentDashboardLoaded extends ParentDashboardState {
  const ParentDashboardLoaded({
    required this.children,
    required this.notifications,
    this.parentName = 'Phu huynh',
  });

  final List<ChildModel> children;
  final List<ParentNotificationModel> notifications;
  final String parentName;

  @override
  List<Object?> get props => [children, notifications, parentName];
}

final class ParentDashboardFailure extends ParentDashboardState {
  const ParentDashboardFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
