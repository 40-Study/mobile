import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/security/security_state.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

class SecurityCubit extends Cubit<SecurityState> {
  SecurityCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SecurityInitial());

  final AuthRepository _authRepository;

  Future<void> loadDevices() async {
    emit(const SecurityLoading());
    try {
      final devices = await _authRepository.getDevices();
      emit(SecurityLoaded(devices: devices));
    } catch (e) {
      emit(SecurityFailure(message: _parseError(e)));
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required DeviceInfoModel deviceInfo,
    bool revokeOthers = false,
  }) async {
    final currentDevices = _getCurrentDevices();
    emit(SecurityChangingPassword(devices: currentDevices));

    try {
      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        deviceInfo: deviceInfo,
        revokeOthers: revokeOthers,
      );
      emit(SecurityPasswordChanged(devices: currentDevices));
    } catch (e) {
      emit(SecurityFailure(message: _parseError(e), devices: currentDevices));
    }
  }

  Future<void> logoutAllDevices() async {
    final currentDevices = _getCurrentDevices();
    emit(SecurityLoggingOutAll(devices: currentDevices));

    try {
      await _authRepository.logoutAll();
      emit(const SecurityLoggedOutAll());
    } catch (e) {
      emit(SecurityFailure(message: _parseError(e), devices: currentDevices));
    }
  }

  List<DeviceModel> _getCurrentDevices() {
    return switch (state) {
      SecurityLoaded(:final devices) => devices,
      SecurityChangingPassword(:final devices) => devices,
      SecurityPasswordChanged(:final devices) => devices,
      SecurityLoggingOutAll(:final devices) => devices,
      SecurityFailure(:final devices) => devices,
      _ => [],
    };
  }

  String _parseError(dynamic error) {
    final message = error.toString();
    if (message.contains('401')) {
      return 'Phiên đăng nhập hết hạn';
    }
    if (message.contains('400')) {
      return 'Mật khẩu cũ không đúng';
    }
    if (message.contains('network')) {
      return 'Lỗi kết nối mạng';
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
