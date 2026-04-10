import 'package:equatable/equatable.dart';
import 'package:study/features/parent/data/models/models.dart';

sealed class ChildrenSelectorState extends Equatable {
  const ChildrenSelectorState();

  @override
  List<Object?> get props => [];
}

final class ChildrenSelectorInitial extends ChildrenSelectorState {
  const ChildrenSelectorInitial();
}

final class ChildrenSelectorLoading extends ChildrenSelectorState {
  const ChildrenSelectorLoading();
}

final class ChildrenSelectorLoaded extends ChildrenSelectorState {
  const ChildrenSelectorLoaded({
    required this.children,
    this.selectedChild,
  });

  final List<ChildModel> children;
  final ChildModel? selectedChild;

  @override
  List<Object?> get props => [children, selectedChild];

  ChildrenSelectorLoaded copyWith({
    List<ChildModel>? children,
    ChildModel? selectedChild,
  }) {
    return ChildrenSelectorLoaded(
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
    );
  }
}

final class ChildrenSelectorFailure extends ChildrenSelectorState {
  const ChildrenSelectorFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
