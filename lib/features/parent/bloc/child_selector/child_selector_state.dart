import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/parent/data/models/models.dart';

part 'child_selector_state.freezed.dart';

@freezed
abstract class ChildSelectorState with _$ChildSelectorState {
  const factory ChildSelectorState({
    @Default([]) List<ChildModel> children,
    ChildModel? selectedChild,
  }) = _ChildSelectorState;
}
