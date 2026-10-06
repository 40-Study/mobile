import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import '../../widgets/payment_formatters.dart';

class InvoiceLineItemsCard extends StatelessWidget {
  const InvoiceLineItemsCard({
    super.key,
    required this.invoice,
  });

  final ParentInvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
            'BẢNG KÊ CHI PHÍ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...invoice.lineItems.map((item) {
            final isDiscount = item.isDiscount || item.amount < 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDiscount) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 6),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isDiscount
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isDiscount
                                ? const Color(0xFF15803D)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        if (item.note != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.note!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatVnd(item.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isDiscount
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isDiscount
                          ? const Color(0xFF15803D)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                formatVnd(invoice.totalAmount),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
