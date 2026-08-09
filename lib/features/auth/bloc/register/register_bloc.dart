import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/data/error_handler.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterOTPSubmitted>(_onOTPSubmitted);
    on<RegisterOTPResent>(_onOTPResent);
  }

  final AuthRepository _authRepository;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterInProgress());

    try {
      await _authRepository.registerRequest(
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
        userName: event.userName,
        fullName: event.fullName,
      );
      emit(RegisterOTPSent());
    } on DioException catch (e) {
      emit(RegisterFailure(AuthErrorHandler.extractMessage(e)));
    }
  }

  Future<void> _onOTPSubmitted(
    RegisterOTPSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterInProgress());

    try {
      await _authRepository.registerVerify(email: event.email, otp: event.otp);
      emit(RegisterSuccess());
    } on DioException catch (e) {
      emit(RegisterFailure(AuthErrorHandler.extractMessage(e)));
    }
  }

  Future<void> _onOTPResent(
    RegisterOTPResent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterInProgress());

    try {
      await _authRepository.registerRequest(
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
        userName: event.userName,
        fullName: event.fullName,
      );
      emit(RegisterOTPSent());
    } on DioException catch (e) {
      emit(RegisterFailure(AuthErrorHandler.extractMessage(e)));
    }
  }
}
