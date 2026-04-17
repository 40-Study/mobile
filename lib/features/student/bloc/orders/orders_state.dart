import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

final class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

final class OrdersLoaded extends OrdersState {
  const OrdersLoaded({
    required this.orders,
    this.selectedFilter,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.page = 1,
  });

  final List<OrderModel> orders;
  final String? selectedFilter;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int page;

  /// Loc theo trang thai.
  List<OrderModel> get filteredOrders {
    if (selectedFilter == null) return orders;
    return orders.where((o) => o.status == selectedFilter).toList();
  }

  /// Don hang dang cho thanh toan.
  List<OrderModel> get pendingOrders =>
      orders.where((o) => o.status == 'pending').toList();

  OrdersLoaded copyWith({
    List<OrderModel>? orders,
    String? selectedFilter,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? page,
    bool clearFilter = false,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [orders, selectedFilter, isLoadingMore, hasReachedMax, page];
}

final class OrdersError extends OrdersState {
  const OrdersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// Checkout State
// ============================================================================

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

final class CheckoutCreating extends CheckoutState {
  const CheckoutCreating();
}

final class CheckoutCreated extends CheckoutState {
  const CheckoutCreated({required this.order});

  final OrderModel order;

  @override
  List<Object?> get props => [order];
}

final class CheckoutPaymentPending extends CheckoutState {
  const CheckoutPaymentPending({
    required this.order,
    this.isChecking = false,
  });

  final OrderModel order;
  final bool isChecking;

  CheckoutPaymentPending copyWith({bool? isChecking}) {
    return CheckoutPaymentPending(
      order: order,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  @override
  List<Object?> get props => [order, isChecking];
}

final class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess({required this.order});

  final OrderModel order;

  @override
  List<Object?> get props => [order];
}

final class CheckoutError extends CheckoutState {
  const CheckoutError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
