import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

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

  /// Generate device info from current platform.
  factory DeviceInfoModel.generate() {
    String os;
    String deviceName;

    if (kIsWeb) {
      os = 'Web';
      deviceName = 'Web Browser';
    } else if (Platform.isIOS) {
      os = 'iOS';
      deviceName = 'iPhone';
    } else if (Platform.isAndroid) {
      os = 'Android';
      deviceName = 'Android Device';
    } else if (Platform.isMacOS) {
      os = 'macOS';
      deviceName = 'Mac';
    } else if (Platform.isWindows) {
      os = 'Windows';
      deviceName = 'Windows PC';
    } else if (Platform.isLinux) {
      os = 'Linux';
      deviceName = 'Linux PC';
    } else {
      os = 'Unknown';
      deviceName = 'Unknown Device';
    }

    return DeviceInfoModel(
      deviceId: const Uuid().v4(),
      deviceName: deviceName,
      os: os,
      appVersion: '1.0.0',
    );
  }
}
