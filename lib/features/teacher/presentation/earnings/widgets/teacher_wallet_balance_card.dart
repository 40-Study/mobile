import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';
import '../wallet_format.dart';

class TeacherWalletBalanceCard extends StatelessWidget {
  const TeacherWalletBalanceCard({super.key, required this.balance});
  final dynamic balance;
  @override
  Widget build(BuildContext context) => Container(
    padding: AppSpacing.paddingXl,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: AppRadius.borderLg,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            AppSpacing.hGap8,
            Expanded(
              child: Text(
                'Số dư khả dụng',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vGap12,
        Text(
          teacherMoney(balance),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
