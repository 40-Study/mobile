import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/auth/data/error_handler.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

part 'select_role_state.dart';

class SelectRoleCubit extends Cubit<SelectRoleState> {
  SelectRoleCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SelectRoleInitial());

  final AuthRepository _authRepository;

  Future<void> loadRoles() async {
    emit(const SelectRoleLoading());

    try {
      final allRoles = await _authRepository.getSystemRoles();

      // Filter only allowed roles using RoleUtils
      final filteredRoles = allRoles
          .where((role) => RoleUtils.isAllowedRole(role.name))
          .toList();

      // Sort roles using RoleUtils
      filteredRoles.sort(
        (a, b) => RoleUtils.getSortOrder(a.name)
            .compareTo(RoleUtils.getSortOrder(b.name)),
      );

      emit(SelectRoleLoaded(roles: filteredRoles));
    } on DioException catch (e) {
      emit(SelectRoleFailure(message: AuthErrorHandler.extractMessage(e)));
    }
  }
}
