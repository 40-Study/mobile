import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/student/data/models/models.dart';

part 'contribution_state.freezed.dart';

@freezed
sealed class ContributionState with _$ContributionState {
  const factory ContributionState.initial() = ContributionInitial;
  const factory ContributionState.loading() = ContributionLoading;
  const factory ContributionState.success(List<ContributionModel> contributions) = ContributionSuccess;
  const factory ContributionState.failure(String message) = ContributionFailure;
}
