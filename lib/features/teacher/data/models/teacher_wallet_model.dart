import 'package:freezed_annotation/freezed_annotation.dart';

part 'teacher_wallet_model.freezed.dart';
part 'teacher_wallet_model.g.dart';

@freezed
abstract class TeacherWalletModel with _$TeacherWalletModel {
  const factory TeacherWalletModel({
    @Default(0) double balance,
    @JsonKey(name: 'monthly_income') @Default(0) double monthlyIncome,
    @JsonKey(name: 'income_change_percent') @Default(0) double incomeChangePercent,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
  }) = _TeacherWalletModel;

  factory TeacherWalletModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherWalletModelFromJson(json);
}
