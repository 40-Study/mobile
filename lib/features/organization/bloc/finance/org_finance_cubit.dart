import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/organization/data/models/models.dart';
import 'package:study/features/organization/data/repository/organization_repository.dart';

part 'org_finance_state.dart';

class OrgFinanceCubit extends Cubit<OrgFinanceState> {
  OrgFinanceCubit({required OrganizationRepository repository})
      : _repository = repository,
        super(const OrgFinanceInitial());

  final OrganizationRepository _repository;

  Future<void> loadFinance() async {
    emit(const OrgFinanceLoading());

    try {
      final results = await Future.wait([
        _repository.getFinanceOverview(),
        _repository.getTransactions(),
      ]);

      emit(OrgFinanceLoaded(
        overview: results[0] as OrgFinanceModel,
        transactions: results[1] as List<OrgTransactionModel>,
      ));
    } catch (e) {
      emit(OrgFinanceFailure(message: e.toString()));
    }
  }

  Future<void> loadTransactions({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final currentState = state;
    if (currentState is! OrgFinanceLoaded) return;

    try {
      final transactions = await _repository.getTransactions(
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      emit(OrgFinanceLoaded(
        overview: currentState.overview,
        transactions: transactions,
        filterType: type,
      ));
    } catch (e) {
      // Keep current state on filter error
    }
  }

  Future<void> requestPayout(double amount) async {
    try {
      await _repository.requestPayout(amount);
      await loadFinance();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refresh() async {
    await loadFinance();
  }
}
