import 'package:freezed_annotation/freezed_annotation.dart';

part 'linked_account_model.freezed.dart';
part 'linked_account_model.g.dart';

/// Model cho tài khoản OAuth đã liên kết
@freezed
abstract class LinkedAccountModel with _$LinkedAccountModel {
  const factory LinkedAccountModel({
    required String provider,
    String? email,
    @JsonKey(name: 'connected_at') String? connectedAt,
  }) = _LinkedAccountModel;

  factory LinkedAccountModel.fromJson(Map<String, dynamic> json) =>
      _$LinkedAccountModelFromJson(json);
}
