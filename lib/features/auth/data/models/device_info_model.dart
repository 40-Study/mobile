import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_info_model.freezed.dart';
part 'device_info_model.g.dart';

@freezed
abstract class DeviceInfoModel with _$DeviceInfoModel {
  const factory DeviceInfoModel({
    @JsonKey(name: 'device_id') required String deviceId,
    @JsonKey(name: 'device_name') required String deviceName,
    required String os,
    @JsonKey(name: 'app_version') String? appVersion,
    @JsonKey(name: 'user_agent') String? userAgent,
  }) = _DeviceInfoModel;

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoModelFromJson(json);
}
