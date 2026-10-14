import 'package:flutter/material.dart';

class PaymentToolbar extends StatelessWidget {
  const PaymentToolbar({
    super.key,
    required this.showDueDemo,
    required this.onOpenHistory,
    required this.onToggleDemo,
  });

  final bool showDueDemo;
  final VoidCallback onOpenHistory;
  final VoidCallback onToggleDemo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Nút mở Lịch sử thanh toán
        InkWell(
          onTap: onOpenHistory,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  'Lịch sử thanh toán',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Nút toggle chuyển chế độ demo All-Clear ↔ Có nợ quá hạn
        InkWell(
          onTap: onToggleDemo,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: showDueDemo
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: showDueDemo
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFBBF7D0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  showDueDemo
                      ? Icons.pending_actions_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 14,
                  color: showDueDemo
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF15803D),
                ),
                const SizedBox(width: 5),
                Text(
                  showDueDemo ? 'Demo: Có nợ quá hạn' : 'Demo: Tất toán',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: showDueDemo
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
