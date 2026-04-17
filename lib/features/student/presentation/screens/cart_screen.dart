import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/cart/cart_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/checkout_screen.dart';
import 'package:study/index.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit(
        repository: context.read<StudentRepository>(),
      )..loadCart(),
      child: const _CartScreenContent(),
    );
  }
}

class _CartScreenContent extends StatefulWidget {
  const _CartScreenContent();

  @override
  State<_CartScreenContent> createState() => _CartScreenContentState();
}

class _CartScreenContentState extends State<_CartScreenContent> {
  final _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _applyVoucher() {
    final code = _voucherController.text.trim();
    if (code.isNotEmpty) {
      context.read<CartCubit>().applyVoucher(code);
    }
  }

  void _goToCheckout(CartLoaded state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cart: state.cart,
          voucher: state.selectedVoucher,
        ),
      ),
    );
  }

  double _calculateDiscount(CartLoaded state) {
    final voucher = state.selectedVoucher;
    if (voucher == null) return 0;

    if (voucher.discountType == 'percentage') {
      final discount = state.cart.total * voucher.discountValue / 100;
      if (voucher.maxDiscount != null && discount > voucher.maxDiscount!) {
        return voucher.maxDiscount!;
      }
      return discount;
    }
    return voucher.discountValue;
  }

  double _calculateFinalTotal(CartLoaded state) {
    final discount = _calculateDiscount(state);
    final total = state.cart.total - discount;
    return total > 0 ? total : 0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gio hang'),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.items.isNotEmpty) {
                return TextButton(
                  onPressed: () => _showClearConfirmDialog(context),
                  child: Text('Xoa tat ca', style: TextStyle(color: cs.error)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return switch (state) {
            CartInitial() || CartLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            CartLoaded() => state.cart.items.isEmpty
                ? _buildEmptyCart(cs, tt)
                : _buildCartContent(context, state, cs, tt),
            CartFailure(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(message),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () => context.read<CartCubit>().loadCart(),
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }

  Widget _buildEmptyCart(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: cs.outline),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Gio hang trong',
            style: tt.titleLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hay them khoa hoc vao gio hang',
            style: tt.bodyMedium?.copyWith(color: cs.outline),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.explore),
            label: const Text('Kham pha khoa hoc'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartLoaded state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final discount = _calculateDiscount(state);
    final finalTotal = _calculateFinalTotal(state);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<CartCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Cart items
                ...state.cart.items.map((item) => _CartItemCard(
                      item: item,
                      onRemove: () =>
                          context.read<CartCubit>().removeFromCart([item.courseId]),
                    )),

                const SizedBox(height: AppSpacing.lg),

                // Voucher input
                _VoucherSection(
                  controller: _voucherController,
                  selectedVoucher: state.selectedVoucher,
                  isLoading: state.isApplyingVoucher,
                  error: state.voucherError,
                  onApply: _applyVoucher,
                  onRemove: () => context.read<CartCubit>().removeVoucher(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Price summary
                _PriceSummary(
                  cart: state.cart,
                  voucher: state.selectedVoucher,
                  discount: discount,
                  finalTotal: finalTotal,
                ),
              ],
            ),
          ),
        ),

        // Checkout button
        _CheckoutBar(
          finalTotal: finalTotal,
          onCheckout: () => _goToCheckout(state),
        ),
      ],
    );
  }

  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoa gio hang?'),
        content: const Text('Ban co chac muon xoa tat ca khoa hoc khoi gio hang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<CartCubit>().clearCart();
            },
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onRemove,
  });

  final CartItemModel item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = item.course;
    final hasDiscount = course?.discountPrice != null && course!.discountPrice! < course.price;
    final displayPrice = hasDiscount ? course!.discountPrice! : (course?.price ?? 0);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 70,
                color: cs.surfaceContainerHighest,
                child: course?.thumbnailUrl != null
                    ? Image.network(
                        course!.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image, color: cs.outline),
                      )
                    : Icon(Icons.play_circle_outline, color: cs.outline),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course?.title ?? 'Khoa hoc',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course?.instructorName ?? '',
                    style: tt.bodySmall?.copyWith(color: cs.outline),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (hasDiscount) ...[
                        Text(
                          '\$${course!.price.toStringAsFixed(2)}',
                          style: tt.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: cs.outline,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        '\$${displayPrice.toStringAsFixed(2)}',
                        style: tt.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close, color: cs.error),
              tooltip: 'Xoa',
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherSection extends StatelessWidget {
  const _VoucherSection({
    required this.controller,
    required this.selectedVoucher,
    required this.isLoading,
    required this.error,
    required this.onApply,
    required this.onRemove,
  });

  final TextEditingController controller;
  final VoucherModel? selectedVoucher;
  final bool isLoading;
  final String? error;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  String _getDiscountDisplay(VoucherModel voucher) {
    if (voucher.discountType == 'percentage') {
      return '${voucher.discountValue.toInt()}%';
    }
    return '\$${voucher.discountValue.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (selectedVoucher != null) {
      return Card(
        color: cs.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.local_offer, color: cs.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedVoucher!.code,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    if (selectedVoucher!.name != null)
                      Text(
                        selectedVoucher!.name!,
                        style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer),
                      ),
                  ],
                ),
              ),
              Text(
                '-${_getDiscountDisplay(selectedVoucher!)}',
                style: tt.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.close, color: cs.primary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nhap ma giam gia',
                  prefixIcon: const Icon(Icons.local_offer_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: error,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            FilledButton(
              onPressed: isLoading ? null : onApply,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ap dung'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({
    required this.cart,
    required this.voucher,
    required this.discount,
    required this.finalTotal,
  });

  final CartModel cart;
  final VoucherModel? voucher;
  final double discount;
  final double finalTotal;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _PriceRow(
              label: 'Tam tinh (${cart.totalItem} khoa hoc)',
              value: '\$${cart.total.toStringAsFixed(2)}',
            ),
            if (voucher != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _PriceRow(
                label: 'Giam gia',
                value: '-\$${discount.toStringAsFixed(2)}',
                valueColor: cs.primary,
              ),
            ],
            const Divider(height: AppSpacing.lg),
            _PriceRow(
              label: 'Tong cong',
              value: '\$${finalTotal.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : tt.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                )
              : tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.finalTotal,
    required this.onCheckout,
  });

  final double finalTotal;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tong cong', style: tt.bodySmall),
                Text(
                  '\$${finalTotal.toStringAsFixed(2)}',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: FilledButton(
                onPressed: onCheckout,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: const Text('Thanh toan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
