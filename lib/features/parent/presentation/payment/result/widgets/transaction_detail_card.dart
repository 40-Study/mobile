import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import '../../widgets/payment_formatters.dart';

class TransactionDetailCard extends StatelessWidget {
  const TransactionDetailCard({
    super.key,
    required this.result,
  });

  final PaymentTransactionResult result;

  String _getMethodName(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.vietQr:
        return 'VietQR Napas247';
      case PaymentMethodType.atmCard:
        return 'Thẻ ATM nội địa';
      case PaymentMethodType.eWallet:
        return 'Ví điện tử';
      case PaymentMethodType.creditCard:
        return 'Thẻ quốc tế';
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value, {
    bool canCopy = false,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                      color: valueColor ?? const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (canCopy) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _copyToClipboard(context, value, label),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeStr = '${result.timestamp.hour.toString().padLeft(2, '0')}:'
        '${result.timestamp.minute.toString().padLeft(2, '0')} - '
        '${result.timestamp.day.toString().padLeft(2, '0')}/'
        '${result.timestamp.month.toString().padLeft(2, '0')}/'
        '${result.timestamp.year}';

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHI TIẾT GIAO DỊCH',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildRow(
            context,
            'Mã giao dịch',
            result.transactionId,
            canCopy: true,
            isBold: true,
          ),
          const Divider(height: 1, thickness: 0.5),
          _buildRow(
            context,
            'Số tiền',
            formatVnd(result.amount),
            isBold: true,
            valueColor: const Color(0xFF1D4ED8),
          ),
          const Divider(height: 1, thickness: 0.5),
          _buildRow(
            context,
            'Phương thức',
            _getMethodName(result.paymentMethod),
          ),
          const Divider(height: 1, thickness: 0.5),
          _buildRow(context, 'Thời gian', timeStr),
          const Divider(height: 1, thickness: 0.5),
          _buildRow(
            context,
            'Mã tra soát Idempotency',
            result.idempotencyKey.length > 20
                ? '${result.idempotencyKey.substring(0, 18)}...'
                : result.idempotencyKey,
            canCopy: true,
          ),
          if (result.vatInfo != null) ...[
            const Divider(height: 1, thickness: 0.5),
            _buildRow(
              context,
              'Hóa đơn VAT (MST)',
              result.vatInfo!.taxCode,
            ),
          ],
        ],
      ),
    );
  }
}
