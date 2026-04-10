part of 'org_finance_cubit.dart';

@immutable
sealed class OrgFinanceState extends Equatable {
  const OrgFinanceState();

  @override
  List<Object?> get props => [];
}

final class OrgFinanceInitial extends OrgFinanceState {
  const OrgFinanceInitial();
}

final class OrgFinanceLoading extends OrgFinanceState {
  const OrgFinanceLoading();
}

final class OrgFinanceLoaded extends OrgFinanceState {
  const OrgFinanceLoaded({
    required this.overview,
    required this.transactions,
    this.filterType,
  });

  final OrgFinanceModel overview;
  final List<OrgTransactionModel> transactions;
  final String? filterType;

  @override
  List<Object?> get props => [overview, transactions, filterType];
}

final class OrgFinanceFailure extends OrgFinanceState {
  const OrgFinanceFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
