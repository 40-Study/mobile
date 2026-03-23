import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/account/account_state.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AccountInitial());

  final AuthRepository _authRepository;

  Future<void> loadAccount() async {
    emit(const AccountLoading());
    try {
      final user = await _authRepository.getMe();
      emit(AccountLoaded(user: user));
    } catch (e) {
      emit(AccountFailure(message: _parseError(e)));
    }
  }

  Future<void> updateAccount({
    String? username,
    String? phone,
    String? dateOfBirth,
    String? fullName,
  }) async {
    final currentUser = switch (state) {
      AccountLoaded(:final user) => user,
      AccountUpdateSuccess(:final user) => user,
      AccountFailure(:final user) => user,
      _ => null,
    };

    if (currentUser == null) return;

    emit(AccountUpdating(user: currentUser));
    try {
      final updatedUser = await _authRepository.updateMe(
        username: username,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );
      emit(AccountUpdateSuccess(user: updatedUser));
    } catch (e) {
      emit(AccountFailure(message: _parseError(e), user: currentUser));
    }
  }

  String _parseError(dynamic error) {
    final message = error.toString();
    if (message.contains('401')) {
      return 'Phiên đăng nhập hết hạn';
    }
    if (message.contains('network')) {
      return 'Lỗi kết nối mạng';
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
