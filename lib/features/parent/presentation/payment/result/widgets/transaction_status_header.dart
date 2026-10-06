import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';

class TransactionStatusHeader extends StatelessWidget {
  const TransactionStatusHeader({
    super.key,
    required this.status,
    required this.title,
    required this.message,
  });

  final PaymentTransactionStatus status;
  final String title;
  final String message;

  Color _getPrimaryColor() {
    switch (status) {
      case PaymentTransactionStatus.success:
        return const Color(0xFF15803D); // Green
      case PaymentTransactionStatus.failed:
        return const Color(0xFFDC2626); // Red
      case PaymentTransactionStatus.pending:
        return const Color(0xFFD97706); // Amber
      case PaymentTransactionStatus.unknown:
        return const Color(0xFF475569); // Slate
    }
  }

  Color _getBgColor() {
    switch (status) {
      case PaymentTransactionStatus.success:
        return const Color(0xFFDCFCE7);
      case PaymentTransactionStatus.failed:
        return const Color(0xFFFEE2E2);
      case PaymentTransactionStatus.pending:
        return const Color(0xFFFEF3C7);
      case PaymentTransactionStatus.unknown:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _getIcon() {
    switch (status) {
      case PaymentTransactionStatus.success:
        return Icons.check_circle_rounded;
      case PaymentTransactionStatus.failed:
        return Icons.cancel_rounded;
      case PaymentTransactionStatus.pending:
        return Icons.hourglass_top_rounded;
      case PaymentTransactionStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor();
    final bgColor = _getBgColor();

    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            _getIcon(),
            size: 44,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
