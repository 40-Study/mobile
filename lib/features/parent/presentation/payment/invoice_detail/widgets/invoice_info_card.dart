import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';

class InvoiceInfoCard extends StatelessWidget {
  const InvoiceInfoCard({
    super.key,
    required this.invoice,
  });

  final ParentInvoiceModel invoice;

  Widget _buildRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            'THÔNG TIN KHÓA HỌC',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildRow('Học sinh', '${invoice.childName} (${invoice.className})'),
          const Divider(height: 1, thickness: 0.5),
          _buildRow('Khóa học', invoice.courseName, isHighlighted: true),
          const Divider(height: 1, thickness: 0.5),
          _buildRow('Giáo viên phụ trách', invoice.teacherName),
          const Divider(height: 1, thickness: 0.5),
          _buildRow('Thời lượng', invoice.durationText),
          const Divider(height: 1, thickness: 0.5),
          _buildRow('Hạn thanh toán', invoice.dueDateText),
          if (invoice.paidDateText != null) ...[
            const Divider(height: 1, thickness: 0.5),
            _buildRow('Ngày thanh toán', invoice.paidDateText!),
          ],
        ],
      ),
    );
  }
}
