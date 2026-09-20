import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/children/children_event.dart';
import 'package:study/features/parent/bloc/children/children_state.dart';
import 'package:study/features/parent/repository/parent_repository.dart';

class ChildrenBloc extends Bloc<ChildrenEvent, ChildrenState> {
  ChildrenBloc(this._repository) : super(const ChildrenInitial()) {
    on<ChildrenStarted>(_onStarted);
    on<ChildrenRefreshed>(_onRefreshed);
  }

  final ParentRepository _repository;

  Future<void> _onStarted(
    ChildrenStarted event,
    Emitter<ChildrenState> emit,
  ) async {
    emit(const ChildrenLoading());
    await _loadChildren(emit);
  }

  Future<void> _onRefreshed(
    ChildrenRefreshed event,
    Emitter<ChildrenState> emit,
  ) async {
    await _loadChildren(emit);
  }

  Future<void> _loadChildren(Emitter<ChildrenState> emit) async {
    final result = await _repository.getChildren();
    result.when(
      success: (children) => emit(ChildrenSuccess(children)),
      failure: (error) => emit(ChildrenFailure(error.message ?? 'Loi khong xac dinh')),
    );
  }
}
