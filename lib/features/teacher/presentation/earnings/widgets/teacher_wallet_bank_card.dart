import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';
import '../../widgets/teacher_surface.dart';
import '../wallet_format.dart';

class TeacherWalletBankCard extends StatelessWidget {
  const TeacherWalletBankCard({
    super.key,
    required this.wallet,
    required this.onEdit,
  });
  final Map<String, dynamic> wallet;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) => TeacherSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${wallet['bank_name'] ?? 'Chưa có ngân hàng'}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${wallet['bank_account_name'] ?? ''}\n${teacherMaskedAccount('${wallet['bank_account_number'] ?? ''}')}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
            label: const Text('Cập nhật ngân hàng'),
          ),
        ),
        const Text(
          'Đổi ngân hàng không thay đổi thông tin nhận tiền của yêu cầu đã gửi.',
        ),
      ],
    ),
  );
}
