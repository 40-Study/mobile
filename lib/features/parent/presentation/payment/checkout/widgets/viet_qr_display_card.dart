import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import '../../widgets/payment_formatters.dart';

class VietQrDisplayCard extends StatelessWidget {
  const VietQrDisplayCard({
    super.key,
    required this.invoice,
  });

  final ParentInvoiceModel invoice;

  static const String bankName = 'Ngân hàng TMCP Quân Đội (MB Bank)';
  static const String accountNumber = '0987654321';
  static const String accountHolder = 'CONG TY CO PHAN CONG NGHE FORTEX';

  String get transferContent =>
      'FORTEX ${invoice.invoiceCode.replaceAll('#', '')}';

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool canCopy = false,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
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
                        size: 14,
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

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF93C5FD),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Banner VietQR & Napas247
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'VIETQR · NAPAS 247',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D4ED8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Xử lý tức thì',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Khung mô phỏng mã QR động
          Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  size: 156,
                  color: Color(0xFF0F172A),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 20,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Quét mã qua ứng dụng ngân hàng bất kỳ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 10),

          // Bảng thông tin chuyển khoản chi tiết
          _buildInfoRow(context, 'Ngân hàng', bankName),
          _buildInfoRow(
            context,
            'Số tài khoản',
            accountNumber,
            canCopy: true,
            isBold: true,
          ),
          _buildInfoRow(context, 'Chủ tài khoản', accountHolder),
          _buildInfoRow(
            context,
            'Số tiền',
            formatVnd(invoice.totalAmount),
            isBold: true,
            valueColor: const Color(0xFF1D4ED8),
          ),
          _buildInfoRow(
            context,
            'Nội dung CK',
            transferContent,
            canCopy: true,
            isBold: true,
            valueColor: const Color(0xFFDC2626),
          ),

          const SizedBox(height: 12),

          // Hai nút hỗ trợ nhanh
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã lưu mã QR vào thư viện ảnh'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Lưu mã QR'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final allInfo = 'NH: $bankName\n'
                        'STK: $accountNumber\n'
                        'CTK: $accountHolder\n'
                        'So tien: ${formatVnd(invoice.totalAmount)}\n'
                        'Noi dung: $transferContent';
                    _copyToClipboard(
                      context,
                      allInfo,
                      'thông tin chuyển khoản',
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Sao chép tất cả'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Ghi chú hệ thống tự động
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hệ thống tự động đối soát và kích hoạt trong vòng '
                    '1-3 phút. Vui lòng nhập đúng nội dung CK ở trên.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
