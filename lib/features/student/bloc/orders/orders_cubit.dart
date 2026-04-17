import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/orders/orders_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({required StudentRepository repository})
      : _repository = repository,
        super(const OrdersInitial());

  final StudentRepository _repository;

  /// Tai danh sach don hang.
  Future<void> loadOrders() async {
    emit(const OrdersLoading());
    try {
      final orders = await _repository.getOrders();
      emit(OrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Lam moi.
  Future<void> refresh() async {
    final currentState = state;
    try {
      final orders = await _repository.getOrders();
      if (currentState is OrdersLoaded) {
        emit(currentState.copyWith(orders: orders, page: 1, hasReachedMax: false));
      } else {
        emit(OrdersLoaded(orders: orders));
      }
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Loc theo trang thai.
  void filterByStatus(String? status) {
    final currentState = state;
    if (currentState is! OrdersLoaded) return;
    emit(currentState.copyWith(
      selectedFilter: status,
      clearFilter: status == null,
    ));
  }

  /// Tai them.
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! OrdersLoaded || currentState.isLoadingMore || currentState.hasReachedMax) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.page + 1;
      final moreOrders = await _repository.getOrders(page: nextPage);

      if (moreOrders.isEmpty) {
        emit(currentState.copyWith(isLoadingMore: false, hasReachedMax: true));
      } else {
        emit(currentState.copyWith(
          orders: [...currentState.orders, ...moreOrders],
          isLoadingMore: false,
          page: nextPage,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}

// ============================================================================
// Checkout Cubit
// ============================================================================

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({required StudentRepository repository})
      : _repository = repository,
        super(const CheckoutInitial());

  final StudentRepository _repository;

  /// Tao don hang tu gio hang.
  Future<void> createOrder({
    required List<String> courseIds,
    String? couponCode,
  }) async {
    emit(const CheckoutCreating());
    try {
      final order = await _repository.createOrder(
        source: 'cart',
        courseIds: courseIds,
        couponCode: couponCode,
      );
      emit(CheckoutCreated(order: order));
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

  /// Bat dau thanh toan.
  void startPayment() {
    final currentState = state;
    if (currentState is! CheckoutCreated) return;
    emit(CheckoutPaymentPending(order: currentState.order));
  }

  /// Kiem tra trang thai thanh toan.
  Future<void> checkPaymentStatus(String orderId) async {
    final currentState = state;
    if (currentState is! CheckoutPaymentPending) return;

    emit(currentState.copyWith(isChecking: true));

    try {
      final order = await _repository.getOrderDetail(orderId);

      if (order.status == 'completed' || order.status == 'paid') {
        emit(CheckoutSuccess(order: order));
      } else {
        emit(currentState.copyWith(isChecking: false));
      }
    } catch (e) {
      emit(currentState.copyWith(isChecking: false));
    }
  }

  /// Reset state.
  void reset() {
    emit(const CheckoutInitial());
  }
}
