import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({required StudentRepository repository})
      : _repository = repository,
        super(const CartInitial());

  final StudentRepository _repository;

  Future<void> loadCart() async {
    emit(const CartLoading());

    try {
      final cart = await _repository.getCart();
      emit(CartLoaded(cart: cart));
    } catch (e) {
      debugPrint('loadCart error: $e');
      emit(CartFailure(message: e.toString()));
    }
  }

  Future<void> addToCart(String courseId) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWith(isUpdating: true));
    }

    try {
      await _repository.addToCart(courseId);
      await loadCart();
    } catch (e) {
      debugPrint('addToCart error: $e');
      if (currentState is CartLoaded) {
        emit(currentState.copyWith(
          isUpdating: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> removeFromCart(List<String> courseIds) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWith(isUpdating: true));
    }

    try {
      await _repository.removeFromCart(courseIds);
      await loadCart();
    } catch (e) {
      debugPrint('removeFromCart error: $e');
      if (currentState is CartLoaded) {
        emit(currentState.copyWith(
          isUpdating: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> clearCart() async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWith(isUpdating: true));
    }

    try {
      await _repository.clearCart();
      emit(const CartLoaded(cart: CartModel()));
    } catch (e) {
      debugPrint('clearCart error: $e');
      if (currentState is CartLoaded) {
        emit(currentState.copyWith(
          isUpdating: false,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> checkout({String? couponCode}) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    emit(currentState.copyWith(isCheckingOut: true));

    try {
      final courseIds = currentState.cart.items
          .map((item) => item.courseId)
          .toList();

      final order = await _repository.createOrder(
        source: 'cart',
        courseIds: courseIds,
        couponCode: couponCode,
      );

      emit(currentState.copyWith(
        isCheckingOut: false,
        createdOrder: order,
      ));
    } catch (e) {
      debugPrint('checkout error: $e');
      emit(currentState.copyWith(
        isCheckingOut: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh() async {
    await loadCart();
  }

  Future<void> applyVoucher(String code) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    emit(currentState.copyWith(
      isApplyingVoucher: true,
      clearVoucherError: true,
    ));

    try {
      final voucher = await _repository.getVoucherByCode(code);
      emit(currentState.copyWith(
        isApplyingVoucher: false,
        selectedVoucher: voucher,
      ));
    } catch (e) {
      debugPrint('applyVoucher error: $e');
      emit(currentState.copyWith(
        isApplyingVoucher: false,
        voucherError: e.toString(),
      ));
    }
  }

  void removeVoucher() {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    emit(currentState.copyWith(
      clearVoucher: true,
      clearVoucherError: true,
    ));
  }
}
