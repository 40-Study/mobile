import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_state.dart';
import 'package:study/features/parent/data/models/models.dart';

class ChildSelectorCubit extends Cubit<ChildSelectorState> {
  ChildSelectorCubit() : super(const ChildSelectorState());

  void setChildren(List<ChildModel> children) {
    emit(state.copyWith(
      children: children,
      selectedChild: children.isNotEmpty ? children.first : null,
    ));
  }

  void select(ChildModel child) {
    emit(state.copyWith(selectedChild: child));
  }

  void selectById(String childId) {
    final child = state.children.firstWhere(
      (c) => c.id == childId,
      orElse: () => state.children.first,
    );
    select(child);
  }
}
