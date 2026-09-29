import 'package:equatable/equatable.dart';

sealed class FamilyInsightsInboxEvent extends Equatable {
  const FamilyInsightsInboxEvent();

  @override
  List<Object?> get props => [];
}

class FamilyInsightsInboxStarted extends FamilyInsightsInboxEvent {
  const FamilyInsightsInboxStarted();
}

class FamilyInsightsInboxChildFilterChanged extends FamilyInsightsInboxEvent {
  const FamilyInsightsInboxChildFilterChanged(this.childId);

  final String? childId;

  @override
  List<Object?> get props => [childId];
}

class FamilyInsightsInboxMarkAllAsRead extends FamilyInsightsInboxEvent {
  const FamilyInsightsInboxMarkAllAsRead();
}

class FamilyInsightsInboxSendEncouraged extends FamilyInsightsInboxEvent {
  const FamilyInsightsInboxSendEncouraged(this.insightId);

  final String insightId;

  @override
  List<Object?> get props => [insightId];
}

class FamilyInsightsInboxRefreshed extends FamilyInsightsInboxEvent {
  const FamilyInsightsInboxRefreshed();
}
