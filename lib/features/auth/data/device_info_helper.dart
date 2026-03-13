import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/models/models.dart';

/// Tạo DeviceInfoModel cho login request.
/// device_id được generate 1 lần rồi lưu lại.
class DeviceInfoHelper {
  DeviceInfoHelper(this._authStorage);

  final AuthStorage _authStorage;

  Future<DeviceInfoModel> getDeviceInfo() async {
    final deviceId = await _getOrCreateDeviceId();
    final packageInfo = await PackageInfo.fromPlatform();

    return DeviceInfoModel(
      deviceId: deviceId,
      deviceName: _getDeviceName(),
      os: _getOS(),
      appVersion: packageInfo.version,
    );
  }

  Future<String> _getOrCreateDeviceId() async {
    var id = await _authStorage.getDeviceId();
    if (id == null) {
      id = _generateUUID();
      await _authStorage.saveDeviceId(id);
    }
    return id;
  }

  String _getDeviceName() {
    if (kIsWeb) return 'Web Browser';
    if (Platform.isIOS) return 'iPhone';
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown Device';
  }

  String _getOS() {
    if (kIsWeb) return 'Web';
    return '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  }

  /// UUID v4 đơn giản, không cần thêm package.
  String _generateUUID() {
    final r = DateTime.now().millisecondsSinceEpoch;
    return '${_hex(r, 8)}-${_hex(r ~/ 2, 4)}'
        '-4${_hex(r ~/ 3, 3)}'
        '-${_hex(r ~/ 4, 4)}'
        '-${_hex(r ~/ 5, 12)}';
  }

  String _hex(int value, int length) {
    return value.toRadixString(16).padLeft(length, '0').substring(0, length);
  }
}
