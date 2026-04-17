part of 'cart_cubit.dart';

@immutable
sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  const CartLoaded({
    required this.cart,
    this.isUpdating = false,
    this.isCheckingOut = false,
    this.isApplyingVoucher = false,
    this.createdOrder,
    this.errorMessage,
    this.selectedVoucher,
    this.voucherError,
  });

  final CartModel cart;
  final bool isUpdating;
  final bool isCheckingOut;
  final bool isApplyingVoucher;
  final OrderModel? createdOrder;
  final String? errorMessage;
  final VoucherModel? selectedVoucher;
  final String? voucherError;

  CartLoaded copyWith({
    CartModel? cart,
    bool? isUpdating,
    bool? isCheckingOut,
    bool? isApplyingVoucher,
    OrderModel? createdOrder,
    String? errorMessage,
    VoucherModel? selectedVoucher,
    String? voucherError,
    bool clearVoucher = false,
    bool clearVoucherError = false,
  }) {
    return CartLoaded(
      cart: cart ?? this.cart,
      isUpdating: isUpdating ?? this.isUpdating,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      isApplyingVoucher: isApplyingVoucher ?? this.isApplyingVoucher,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: errorMessage,
      selectedVoucher: clearVoucher ? null : (selectedVoucher ?? this.selectedVoucher),
      voucherError: clearVoucherError ? null : (voucherError ?? this.voucherError),
    );
  }

  @override
  List<Object?> get props => [
        cart,
        isUpdating,
        isCheckingOut,
        isApplyingVoucher,
        createdOrder,
        errorMessage,
        selectedVoucher,
        voucherError,
      ];
}

final class CartFailure extends CartState {
  const CartFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
