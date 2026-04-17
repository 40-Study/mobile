import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/vouchers/vouchers_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

class VouchersCubit extends Cubit<VouchersState> {
  VouchersCubit({required StudentRepository repository})
      : _repository = repository,
        super(const VouchersInitial());

  final StudentRepository _repository;

  /// Tai danh sach voucher.
  Future<void> loadVouchers() async {
    emit(const VouchersLoading());
    try {
      final results = await Future.wait([
        _repository.getPublicVouchers(),
        _repository.getMySavedVouchers(),
      ]);

      emit(VouchersLoaded(
        publicVouchers: results[0] as List<VoucherModel>,
        savedVouchers: results[1] as List<VoucherModel>,
      ));
    } catch (e) {
      emit(VouchersError(e.toString()));
    }
  }

  /// Lam moi.
  Future<void> refresh() async {
    final currentState = state;
    try {
      final results = await Future.wait([
        _repository.getPublicVouchers(),
        _repository.getMySavedVouchers(),
      ]);

      if (currentState is VouchersLoaded) {
        emit(currentState.copyWith(
          publicVouchers: results[0] as List<VoucherModel>,
          savedVouchers: results[1] as List<VoucherModel>,
        ));
      } else {
        emit(VouchersLoaded(
          publicVouchers: results[0] as List<VoucherModel>,
          savedVouchers: results[1] as List<VoucherModel>,
        ));
      }
    } catch (e) {
      emit(VouchersError(e.toString()));
    }
  }

  /// Chuyen tab.
  void toggleSavedOnly(bool showSavedOnly) {
    final currentState = state;
    if (currentState is! VouchersLoaded) return;
    emit(currentState.copyWith(showSavedOnly: showSavedOnly));
  }

  /// Luu voucher.
  Future<void> saveVoucher(String voucherId) async {
    final currentState = state;
    if (currentState is! VouchersLoaded) return;

    try {
      await _repository.saveVoucher(voucherId);

      final voucher = currentState.publicVouchers.firstWhere(
        (v) => v.id == voucherId,
        orElse: () => throw Exception('Not found'),
      );

      final updatedSaved = [...currentState.savedVouchers, voucher.copyWith(isSaved: true)];

      emit(currentState.copyWith(savedVouchers: updatedSaved));
    } catch (e) {
      // Silent fail
    }
  }

  /// Bo luu voucher.
  Future<void> unsaveVoucher(String voucherId) async {
    final currentState = state;
    if (currentState is! VouchersLoaded) return;

    try {
      await _repository.unsaveVoucher(voucherId);

      final updatedSaved = currentState.savedVouchers
          .where((v) => v.id != voucherId)
          .toList();

      emit(currentState.copyWith(savedVouchers: updatedSaved));
    } catch (e) {
      // Silent fail
    }
  }
}
