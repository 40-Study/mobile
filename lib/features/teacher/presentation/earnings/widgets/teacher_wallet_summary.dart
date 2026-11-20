import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';
import '../../widgets/teacher_surface.dart';
import '../wallet_format.dart';

class TeacherWalletSummary extends StatelessWidget {
  const TeacherWalletSummary({super.key, required this.wallet});
  final Map<String, dynamic> wallet;
  @override
  Widget build(BuildContext context) => TeacherSurface(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        for (final item in {
          'Tổng thu nhập': 'total_earnings',
          'Đã chi trả': 'total_paid_out',
          'Đang xử lý': 'pending_withdrawal',
        }.entries)
          ListTile(
            contentPadding: AppSpacing.paddingLg,
            leading: Icon(
              item.value == 'total_earnings'
                  ? Icons.trending_up_rounded
                  : item.value == 'total_paid_out'
                  ? Icons.check_circle_outline
                  : Icons.schedule_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(item.key),
            subtitle: Text(
              teacherMoney(wallet[item.value]),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
      ],
    ),
  );
}
