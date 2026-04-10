import 'package:equatable/equatable.dart';
import 'package:study/features/parent/data/models/models.dart';

sealed class ParentFinanceState extends Equatable {
  const ParentFinanceState();

  @override
  List<Object?> get props => [];
}

final class ParentFinanceInitial extends ParentFinanceState {
  const ParentFinanceInitial();
}

final class ParentFinanceLoading extends ParentFinanceState {
  const ParentFinanceLoading();
}

final class ParentFinanceLoaded extends ParentFinanceState {
  const ParentFinanceLoaded({
    required this.financeOverview,
    this.selectedChildId,
  });

  final ParentFinanceOverviewModel financeOverview;
  final String? selectedChildId;

  @override
  List<Object?> get props => [financeOverview, selectedChildId];

  ParentFinanceLoaded copyWith({
    ParentFinanceOverviewModel? financeOverview,
    String? selectedChildId,
  }) {
    return ParentFinanceLoaded(
      financeOverview: financeOverview ?? this.financeOverview,
      selectedChildId: selectedChildId ?? this.selectedChildId,
    );
  }
}

final class ParentFinanceFailure extends ParentFinanceState {
  const ParentFinanceFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

// Payment states
sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

final class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

final class PaymentSuccess extends PaymentState {
  const PaymentSuccess({required this.transactionId});

  final String transactionId;

  @override
  List<Object?> get props => [transactionId];
}

final class PaymentFailure extends PaymentState {
  const PaymentFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
