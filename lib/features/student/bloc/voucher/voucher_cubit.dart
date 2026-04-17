import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'voucher_state.dart';

class VoucherCubit extends Cubit<VoucherState> {
  VoucherCubit({required StudentRepository repository})
      : _repository = repository,
        super(const VoucherInitial());

  final StudentRepository _repository;

  Future<void> loadVouchers() async {
    emit(const VoucherLoading());

    try {
      final results = await Future.wait([
        _repository.getPublicVouchers(),
        _repository.getMySavedVouchers(),
      ]);

      final publicVouchers = results[0] as List<VoucherModel>;
      final savedVouchers = results[1] as List<VoucherModel>;

      emit(VoucherLoaded(
        publicVouchers: publicVouchers,
        savedVouchers: savedVouchers,
      ));
    } catch (e) {
      debugPrint('loadVouchers error: $e');
      emit(VoucherFailure(message: e.toString()));
    }
  }

  Future<void> searchVoucher(String code) async {
    final currentState = state;
    if (currentState is VoucherLoaded) {
      emit(currentState.copyWith(isSearching: true));
    }

    try {
      final voucher = await _repository.getVoucherByCode(code);

      if (currentState is VoucherLoaded) {
        emit(currentState.copyWith(
          isSearching: false,
          searchedVoucher: voucher,
        ));
      }
    } catch (e) {
      debugPrint('searchVoucher error: $e');
      if (currentState is VoucherLoaded) {
        emit(currentState.copyWith(
          isSearching: false,
          errorMessage: 'Khong tim thay voucher',
        ));
      }
    }
  }

  Future<void> saveVoucher(String id) async {
    final currentState = state;
    if (currentState is! VoucherLoaded) return;

    try {
      await _repository.saveVoucher(id);

      final voucher = currentState.publicVouchers.firstWhere(
        (v) => v.id == id,
        orElse: () => currentState.searchedVoucher ?? const VoucherModel(id: '', code: ''),
      );

      if (voucher.id.isNotEmpty) {
        final updatedSaved = [...currentState.savedVouchers, voucher];
        emit(currentState.copyWith(savedVouchers: updatedSaved));
      }
    } catch (e) {
      debugPrint('saveVoucher error: $e');
      emit(currentState.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> unsaveVoucher(String id) async {
    final currentState = state;
    if (currentState is! VoucherLoaded) return;

    try {
      await _repository.unsaveVoucher(id);

      final updatedSaved = currentState.savedVouchers
          .where((v) => v.id != id)
          .toList();
      emit(currentState.copyWith(savedVouchers: updatedSaved));
    } catch (e) {
      debugPrint('unsaveVoucher error: $e');
      emit(currentState.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadVouchers();
  }

  void clearSearch() {
    final currentState = state;
    if (currentState is VoucherLoaded) {
      emit(currentState.copyWith(
        searchedVoucher: null,
        errorMessage: null,
      ));
    }
  }
}
