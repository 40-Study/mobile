import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc
    extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterOTPSubmitted>(_onOTPSubmitted);
    on<RegisterOTPResent>(_onOTPResent);
  }

  // ignore: unused_field
  final AuthRepository _authRepository;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterInProgress());

    // TODO: Bật lại khi test API
    // try {
    //   await _authRepository.registerRequest(
    //     email: event.email,
    //     password: event.password,
    //     confirmPassword: event.confirmPassword,
    //     userName: event.userName,
    //     fullName: event.fullName,
    //     roleIds: event.roleIds,
    //   );
    //   emit(RegisterOTPSent());
    // } on DioException catch (e) {
    //   emit(RegisterFailure(_extractError(e)));
    // }

    await Future<void>.delayed(
      const Duration(milliseconds: 800),
    );
    emit(RegisterOTPSent());
  }

  Future<void> _onOTPSubmitted(
    RegisterOTPSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterInProgress());

    // TODO: Bật lại khi test API
    // try {
    //   await _authRepository.registerVerify(
    //     email: event.email,
    //     otp: event.otp,
    //   );
    //   emit(RegisterSuccess());
    // } on DioException catch (e) {
    //   emit(RegisterFailure(_extractError(e)));
    // }

    await Future<void>.delayed(
      const Duration(milliseconds: 800),
    );
    emit(RegisterSuccess());
  }

  Future<void> _onOTPResent(
    RegisterOTPResent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterInProgress());

    // TODO: Bật lại khi test API
    // try {
    //   await _authRepository.registerRequest(
    //     email: event.email,
    //     password: event.password,
    //     confirmPassword: event.confirmPassword,
    //     userName: event.userName,
    //     fullName: event.fullName,
    //     roleIds: event.roleIds,
    //   );
    //   emit(RegisterOTPSent());
    // } on DioException catch (e) {
    //   emit(RegisterFailure(_extractError(e)));
    // }

    await Future<void>.delayed(
      const Duration(milliseconds: 800),
    );
    emit(RegisterOTPSent());
  }

  // ignore: unused_element
  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors
            .map((e) => e.toString())
            .join(', ');
      }
      return (data['message'] ??
          data['error'] ??
          '') as String;
    }
    return e.message ?? 'Đã có lỗi xảy ra';
  }
}
