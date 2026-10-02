import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import '../checkout/payment_checkout_screen.dart';
import '../result/payment_transaction_result_screen.dart';
import '../widgets/payment_formatters.dart';
import 'widgets/invoice_info_card.dart';
import 'widgets/invoice_line_items_card.dart';
import 'widgets/invoice_policy_note_card.dart';
import 'widgets/invoice_sticky_bottom_bar.dart';
import 'widgets/invoice_vat_pdf_card.dart';

class PaymentInvoiceDetailScreen extends StatefulWidget {
  const PaymentInvoiceDetailScreen({
    super.key,
    required this.invoice,
    this.onCheckout,
  });

  final ParentInvoiceModel invoice;
  final void Function(ParentInvoiceModel invoice)? onCheckout;

  @override
  State<PaymentInvoiceDetailScreen> createState() =>
      _PaymentInvoiceDetailScreenState();
}

class _PaymentInvoiceDetailScreenState
    extends State<PaymentInvoiceDetailScreen> {
  bool _isOffline = false; // Mock offline toggle for testing guardrail

  void _copyInvoiceCode() {
    Clipboard.setData(ClipboardData(text: widget.invoice.invoiceCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã sao chép mã hóa đơn: ${widget.invoice.invoiceCode}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã chia sẻ thông tin học phí của ${widget.invoice.childName}',
        ),
      ),
    );
  }

  void _handleViewPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đang mở hóa đơn điện tử VAT cho mã ${widget.invoice.invoiceCode}...',
        ),
      ),
    );
  }

  void _handleContactSupport() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hỗ trợ Thu học phí & Kế toán',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Phụ huynh vui lòng liên hệ phòng Tài chính - Kế toán '
                  'theo các kênh sau:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.phone_rounded, color: Color(0xFF1D4ED8)),
                  ),
                  title: const Text('Hotline Kế toán'),
                  subtitle: const Text('1900 6868 (Phím 2) — 08:00 - 18:00'),
                  onTap: () => Navigator.pop(ctx),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF0FDF4),
                    child: Icon(Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF15803D)),
                  ),
                  title: const Text('Zalo Official Account'),
                  subtitle: const Text('ForteX Education Center'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handlePayNow() {
    if (widget.onCheckout != null) {
      widget.onCheckout!(widget.invoice);
    } else {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (ctx) => PaymentCheckoutScreen(
            invoice: widget.invoice,
            onPaymentCompleted: (result) {
              Navigator.pushReplacement<void, void>(
                ctx,
                MaterialPageRoute<void>(
                  builder: (resCtx) => PaymentTransactionResultScreen(
                    initialResult: result,
                    onReturnToPaymentHome: () {
                      Navigator.pop(resCtx);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  void _handleDownloadReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đang tải biên lai thanh toán cho ${widget.invoice.invoiceCode}...',
        ),
      ),
    );
  }

  String _getDueSubtitleText(
    ParentInvoiceModel invoice,
    bool isPaid,
    bool isOverdue,
  ) {
    if (isPaid) {
      final date = invoice.paidDateText ?? invoice.dueDateText;
      return 'Đã thanh toán vào $date';
    }
    if (isOverdue) {
      final days = invoice.overdueDays ?? 5;
      return 'Hạn nộp: ${invoice.dueDateText} (Quá hạn $days ngày)';
    }
    return 'Hạn nộp: ${invoice.dueDateText}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final invoice = widget.invoice;
    final isPaid = invoice.status == PaymentInvoiceStatus.paid;
    final isOverdue = invoice.status == PaymentInvoiceStatus.overdue;

    // Subtitle chuẩn hóa ngữ cảnh con (Locked Child Context):
    // Thay vì FAMILY SCOPE, hiển thị rõ ràng: Học phí · Minh (10A1)
    final shortName = invoice.childName.split(' ').last;
    final lockedChildSubtitle = 'Học phí · $shortName (${invoice.className})';

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết khoản thu',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              lockedChildSubtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        actions: [
          // Toggle Offline Guardrail test
          IconButton(
            tooltip: _isOffline
                ? 'Đang chế độ: Ngoại tuyến (Offline)'
                : 'Đang chế độ: Trực tuyến (Online)',
            icon: Icon(
              _isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
              color: _isOffline
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF15803D),
            ),
            onPressed: () {
              setState(() => _isOffline = !_isOffline);
            },
          ),
          IconButton(
            tooltip: 'Chia sẻ thông tin học phí',
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareInvoice,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Block Tài chính & Mã hóa đơn (Thiết kế 1)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isOverdue
                        ? const Color(0xFFFCA5A5)
                        : cs.outlineVariant.withValues(alpha: 0.6),
                    width: isOverdue ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hàng trên: Tag trạng thái & Mã hóa đơn bo pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? const Color(0xFFDCFCE7)
                                : (isOverdue
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFFEF3C7)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            invoice.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isPaid
                                  ? const Color(0xFF15803D)
                                  : (isOverdue
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFFD97706)),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _copyInvoiceCode,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  invoice.invoiceCode,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.copy_rounded,
                                  size: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'TỔNG TIỀN CẦN THANH TOÁN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      formatVnd(invoice.totalAmount),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          isPaid
                              ? Icons.check_circle_outline_rounded
                              : (isOverdue
                                  ? Icons.error_outline_rounded
                                  : Icons.access_time_rounded),
                          size: 14,
                          color: isPaid
                              ? const Color(0xFF15803D)
                              : (isOverdue
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFFD97706)),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getDueSubtitleText(invoice, isPaid, isOverdue),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isPaid
                                ? const Color(0xFF15803D)
                                : (isOverdue
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFFD97706)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Khối Thông tin Khóa học
              InvoiceInfoCard(invoice: invoice),

              const SizedBox(height: 16),

              // 3. Khối Bảng kê Chi phí Minh bạch (Line items)
              InvoiceLineItemsCard(invoice: invoice),

              const SizedBox(height: 16),

              // 4. Khối Hóa đơn điện tử VAT (PDF ký số)
              if (invoice.hasVatInvoice) ...[
                InvoiceVatPdfCard(onViewPdf: _handleViewPdf),
                const SizedBox(height: 16),
              ],

              // 5. Khối Lưu ý chính sách trung tâm & liên hệ kế toán
              if (invoice.policyNote != null) ...[
                InvoicePolicyNoteCard(
                  policyNote: invoice.policyNote!,
                  onContactSupport: _handleContactSupport,
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: InvoiceStickyBottomBar(
        amount: invoice.totalAmount,
        isPaid: isPaid,
        isOverdue: isOverdue,
        isOffline: _isOffline,
        onPayNow: _handlePayNow,
        onDownloadReceipt: _handleDownloadReceipt,
      ),
    );
  }
}
