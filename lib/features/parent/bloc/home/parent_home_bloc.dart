import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/features/parent/bloc/home/parent_home_event.dart';
import 'package:study/features/parent/bloc/home/parent_home_state.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';

class ParentHomeBloc extends Bloc<ParentHomeEvent, ParentHomeState> {
  ParentHomeBloc(this._repository) : super(const ParentHomeInitial()) {
    on<ParentHomeStarted>(_onStarted);
    on<ParentHomeChildSelected>(_onChildSelected);
    on<ParentHomeRefreshed>(_onRefreshed);
  }

  final ParentHomeRepository _repository;
  String? _selectedChildId;

  Future<void> _onStarted(
    ParentHomeStarted event,
    Emitter<ParentHomeState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onChildSelected(
    ParentHomeChildSelected event,
    Emitter<ParentHomeState> emit,
  ) async {
    _selectedChildId = event.childId;
    await _load(emit);
  }

  Future<void> _onRefreshed(
    ParentHomeRefreshed event,
    Emitter<ParentHomeState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<ParentHomeState> emit) async {
    emit(const ParentHomeLoading());
    try {
      final data = await _repository.getHomeDashboard(
        childId: _selectedChildId,
      );
      emit(ParentHomeSuccess(data: data, selectedChildId: _selectedChildId));
    } catch (e) {
      emit(ParentHomeFailure(_formatErrorMessage(e)));
    }
  }

  /// Chuyển đổi lỗi thành thông báo thân thiện bằng tiếng Việt trên giao diện
  String _formatErrorMessage(Object error) {
    if (error is TimeoutException) {
      return 'Kết nối quá thời gian. Vui lòng kiểm tra lại mạng và thử lại.';
    }
    if (error is Failure) {
      return error.message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('kết nối') ||
        text.contains('Failed host lookup')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.';
    }
    if (text.contains('401') || text.contains('Unauthorized')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }
    return 'Không thể tải dữ liệu. Vui lòng bấm "Thử lại".';
  }
}
