import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(RegisterInitial()) {
    on<RegisterRolesRequested>(_onRolesRequested);
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterOTPSubmitted>(_onOTPSubmitted);
    on<RegisterOTPResent>(_onOTPResent);
  }

  final AuthRepository _authRepository;

  static const _fallbackRoles = [
    RoleModel(id: 'STUDENT', name: 'STUDENT'),
    RoleModel(id: 'TEACHER', name: 'TEACHER'),
    RoleModel(id: 'PARENT', name: 'PARENT'),
    RoleModel(id: 'ORG_OWNER', name: 'ORG_OWNER'),
  ];

  Future<void> _onRolesRequested(
    RegisterRolesRequested event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterInProgress());

    try {
      final roles = await _authRepository.getSystemRoles();
      emit(RegisterRolesLoaded(roles.isNotEmpty ? roles : _fallbackRoles));
    } on DioException {
      emit(const RegisterRolesLoaded(_fallbackRoles));
    }
  }

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
        roleIds: event.roleIds,
      );
      emit(RegisterOTPSent());
    } on DioException catch (e) {
      emit(RegisterFailure(_extractError(e)));
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
      emit(RegisterFailure(_extractError(e)));
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
        roleIds: event.roleIds,
      );
      emit(RegisterOTPSent());
    } on DioException catch (e) {
      emit(RegisterFailure(_extractError(e)));
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => e.toString()).join(', ');
      }
      return (data['message'] ?? data['error'] ?? '') as String;
    }
    return e.message ?? 'Đã có lỗi xảy ra';
  }
}
