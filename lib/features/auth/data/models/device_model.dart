import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_model.freezed.dart';
part 'device_model.g.dart';

/// Thông tin thiết bị từ server (login response / danh sách devices).
@freezed
abstract class DeviceModel with _$DeviceModel {
  const factory DeviceModel({
    @JsonKey(name: 'device_id') required String deviceId,
    @JsonKey(name: 'device_name') required String deviceName,
    @JsonKey(name: 'user_agent') String? userAgent,
    @JsonKey(name: 'logged_in_at') String? loggedInAt,
    @JsonKey(name: 'is_current') @Default(false) bool isCurrent,
  }) = _DeviceModel;

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);
}
