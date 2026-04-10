import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/bloc/children/children_selector_cubit.dart';
import 'package:study/features/parent/bloc/children/children_selector_state.dart';
import 'package:study/features/parent/bloc/finance/parent_finance_cubit.dart';
import 'package:study/features/parent/bloc/finance/parent_finance_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/theme/app_colors.dart';

class ParentFinanceScreen extends StatefulWidget {
  const ParentFinanceScreen({super.key});

  @override
  State<ParentFinanceScreen> createState() => _ParentFinanceScreenState();
}

class _ParentFinanceScreenState extends State<ParentFinanceScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final selectedChild = context.read<ChildrenSelectorCubit>().selectedChild;
    context.read<ParentFinanceCubit>().loadFinance(childId: selectedChild?.id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocListener<ChildrenSelectorCubit, ChildrenSelectorState>(
          listener: (context, state) {
            if (state is ChildrenSelectorLoaded && state.selectedChild != null) {
              context.read<ParentFinanceCubit>().loadFinance(
                    childId: state.selectedChild!.id,
                  );
            }
          },
          child: BlocBuilder<ParentFinanceCubit, ParentFinanceState>(
            builder: (context, state) {
              return switch (state) {
                ParentFinanceInitial() || ParentFinanceLoading() =>
                  const Center(child: CircularProgressIndicator()),
                ParentFinanceLoaded() => RefreshIndicator(
                    onRefresh: () => context.read<ParentFinanceCubit>().refresh(),
                    child: _FinanceContent(finance: state.financeOverview),
                  ),
                ParentFinanceFailure(:final message) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: cs.error),
                        const SizedBox(height: AppSpacing.lg),
                        Text(message),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: _loadData,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _FinanceContent extends StatelessWidget {
  const _FinanceContent({required this.finance});

  final ParentFinanceOverviewModel finance;

  String _formatCurrency(double amount) {
    final normalized = amount.round();
    return '${NumberFormat.decimalPattern('vi_VN').format(normalized)}đ';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Header
        Text(
          'Tài chính',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        const StudentSelectorDropdown(),
        const SizedBox(height: AppSpacing.xl),

        // Overview Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: cs.gradientRich,
            borderRadius: BorderRadius.circular(24),
            boxShadow: cs.shadowPrimary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng học phí',
                style: TextStyle(
                  color: cs.onPrimary.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatCurrency(finance.totalTuition),
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _FinanceStatItem(
                      label: 'Đã thanh toán',
                      value: _formatCurrency(finance.paidAmount),
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: cs.onPrimary.withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: _FinanceStatItem(
                      label: 'Còn lại',
                      value: _formatCurrency(finance.remainingAmount),
                      icon: Icons.access_time,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Pending Payments
        if (finance.pendingPayments.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cần thanh toán',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...finance.pendingPayments.take(3).map(
                (payment) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _PendingPaymentCard(payment: payment),
                ),
              ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Payment History
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch sử thanh toán',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (finance.paymentHistory.isEmpty)
          const _EmptyCard(message: 'Chưa có lịch sử thanh toán')
        else
          ...finance.paymentHistory.take(5).map(
                (payment) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PaymentHistoryCard(payment: payment),
                ),
              ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _FinanceStatItem extends StatelessWidget {
  const _FinanceStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cs.onPrimary.withValues(alpha: 0.8), size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: cs.onPrimary.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  const _PendingPaymentCard({required this.payment});

  final PendingPaymentModel payment;

  String _formatCurrency(double amount) {
    final normalized = amount.round();
    return '${NumberFormat.decimalPattern('vi_VN').format(normalized)}đ';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: payment.isOverdue
            ? cs.errorContainer.withValues(alpha: 0.3)
            : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: payment.isOverdue
              ? cs.error.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.courseName ?? 'Học phí',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (payment.childName != null)
                      Text(
                        payment.childName!,
                        style: TextStyle(
                          color: cs.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                _formatCurrency(payment.amount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: payment.isOverdue ? cs.error : cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: payment.isOverdue ? cs.error : cs.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Hạn: ${payment.dueDate}',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          payment.isOverdue ? cs.error : cs.textSecondary,
                    ),
                  ),
                  if (payment.isOverdue) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Quá hạn',
                        style: TextStyle(
                          color: cs.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
                child: const Text('Thanh toán'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({required this.payment});

  final PaymentHistoryModel payment;

  String _formatCurrency(double amount) {
    final normalized = amount.round();
    return '${NumberFormat.decimalPattern('vi_VN').format(normalized)}đ';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final statusColor = switch (payment.status) {
      PaymentStatus.completed => Colors.green,
      PaymentStatus.pending => Colors.orange,
      PaymentStatus.failed => Colors.red,
      PaymentStatus.refunded => Colors.blue,
    };

    final statusText = switch (payment.status) {
      PaymentStatus.completed => 'Thành công',
      PaymentStatus.pending => 'Đang xử lý',
      PaymentStatus.failed => 'Thất bại',
      PaymentStatus.refunded => 'Hoàn tiền',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              payment.status == PaymentStatus.completed
                  ? Icons.check_circle
                  : payment.status == PaymentStatus.pending
                      ? Icons.access_time
                      : Icons.cancel,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.courseName ?? 'Học phí',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.paymentDate,
                  style: TextStyle(
                    color: cs.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(payment.amount),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: cs.textSecondary),
      ),
    );
  }
}
