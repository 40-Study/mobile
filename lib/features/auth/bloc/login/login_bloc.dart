import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/data/device_info_helper.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthRepository authRepository,
    required DeviceInfoHelper deviceInfoHelper,
  })  : _authRepository = authRepository,
        _deviceInfoHelper = deviceInfoHelper,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoginRoleSelected>(_onRoleSelected);
    on<LoginOrgSelected>(_onOrgSelected);
  }

  final AuthRepository _authRepository;
  final DeviceInfoHelper _deviceInfoHelper;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());
    try {
      final deviceInfo =
          await _deviceInfoHelper.getDeviceInfo();
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
        deviceInfo: deviceInfo,
      );
      _handleAuthResponse(response, emit);
    } on DioException catch (e) {
      emit(LoginFailure(_extractError(e)));
    }
  }

  Future<void> _onRoleSelected(
    LoginRoleSelected event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());
    try {
      final response = await _authRepository.selectProfile(
        sessionToken: event.sessionToken,
        systemRoleId: event.systemRoleId,
      );
      _handleAuthResponse(response, emit);
    } on DioException catch (e) {
      emit(LoginFailure(_extractError(e)));
    }
  }

  Future<void> _onOrgSelected(
    LoginOrgSelected event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());
    try {
      final response = await _authRepository.selectOrg(
        sessionToken: event.sessionToken,
        organizationId: event.organizationId,
      );
      _handleAuthResponse(response, emit);
    } on DioException catch (e) {
      emit(LoginFailure(_extractError(e)));
    }
  }

  void _handleAuthResponse(
    AuthResponse response,
    Emitter<LoginState> emit,
  ) {
    if (response.completed) {
      emit(LoginSuccess(response));
      return;
    }

    if (response.systemRoles != null &&
        response.systemRoles!.isNotEmpty) {
      emit(LoginNeedRole(
        sessionToken: response.sessionToken!,
        roles: response.systemRoles!,
      ));
      return;
    }

    if (response.requiresOrgSelection &&
        response.organizations != null) {
      emit(LoginNeedOrg(
        sessionToken: response.sessionToken!,
        organizations: response.organizations!,
        activeRole: response.activeRole,
      ));
      return;
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] ??
          data['error'] ??
          '') as String;
    }
    return e.message ?? 'Đã có lỗi xảy ra';
  }
}
