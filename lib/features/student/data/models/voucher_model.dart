import 'package:freezed_annotation/freezed_annotation.dart';

part 'voucher_model.freezed.dart';
part 'voucher_model.g.dart';

@freezed
abstract class VoucherModel with _$VoucherModel {
  const factory VoucherModel({
    required String id,
    required String code,
    String? name,
    String? description,
    @JsonKey(name: 'discount_type') String? discountType,
    @JsonKey(name: 'discount_value') @Default(0) double discountValue,
    @JsonKey(name: 'max_discount') double? maxDiscount,
    @JsonKey(name: 'min_order_value') double? minOrderValue,
    @JsonKey(name: 'usage_limit') int? usageLimit,
    @JsonKey(name: 'usage_count') @Default(0) int usageCount,
    @JsonKey(name: 'per_user_limit') int? perUserLimit,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_public') @Default(false) bool isPublic,
    @JsonKey(name: 'is_saved') @Default(false) bool isSaved,
    @JsonKey(name: 'applicable_courses') List<String>? applicableCourses,
    @JsonKey(name: 'applicable_categories') List<String>? applicableCategories,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _VoucherModel;

  factory VoucherModel.fromJson(Map<String, dynamic> json) =>
      _$VoucherModelFromJson(json);
}
