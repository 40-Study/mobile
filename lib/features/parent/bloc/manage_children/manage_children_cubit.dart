import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/data/error_handler.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/parent/bloc/manage_children/manage_children_state.dart';

class ManageChildrenCubit extends Cubit<ManageChildrenState> {
  ManageChildrenCubit(this._authRepository)
      : super(const ManageChildrenInitial());

  final AuthRepository _authRepository;

  Future<void> loadChildren() async {
    emit(const ManageChildrenLoading());

    try {
      final children = await _authRepository.getChildren();
      emit(ManageChildrenSuccess(children));
    } on DioException catch (e) {
      emit(ManageChildrenFailure(AuthErrorHandler.extractMessage(e)));
    } catch (e) {
      emit(ManageChildrenFailure('Lỗi: $e'));
    }
  }

  Future<void> refresh() => loadChildren();
}
