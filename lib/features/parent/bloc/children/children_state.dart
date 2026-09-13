import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/parent/data/models/models.dart';

part 'children_state.freezed.dart';

@freezed
sealed class ChildrenState with _$ChildrenState {
  const factory ChildrenState.initial() = ChildrenInitial;
  const factory ChildrenState.loading() = ChildrenLoading;
  const factory ChildrenState.success(List<ChildModel> children) = ChildrenSuccess;
  const factory ChildrenState.failure(String message) = ChildrenFailure;
}
