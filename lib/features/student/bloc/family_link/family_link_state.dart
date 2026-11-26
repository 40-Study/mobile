import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/family_link_model.dart';

sealed class FamilyLinkState extends Equatable {
  const FamilyLinkState();

  @override
  List<Object?> get props => [];
}

class FamilyLinkInitial extends FamilyLinkState {
  const FamilyLinkInitial();
}

class FamilyLinkLoading extends FamilyLinkState {
  const FamilyLinkLoading();
}

class FamilyLinkSuccess extends FamilyLinkState {
  const FamilyLinkSuccess({
    required this.pendingRequests,
    required this.linkedParents,
    this.isResponding = false,
  });

  final List<ParentLinkRequestModel> pendingRequests;
  final List<LinkedParentModel> linkedParents;
  final bool isResponding;

  @override
  List<Object?> get props => [pendingRequests, linkedParents, isResponding];

  FamilyLinkSuccess copyWith({
    List<ParentLinkRequestModel>? pendingRequests,
    List<LinkedParentModel>? linkedParents,
    bool? isResponding,
  }) {
    return FamilyLinkSuccess(
      pendingRequests: pendingRequests ?? this.pendingRequests,
      linkedParents: linkedParents ?? this.linkedParents,
      isResponding: isResponding ?? this.isResponding,
    );
  }
}

class FamilyLinkFailure extends FamilyLinkState {
  const FamilyLinkFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
