import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
    on<ForgotPasswordOTPSubmitted>(_onOTPSubmitted);
    on<ForgotPasswordOTPResent>(_onOTPResent);
  }

  final AuthRepository _authRepository;

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordInProgress());
    try {
      await _authRepository.resetPasswordRequest(
        email: event.email,
      );
      emit(ForgotPasswordOTPSent());
    } on DioException catch (e) {
      emit(ForgotPasswordFailure(_extractError(e)));
    }
  }

  Future<void> _onOTPSubmitted(
    ForgotPasswordOTPSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordInProgress());
    try {
      await _authRepository.resetPassword(
        email: event.email,
        otp: event.otp,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );
      emit(ForgotPasswordSuccess());
    } on DioException catch (e) {
      emit(ForgotPasswordFailure(_extractError(e)));
    }
  }

  Future<void> _onOTPResent(
    ForgotPasswordOTPResent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordInProgress());
    try {
      await _authRepository.resetPasswordRequest(
        email: event.email,
      );
      emit(ForgotPasswordOTPSent());
    } on DioException catch (e) {
      emit(ForgotPasswordFailure(_extractError(e)));
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
