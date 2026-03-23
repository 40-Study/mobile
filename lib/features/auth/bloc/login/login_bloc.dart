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
  }) : _authRepository = authRepository,
       _deviceInfoHelper = deviceInfoHelper,
       super(LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
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
      emit(LoginSuccess(response));
    } on DioException catch (e) {
      emit(LoginFailure(AuthErrorHandler.extractMessage(e)));
    }
  }
}
