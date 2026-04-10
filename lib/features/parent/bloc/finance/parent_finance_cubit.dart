import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/finance/parent_finance_state.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';

class ParentFinanceCubit extends Cubit<ParentFinanceState> {
  ParentFinanceCubit({
    required ParentRepository repository,
  })  : _repository = repository,
        super(const ParentFinanceInitial());

  final ParentRepository _repository;

  Future<void> loadFinance({String? childId}) async {
    emit(const ParentFinanceLoading());

    try {
      final financeOverview = await _repository.getFinanceOverview(childId: childId);

      emit(ParentFinanceLoaded(
        financeOverview: financeOverview,
        selectedChildId: childId,
      ));
    } catch (e) {
      emit(ParentFinanceFailure(message: e.toString()));
    }
  }

  Future<void> refresh({String? childId}) async {
    final currentChildId = state is ParentFinanceLoaded
        ? (state as ParentFinanceLoaded).selectedChildId
        : childId;

    try {
      final financeOverview = await _repository.getFinanceOverview(childId: currentChildId);

      emit(ParentFinanceLoaded(
        financeOverview: financeOverview,
        selectedChildId: currentChildId,
      ));
    } catch (e) {
      emit(ParentFinanceFailure(message: e.toString()));
    }
  }

  void selectChild(String? childId) {
    if (state is ParentFinanceLoaded) {
      loadFinance(childId: childId);
    }
  }
}
