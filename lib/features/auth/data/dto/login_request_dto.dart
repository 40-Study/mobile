import 'package:study/features/auth/data/models/device_info_model.dart';

class LoginRequestDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
    required this.deviceInfo,
  });

  final String email;
  final String password;
  final DeviceInfoModel deviceInfo;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'device_info': deviceInfo.toJson(),
    };
  }
}
