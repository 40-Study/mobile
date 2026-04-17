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
      final results = await Future.wait([
        _authRepository.getDevices(),
        _authRepository.getLinkedAccounts(),
      ]);
      final devices = results[0] as List<DeviceModel>;
      final linkedAccounts = results[1] as List<LinkedAccountModel>;
      emit(SecurityLoaded(devices: devices, linkedAccounts: linkedAccounts));
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
    final currentLinkedAccounts = _getCurrentLinkedAccounts();
    emit(SecurityChangingPassword(
      devices: currentDevices,
      linkedAccounts: currentLinkedAccounts,
    ));

    try {
      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
        deviceInfo: deviceInfo,
        revokeOthers: revokeOthers,
      );
      emit(SecurityPasswordChanged(
        devices: currentDevices,
        linkedAccounts: currentLinkedAccounts,
      ));
    } catch (e) {
      emit(SecurityFailure(
        message: _parseError(e),
        devices: currentDevices,
        linkedAccounts: currentLinkedAccounts,
      ));
    }
  }

  Future<void> unlinkAccount(String provider) async {
    final currentDevices = _getCurrentDevices();
    final currentLinkedAccounts = _getCurrentLinkedAccounts();
    emit(SecurityUnlinkingAccount(
      devices: currentDevices,
      linkedAccounts: currentLinkedAccounts,
      provider: provider,
    ));

    try {
      await _authRepository.unlinkAccount(provider: provider);
      final updatedAccounts = currentLinkedAccounts
          .where((a) => a.provider != provider)
          .toList();
      emit(SecurityAccountUnlinked(
        devices: currentDevices,
        linkedAccounts: updatedAccounts,
        provider: provider,
      ));
    } catch (e) {
      emit(SecurityFailure(
        message: _parseError(e),
        devices: currentDevices,
        linkedAccounts: currentLinkedAccounts,
      ));
    }
  }

  Future<void> logoutAllDevices() async {
    final currentDevices = _getCurrentDevices();
    final currentLinkedAccounts = _getCurrentLinkedAccounts();
    emit(SecurityLoggingOutAll(
      devices: currentDevices,
      linkedAccounts: currentLinkedAccounts,
    ));

    try {
      await _authRepository.logoutAll();
      emit(const SecurityLoggedOutAll());
    } catch (e) {
      emit(SecurityFailure(
        message: _parseError(e),
        devices: currentDevices,
        linkedAccounts: currentLinkedAccounts,
      ));
    }
  }

  List<DeviceModel> _getCurrentDevices() {
    return switch (state) {
      SecurityLoaded(:final devices) => devices,
      SecurityChangingPassword(:final devices) => devices,
      SecurityPasswordChanged(:final devices) => devices,
      SecurityLoggingOutAll(:final devices) => devices,
      SecurityUnlinkingAccount(:final devices) => devices,
      SecurityAccountUnlinked(:final devices) => devices,
      SecurityFailure(:final devices) => devices,
      _ => [],
    };
  }

  List<LinkedAccountModel> _getCurrentLinkedAccounts() {
    return switch (state) {
      SecurityLoaded(:final linkedAccounts) => linkedAccounts,
      SecurityChangingPassword(:final linkedAccounts) => linkedAccounts,
      SecurityPasswordChanged(:final linkedAccounts) => linkedAccounts,
      SecurityLoggingOutAll(:final linkedAccounts) => linkedAccounts,
      SecurityUnlinkingAccount(:final linkedAccounts) => linkedAccounts,
      SecurityAccountUnlinked(:final linkedAccounts) => linkedAccounts,
      SecurityFailure(:final linkedAccounts) => linkedAccounts,
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
