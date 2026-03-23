import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/data/error_handler.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
    on<ForgotPasswordOTPVerified>(_onOTPVerified);
    on<ForgotPasswordResetSubmitted>(_onResetSubmitted);
    on<ForgotPasswordOTPResent>(_onOTPResent);
  }

  final AuthRepository _authRepository;

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordInProgress());

    try {
      await _authRepository.resetPasswordRequest(email: event.email);
      emit(ForgotPasswordOTPSent());
    } on DioException catch (e) {
      emit(ForgotPasswordFailure(AuthErrorHandler.extractMessage(e)));
    }
  }

  Future<void> _onOTPVerified(
    ForgotPasswordOTPVerified event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordInProgress());
    emit(ForgotPasswordOTPVerifiedState(email: event.email, otp: event.otp));
  }

  Future<void> _onResetSubmitted(
    ForgotPasswordResetSubmitted event,
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
      emit(ForgotPasswordFailure(AuthErrorHandler.extractMessage(e)));
    }
  }

  Future<void> _onOTPResent(
    ForgotPasswordOTPResent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordInProgress());

    try {
      await _authRepository.resetPasswordRequest(email: event.email);
      emit(ForgotPasswordOTPSent());
    } on DioException catch (e) {
      emit(ForgotPasswordFailure(AuthErrorHandler.extractMessage(e)));
    }
  }
}
