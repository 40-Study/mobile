import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:study/core/logger/app_logger.dart';
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
    AppLogger.auth('SelectRoleCubit: Loading roles...');

    try {
      final allRoles = await _authRepository.getSystemRoles();
      AppLogger.auth('SelectRoleCubit: Got ${allRoles.length} roles');

      // Filter only allowed roles using RoleUtils
      final filteredRoles = allRoles
          .where((role) => RoleUtils.isAllowedRole(role.name))
          .toList();
      AppLogger.auth(
        'SelectRoleCubit: Filtered to ${filteredRoles.length} roles',
      );

      // Sort roles using RoleUtils
      filteredRoles.sort(
        (a, b) => RoleUtils.getSortOrder(
          a.name,
        ).compareTo(RoleUtils.getSortOrder(b.name)),
      );

      emit(SelectRoleLoaded(roles: filteredRoles));
      AppLogger.auth('SelectRoleCubit: Emitted SelectRoleLoaded');
    } on DioException catch (e) {
      AppLogger.w('SelectRoleCubit: DioException', e.message);
      AppLogger.w('SelectRoleCubit: Response', e.response?.data);
      emit(SelectRoleFailure(message: AuthErrorHandler.extractMessage(e)));
    } catch (e, stack) {
      AppLogger.e('SelectRoleCubit: Unexpected error', e, stack);
      emit(SelectRoleFailure(message: 'Lỗi: $e'));
    }
  }
}
