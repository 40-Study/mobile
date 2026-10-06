import 'package:flutter/material.dart';
import '../../widgets/payment_formatters.dart';

class InvoiceStickyBottomBar extends StatelessWidget {
  const InvoiceStickyBottomBar({
    super.key,
    required this.amount,
    required this.isPaid,
    required this.isOverdue,
    this.isOffline = false,
    required this.onPayNow,
    required this.onDownloadReceipt,
  });

  final double amount;
  final bool isPaid;
  final bool isOverdue;
  final bool isOffline;
  final VoidCallback onPayNow;
  final VoidCallback onDownloadReceipt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOffline && !isPaid) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 14,
                    color: Color(0xFFDC2626),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Đang ngoại tuyến. Vui lòng kết nối mạng để thanh toán.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              // Cột tóm tắt số tiền bên trái
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPaid ? 'ĐÃ THANH TOÁN' : 'CẦN THANH TOÁN',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatVnd(amount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isPaid
                          ? const Color(0xFF15803D)
                          : (isOverdue
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Nút hành động bên phải
              Expanded(
                child: isPaid
                    ? OutlinedButton.icon(
                        onPressed: onDownloadReceipt,
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('Biên lai thu tiền'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF1D4ED8),
                            width: 1.2,
                          ),
                          foregroundColor: const Color(0xFF1D4ED8),
                        ),
                      )
                    : FilledButton(
                        onPressed: isOffline ? null : onPayNow,
                        style: FilledButton.styleFrom(
                          backgroundColor: isOverdue
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF1D4ED8),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Thanh toán ngay',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
