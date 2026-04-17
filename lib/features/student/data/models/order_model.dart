import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'order_number') String? orderNumber,
    @Default('pending') String status,
    @Default(0) double total,
    @JsonKey(name: 'discount_amount') @Default(0) double discountAmount,
    @JsonKey(name: 'final_amount') @Default(0) double finalAmount,
    @JsonKey(name: 'coupon_code') String? couponCode,
    String? note,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_url') String? paymentUrl,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'expires_at') String? expiresAt,
    @Default([]) List<OrderItemModel> items,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}

@freezed
abstract class OrderItemModel with _$OrderItemModel {
  const factory OrderItemModel({
    required String id,
    @JsonKey(name: 'course_id') required String courseId,
    @JsonKey(name: 'course_title') String? courseTitle,
    @JsonKey(name: 'course_thumbnail') String? courseThumbnail,
    @Default(0) double price,
    @JsonKey(name: 'discount_price') double? discountPrice,
  }) = _OrderItemModel;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
}
