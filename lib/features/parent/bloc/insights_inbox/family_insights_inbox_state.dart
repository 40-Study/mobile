import 'package:equatable/equatable.dart';
import 'package:study/features/parent/data/models/models.dart';

sealed class FamilyInsightsInboxState extends Equatable {
  const FamilyInsightsInboxState();

  @override
  List<Object?> get props => [];
}

class FamilyInsightsInboxInitial extends FamilyInsightsInboxState {
  const FamilyInsightsInboxInitial();
}

class FamilyInsightsInboxLoading extends FamilyInsightsInboxState {
  const FamilyInsightsInboxLoading();
}

class FamilyInsightsInboxSuccess extends FamilyInsightsInboxState {
  const FamilyInsightsInboxSuccess({
    required this.insights,
    required this.allInsights,
    required this.children,
    this.selectedChildId,
    this.encouragedIds = const {},
  });

  final List<FamilyInsightItem> insights;
  final List<FamilyInsightItem> allInsights;
  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final Set<String> encouragedIds;

  int get unreadCount => allInsights.where((item) => !item.isRead).length;

  int countForChild(String? childId) {
    if (childId == null) return allInsights.length;
    return allInsights.where((item) => item.childId == childId).length;
  }

  FamilyInsightsInboxSuccess copyWith({
    List<FamilyInsightItem>? insights,
    List<FamilyInsightItem>? allInsights,
    List<FamilyScopeChild>? children,
    String? selectedChildId,
    bool clearSelectedChild = false,
    Set<String>? encouragedIds,
  }) {
    return FamilyInsightsInboxSuccess(
      insights: insights ?? this.insights,
      allInsights: allInsights ?? this.allInsights,
      children: children ?? this.children,
      selectedChildId: clearSelectedChild
          ? null
          : (selectedChildId ?? this.selectedChildId),
      encouragedIds: encouragedIds ?? this.encouragedIds,
    );
  }

  @override
  List<Object?> get props => [
        insights,
        allInsights,
        children,
        selectedChildId,
        encouragedIds,
      ];
}

class FamilyInsightsInboxFailure extends FamilyInsightsInboxState {
  const FamilyInsightsInboxFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
