import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/children/children_selector_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';

class ChildrenSelectorCubit extends Cubit<ChildrenSelectorState> {
  ChildrenSelectorCubit({
    required ParentRepository repository,
  })  : _repository = repository,
        super(const ChildrenSelectorInitial());

  final ParentRepository _repository;

  Future<void> loadChildren() async {
    emit(const ChildrenSelectorLoading());

    try {
      final children = await _repository.getChildren();

      emit(ChildrenSelectorLoaded(
        children: children,
        selectedChild: children.isNotEmpty ? children.first : null,
      ));
    } catch (e) {
      emit(ChildrenSelectorFailure(message: e.toString()));
    }
  }

  void selectChild(ChildModel child) {
    if (state is ChildrenSelectorLoaded) {
      emit((state as ChildrenSelectorLoaded).copyWith(selectedChild: child));
    }
  }

  ChildModel? get selectedChild {
    if (state is ChildrenSelectorLoaded) {
      return (state as ChildrenSelectorLoaded).selectedChild;
    }
    return null;
  }

  List<ChildModel> get children {
    if (state is ChildrenSelectorLoaded) {
      return (state as ChildrenSelectorLoaded).children;
    }
    return [];
  }
}
