import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/data/device_info_helper.dart';
import 'package:study/features/auth/data/error_handler.dart';
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
  }

  final AuthRepository _authRepository;
  final DeviceInfoHelper _deviceInfoHelper;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());

    try {
      final deviceInfo = await _deviceInfoHelper.getDeviceInfo();
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
        deviceInfo: deviceInfo,
      );

      // Theo API DOCS, login có 2 trường hợp:
      // 1. completed=true: login thành công với 1 role
      // 2. completed=false: cần chọn role (có session_token + roles[])

      if (response.completed && response.accessToken != null) {
        // Case 1: Login thành công (1 role)
        emit(LoginSuccess(AuthResponse(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          user: response.user,
          activeRole: response.activeRole,
          entryContext: response.entryContext,
          currentDevice: response.currentDevice,
        )));
      } else if (response.sessionToken != null) {
        // Case 2: Cần chọn role
        if (response.roles.isEmpty) {
          // Không có role nào - cần đăng ký role mới
          emit(LoginNeedsRoleRegistration(
            sessionToken: response.sessionToken!,
            user: response.user,
          ));
        } else {
          // Có nhiều roles - cần chọn 1
          emit(LoginNeedsRoleSelection(
            sessionToken: response.sessionToken!,
            roles: response.roles,
            requiresOrgSelection: response.requiresOrgSelection,
          ));
        }
      } else {
        emit(const LoginFailure('Có lỗi xảy ra khi đăng nhập'));
      }
    } on DioException catch (e) {
      emit(LoginFailure(AuthErrorHandler.extractMessage(e)));
    } catch (e) {
      emit(LoginFailure('Có lỗi xảy ra: $e'));
    }
  }

  Future<void> _onRoleSelected(
    LoginRoleSelected event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());

    try {
      final response = await _authRepository.selectRole(
        sessionToken: event.sessionToken,
        roleId: event.roleId,
        roleType: event.roleType,
        organizationId: event.organizationId,
      );
      emit(LoginSuccess(response));
    } on DioException catch (e) {
      emit(LoginFailure(AuthErrorHandler.extractMessage(e)));
    } catch (e) {
      emit(LoginFailure('Có lỗi xảy ra: $e'));
    }
  }
}
