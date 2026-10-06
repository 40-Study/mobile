import 'package:equatable/equatable.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_learning_hub_data.dart';

enum ParentLearningStatus { initial, loading, success, failure }

class ParentLearningState extends Equatable {
  const ParentLearningState({
    this.status = ParentLearningStatus.initial,
    this.children = const [],
    this.selectedChildId,
    this.hubData,
    this.allHubData = const {},
    this.errorMessage,
  });

  final ParentLearningStatus status;
  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final ParentLearningHubData? hubData;
  final Map<String, ParentLearningHubData> allHubData;
  final String? errorMessage;

  bool get isLoading => status == ParentLearningStatus.loading;
  bool get isSuccess => status == ParentLearningStatus.success;
  bool get isFailure => status == ParentLearningStatus.failure;

  /// Đang xem ở chế độ "Tất cả các con" (khi selectedChildId == null)
  bool get isAllChildrenSelected => selectedChildId == null;

  /// Con đang được chọn
  FamilyScopeChild? get activeChild {
    if (selectedChildId == null || children.isEmpty) return null;
    return children.cast<FamilyScopeChild?>().firstWhere(
          (c) => c?.id == selectedChildId,
          orElse: () => null,
        );
  }

  ParentLearningState copyWith({
    ParentLearningStatus? status,
    List<FamilyScopeChild>? children,
    String? Function()? selectedChildId,
    ParentLearningHubData? Function()? hubData,
    Map<String, ParentLearningHubData>? allHubData,
    String? Function()? errorMessage,
  }) {
    return ParentLearningState(
      status: status ?? this.status,
      children: children ?? this.children,
      selectedChildId:
          selectedChildId != null ? selectedChildId() : this.selectedChildId,
      hubData: hubData != null ? hubData() : this.hubData,
      allHubData: allHubData ?? this.allHubData,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        children,
        selectedChildId,
        hubData,
        allHubData,
        errorMessage,
      ];
}
