import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_finance_model.freezed.dart';
part 'parent_finance_model.g.dart';

@freezed
abstract class ParentFinanceOverviewModel with _$ParentFinanceOverviewModel {
  const factory ParentFinanceOverviewModel({
    @JsonKey(name: 'total_tuition') @Default(0.0) double totalTuition,
    @JsonKey(name: 'paid_amount') @Default(0.0) double paidAmount,
    @JsonKey(name: 'remaining_amount') @Default(0.0) double remainingAmount,
    @JsonKey(name: 'next_due_date') String? nextDueDate,
    @JsonKey(name: 'payment_history') @Default([]) List<PaymentHistoryModel> paymentHistory,
    @JsonKey(name: 'pending_payments') @Default([]) List<PendingPaymentModel> pendingPayments,
  }) = _ParentFinanceOverviewModel;

  factory ParentFinanceOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$ParentFinanceOverviewModelFromJson(json);
}

@freezed
abstract class PaymentHistoryModel with _$PaymentHistoryModel {
  const factory PaymentHistoryModel({
    required String id,
    required double amount,
    @JsonKey(name: 'payment_date') required String paymentDate,
    required PaymentStatus status,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'child_name') String? childName,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'transaction_id') String? transactionId,
    String? description,
  }) = _PaymentHistoryModel;

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryModelFromJson(json);
}

@JsonEnum()
enum PaymentStatus {
  @JsonValue('completed')
  completed,
  @JsonValue('pending')
  pending,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}

@freezed
abstract class PendingPaymentModel with _$PendingPaymentModel {
  const factory PendingPaymentModel({
    required String id,
    required double amount,
    @JsonKey(name: 'due_date') required String dueDate,
    @JsonKey(name: 'child_name') String? childName,
    @JsonKey(name: 'course_name') String? courseName,
    String? description,
    @JsonKey(name: 'is_overdue') @Default(false) bool isOverdue,
  }) = _PendingPaymentModel;

  factory PendingPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PendingPaymentModelFromJson(json);
}

@freezed
abstract class PaymentMethodModel with _$PaymentMethodModel {
  const factory PaymentMethodModel({
    required String id,
    required String name,
    required PaymentMethodType type,
    @JsonKey(name: 'account_number') String? accountNumber,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
    String? icon,
  }) = _PaymentMethodModel;

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);
}

@JsonEnum()
enum PaymentMethodType {
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('credit_card')
  creditCard,
  @JsonValue('e_wallet')
  eWallet,
  @JsonValue('cash')
  cash,
}

@freezed
abstract class CreatePaymentRequest with _$CreatePaymentRequest {
  const factory CreatePaymentRequest({
    @JsonKey(name: 'pending_payment_id') required String pendingPaymentId,
    required double amount,
    @JsonKey(name: 'payment_method_id') required String paymentMethodId,
  }) = _CreatePaymentRequest;

  factory CreatePaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentRequestFromJson(json);
}
