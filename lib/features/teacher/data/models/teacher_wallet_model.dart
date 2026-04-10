import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_wallet_model.freezed.dart';
part 'teacher_wallet_model.g.dart';

/// Teacher wallet model theo API DOCS - GET /wallet/teacher/me
/// Response: TeacherWalletResponse
@freezed
abstract class TeacherWalletModel with _$TeacherWalletModel {
  const factory TeacherWalletModel({
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'total_earnings') @Default('0') String totalEarnings,
    @JsonKey(name: 'total_paid_out') @Default('0') String totalPaidOut,
    @JsonKey(name: 'available_balance') @Default('0') String availableBalance,
    @Default('VND') String currency,
    @JsonKey(name: 'order_count') @Default(0) int orderCount,
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'bank_account_number') String? bankAccountNumber,
    @JsonKey(name: 'bank_account_name') String? bankAccountName,
    // Legacy fields for backward compatibility
    @Default(0) double balance,
    @JsonKey(name: 'monthly_income') @Default(0) double monthlyIncome,
    @JsonKey(name: 'income_change_percent') @Default(0) double incomeChangePercent,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
  }) = _TeacherWalletModel;

  factory TeacherWalletModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherWalletModelFromJson(json);
}

extension TeacherWalletModelX on TeacherWalletModel {
  /// Get available balance as double (prefer API field, fallback to legacy)
  double get availableBalanceValue {
    final parsed = double.tryParse(availableBalance);
    if (parsed != null && parsed > 0) return parsed;
    return balance;
  }

  /// Get total earnings as double
  double get totalEarningsValue => double.tryParse(totalEarnings) ?? 0;

  /// Get total paid out as double
  double get totalPaidOutValue => double.tryParse(totalPaidOut) ?? 0;

  /// Check if bank info is set up
  bool get hasBankInfo =>
      bankName != null && bankAccountNumber != null && bankAccountName != null;

  /// Display bank info
  String get displayBankInfo {
    if (!hasBankInfo) return 'Chưa thiết lập';
    return '$bankName - $bankAccountNumber';
  }
}
