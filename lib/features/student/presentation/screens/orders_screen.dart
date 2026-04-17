import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/orders/orders_cubit.dart';
import 'package:study/features/student/bloc/orders/orders_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/index.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersCubit(
        repository: context.read<StudentRepository>(),
      )..loadOrders(),
      child: const _OrdersScreenContent(),
    );
  }
}

class _OrdersScreenContent extends StatelessWidget {
  const _OrdersScreenContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Don hang cua toi'),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          return switch (state) {
            OrdersInitial() || OrdersLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            OrdersLoaded() => state.orders.isEmpty
                ? _buildEmptyState(context)
                : _buildOrdersList(context, state),
            OrdersError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(message),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () => context.read<OrdersCubit>().loadOrders(),
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

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: cs.outline),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chua co don hang nao',
            style: tt.titleLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Cac don hang cua ban se xuat hien o day',
            style: tt.bodyMedium?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, OrdersLoaded state) {
    return Column(
      children: [
        // Filter chips
        _FilterChips(
          selectedFilter: state.selectedFilter,
          onFilterChanged: (filter) {
            context.read<OrdersCubit>().filterByStatus(filter);
          },
        ),

        // Orders list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<OrdersCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.filteredOrders.length,
              itemBuilder: (context, index) {
                final order = state.filteredOrders[index];
                return _OrderCard(order: order);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final String? selectedFilter;
  final ValueChanged<String?> onFilterChanged;

  static const _statuses = [
    ('pending', 'Cho thanh toan'),
    ('processing', 'Dang xu ly'),
    ('completed', 'Hoan thanh'),
    ('cancelled', 'Da huy'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Tat ca'),
            selected: selectedFilter == null,
            onSelected: (_) => onFilterChanged(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          ..._statuses.map((s) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(s.$2),
                  selected: selectedFilter == s.$1,
                  onSelected: (_) => onFilterChanged(s.$1),
                ),
              )),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOrderDetail(context),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primaryContainer.withOpacity(0.5),
                      cs.primaryContainer.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: cs.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber ?? order.id,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: cs.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(order.createdAt),
                                style: tt.bodySmall?.copyWith(
                                  color: cs.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: order.status),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Items
                    ...order.items.take(2).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cs.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.play_circle_fill,
                                  size: 18,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  item.courseTitle ?? 'Khoa hoc',
                                  style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '\$${(item.discountPrice ?? item.price).toStringAsFixed(0)}',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.outline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (order.items.length > 2)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${order.items.length - 2} khoa hoc khac',
                          style: tt.bodySmall?.copyWith(color: cs.outline),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // Total row
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cs.primary.withOpacity(0.05),
                            cs.tertiary.withOpacity(0.05),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tong cong',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.outline,
                                ),
                              ),
                              Text(
                                '${order.items.length} khoa hoc',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.outline,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${order.finalAmount.toStringAsFixed(2)}',
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => _OrderDetailSheet(
          order: order,
          scrollController: controller,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  String get _displayName {
    switch (status) {
      case 'pending':
        return 'Cho thanh toan';
      case 'processing':
        return 'Dang xu ly';
      case 'completed':
      case 'paid':
        return 'Hoan thanh';
      case 'cancelled':
        return 'Da huy';
      case 'refunded':
        return 'Da hoan tien';
      default:
        return status;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.sync;
      case 'completed':
      case 'paid':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.replay;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'pending':
        backgroundColor = cs.tertiary;
        textColor = cs.onTertiary;
      case 'processing':
        backgroundColor = cs.primary;
        textColor = cs.onPrimary;
      case 'completed':
      case 'paid':
        backgroundColor = cs.secondary;
        textColor = cs.onSecondary;
      case 'cancelled':
      case 'refunded':
        backgroundColor = cs.error;
        textColor = cs.onError;
      default:
        backgroundColor = cs.surfaceContainerHighest;
        textColor = cs.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            _displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({
    required this.order,
    required this.scrollController,
  });

  final OrderModel order;
  final ScrollController scrollController;

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chi tiet don hang',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Order info
                _InfoRow(label: 'Ma don hang', value: order.orderNumber ?? order.id),
                _InfoRow(
                  label: 'Ngay dat',
                  value: _formatDate(order.createdAt),
                ),
                if (order.paidAt != null)
                  _InfoRow(
                    label: 'Ngay thanh toan',
                    value: _formatDate(order.paidAt),
                  ),

                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Khoa hoc',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),

                // Items
                ...order.items.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.primaryContainer,
                          child: Icon(Icons.play_arrow, color: cs.primary),
                        ),
                        title: Text(item.courseTitle ?? 'Khoa hoc'),
                        trailing: Text(
                          '\$${(item.discountPrice ?? item.price).toStringAsFixed(2)}',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),

                const SizedBox(height: AppSpacing.lg),

                // Price breakdown
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _PriceRow(
                          label: 'Tam tinh',
                          value: '\$${order.total.toStringAsFixed(2)}',
                        ),
                        if (order.discountAmount > 0) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _PriceRow(
                            label: 'Giam gia',
                            value:
                                '-\$${order.discountAmount.toStringAsFixed(2)}',
                            valueColor: cs.primary,
                          ),
                        ],
                        const Divider(height: AppSpacing.lg),
                        _PriceRow(
                          label: 'Tong cong',
                          value: '\$${order.finalAmount.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: tt.bodyMedium?.copyWith(color: cs.outline)),
          Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
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
