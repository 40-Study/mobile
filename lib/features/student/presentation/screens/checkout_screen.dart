import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/orders/orders_cubit.dart';
import 'package:study/features/student/bloc/orders/orders_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/index.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({
    super.key,
    required this.cart,
    this.voucher,
  });

  final CartModel cart;
  final VoucherModel? voucher;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckoutCubit(
        repository: context.read<StudentRepository>(),
      ),
      child: _CheckoutScreenContent(cart: cart, voucher: voucher),
    );
  }
}

class _CheckoutScreenContent extends StatefulWidget {
  const _CheckoutScreenContent({
    required this.cart,
    this.voucher,
  });

  final CartModel cart;
  final VoucherModel? voucher;

  @override
  State<_CheckoutScreenContent> createState() => _CheckoutScreenContentState();
}

class _CheckoutScreenContentState extends State<_CheckoutScreenContent> {
  @override
  void initState() {
    super.initState();
    _createOrder();
  }

  void _createOrder() {
    context.read<CheckoutCubit>().createOrder(
          courseIds: widget.cart.items.map((e) => e.courseId).toList(),
          couponCode: widget.voucher?.code,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toan'),
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutCreated) {
            // Show order created
            context.read<CheckoutCubit>().startPayment();
          } else if (state is CheckoutSuccess) {
            _showSuccessDialog();
          }
        },
        builder: (context, state) {
          return switch (state) {
            CheckoutInitial() ||
            CheckoutCreating() =>
              const Center(child: CircularProgressIndicator()),
            CheckoutCreated(:final order) => _OrderCreatedView(
                order: order,
                onProceed: () => context.read<CheckoutCubit>().startPayment(),
              ),
            CheckoutPaymentPending(:final order) => _PaymentPendingView(
                order: order,
                onCheckPayment: () => context
                    .read<CheckoutCubit>()
                    .checkPaymentStatus(order.id),
                onCancel: () => _showCancelConfirmDialog(),
              ),
            CheckoutSuccess(:final order) => _PaymentSuccessView(
                order: order,
                onGoToLearning: () => _goToLearning(),
              ),
            CheckoutError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(message),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _createOrder,
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

  void _showSuccessDialog() {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.check_circle, color: cs.primary, size: 64),
        title: const Text('Thanh toan thanh cong!'),
        content: const Text('Ban da dang ky khoa hoc thanh cong.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _goToLearning();
            },
            child: const Text('Bat dau hoc'),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Huy don hang?'),
        content: const Text('Ban co chac muon huy don hang nay?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Khong'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<CheckoutCubit>().reset();
              Navigator.of(context).pop();
            },
            child: const Text('Huy don'),
          ),
        ],
      ),
    );
  }

  void _goToLearning() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _OrderCreatedView extends StatelessWidget {
  const _OrderCreatedView({
    required this.order,
    required this.onProceed,
  });

  final OrderModel order;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 80, color: cs.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Don hang da duoc tao',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ma don: ${order.orderNumber ?? order.id}',
            style: tt.bodyMedium?.copyWith(color: cs.outline),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Order summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.courseTitle ?? 'Khoa hoc',
                                style: tt.bodyMedium,
                              ),
                            ),
                            Text(
                              '\$${(item.discountPrice ?? item.price).toStringAsFixed(2)}',
                              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tong cong', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        '\$${order.finalAmount.toStringAsFixed(2)}',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onProceed,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text('Tiep tuc thanh toan'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentPendingView extends StatelessWidget {
  const _PaymentPendingView({
    required this.order,
    required this.onCheckPayment,
    required this.onCancel,
  });

  final OrderModel order;
  final VoidCallback onCheckPayment;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Amount
          Text(
            '\$${order.finalAmount.toStringAsFixed(2)}',
            style: tt.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Payment info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Icon(Icons.payment, size: 48, color: cs.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Vui long hoan tat thanh toan',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (order.paymentUrl != null) ...[
                    Text(
                      'Bam nut ben duoi de thanh toan qua cong thanh toan',
                      style: tt.bodyMedium?.copyWith(color: cs.outline),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          // TODO: Open payment URL
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Mo trang thanh toan'),
                      ),
                    ),
                  ] else
                    Text(
                      'Dang cho xu ly thanh toan...',
                      style: tt.bodyMedium?.copyWith(color: cs.outline),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Huy'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: onCheckPayment,
                  child: const Text('Da thanh toan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentSuccessView extends StatefulWidget {
  const _PaymentSuccessView({
    required this.order,
    required this.onGoToLearning,
  });

  final OrderModel order;
  final VoidCallback onGoToLearning;

  @override
  State<_PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<_PaymentSuccessView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated success icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          cs.primary.withOpacity(0.2),
                          cs.primary.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, cs.tertiary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: cs.onPrimary,
                        size: 50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Text content with fade animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    'Thanh toan thanh cong!',
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Ban da dang ky ${widget.order.items.length} khoa hoc thanh cong.',
                    style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Order summary card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cs.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        ...widget.order.items.take(3).map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      size: 16,
                                      color: cs.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.courseTitle ?? 'Khoa hoc',
                                      style: tt.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        if (widget.order.items.length > 3)
                          Text(
                            '+${widget.order.items.length - 3} khoa hoc khac',
                            style: tt.bodySmall?.copyWith(color: cs.outline),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, cs.tertiary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onGoToLearning,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.rocket_launch,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Bat dau hoc ngay',
                                  style: tt.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
