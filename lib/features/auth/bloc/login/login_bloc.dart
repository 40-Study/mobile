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

  // ignore: unused_field
  final AuthRepository _authRepository;
  // ignore: unused_field
  final DeviceInfoHelper _deviceInfoHelper;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());

    // TODO: Bật lại khi test API
    // try {
    //   final deviceInfo =
    //       await _deviceInfoHelper.getDeviceInfo();
    //   final response = await _authRepository.login(
    //     email: event.email,
    //     password: event.password,
    //     deviceInfo: deviceInfo,
    //   );
    //   _handleAuthResponse(response, emit);
    // } on DioException catch (e) {
    //   emit(LoginFailure(_extractError(e)));
    // }

    await Future<void>.delayed(
      const Duration(milliseconds: 800),
    );

    // Giả lập: login -> cần chọn role
    emit(LoginNeedRole(
      sessionToken: 'fake-session-token',
      roles: const [
        RoleModel(id: 'role-1', name: 'STUDENT'),
        RoleModel(id: 'role-2', name: 'TEACHER'),
      ],
    ));
  }

  Future<void> _onRoleSelected(
    LoginRoleSelected event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());

    // TODO: Bật lại khi test API
    // try {
    //   final response =
    //       await _authRepository.selectProfile(
    //     sessionToken: event.sessionToken,
    //     systemRoleId: event.systemRoleId,
    //   );
    //   _handleAuthResponse(response, emit);
    // } on DioException catch (e) {
    //   emit(LoginFailure(_extractError(e)));
    // }

    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

    // Giả lập: chọn role -> cần chọn org
    emit(LoginNeedOrg(
      sessionToken: event.sessionToken,
      organizations: const [
        OrganizationModel(
          id: 'org-1',
          name: 'Trường THPT ABC',
        ),
        OrganizationModel(
          id: 'org-2',
          name: 'Trung tâm XYZ',
        ),
      ],
      activeRole: RoleModel(
        id: event.systemRoleId,
        name: 'STUDENT',
      ),
    ));
  }

  Future<void> _onOrgSelected(
    LoginOrgSelected event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());

    // TODO: Bật lại khi test API
    // try {
    //   final response =
    //       await _authRepository.selectOrg(
    //     sessionToken: event.sessionToken,
    //     organizationId: event.organizationId,
    //   );
    //   _handleAuthResponse(response, emit);
    // } on DioException catch (e) {
    //   emit(LoginFailure(_extractError(e)));
    // }

    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

    // Giả lập: chọn org -> login thành công
    emit(LoginSuccess(AuthResponse(
      completed: true,
      accessToken: 'fake-access-token',
      refreshToken: 'fake-refresh-token',
      user: const UserModel(
        id: 'user-1',
        username: 'testuser',
        email: 'test@example.com',
      ),
    )));
  }

  // ignore: unused_element
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

  // ignore: unused_element
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
