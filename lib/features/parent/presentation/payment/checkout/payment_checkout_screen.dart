import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import 'package:study/features/parent/repository/parent_payment_repository.dart';
import 'package:study/features/parent/repository/parent_payment_repository_impl.dart';
import '../widgets/payment_formatters.dart';
import 'widgets/checkout_order_summary_card.dart';
import 'widgets/payment_method_selector.dart';
import 'widgets/vat_invoice_form.dart';
import 'widgets/viet_qr_display_card.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({
    super.key,
    required this.invoice,
    this.repository,
    this.onPaymentCompleted,
  });

  final ParentInvoiceModel invoice;
  final ParentPaymentRepository? repository;
  final void Function(PaymentTransactionResult result)? onPaymentCompleted;

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  late final ParentPaymentRepository _repository;

  PaymentMethodType _selectedMethod = PaymentMethodType.vietQr;
  VatInvoiceRequestInfo? _vatInfo;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ParentPaymentRepositoryImpl();
  }

  Future<void> _handleSubmitPayment() async {
    if (_isSubmitting) return; // Bảo toàn Idempotency: chống double-click

    setState(() => _isSubmitting = true);

    try {
      // Tạo Idempotency Key duy nhất cho attempt này
      final idempotencyKey = 'attempt-${widget.invoice.id}-'
          '${DateTime.now().millisecondsSinceEpoch}';

      final result = await _repository.submitPayment(
        invoiceId: widget.invoice.id,
        method: _selectedMethod,
        idempotencyKey: idempotencyKey,
        vatInfo: _vatInfo,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (widget.onPaymentCompleted != null) {
        widget.onPaymentCompleted!(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Giao dịch ${result.transactionId}: ${result.status.name}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xử lý giao dịch: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surfaceBg = Color.alphaBlend(
      cs.primary.withValues(
        alpha: Theme.of(context).brightness == Brightness.light ? 0.045 : 0.065,
      ),
      cs.surfaceContainer,
    );
    final invoice = widget.invoice;
    final shortName = invoice.childName.split(' ').last;

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thanh toán học phí',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Học phí · $shortName (${invoice.className})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tóm tắt thông tin khoản nộp
              CheckoutOrderSummaryCard(invoice: invoice),

              const SizedBox(height: 18),

              // 2. Bộ chọn 4 phương thức thanh toán
              PaymentMethodSelector(
                selectedMethod: _selectedMethod,
                onChanged: (method) {
                  setState(() => _selectedMethod = method);
                },
              ),

              const SizedBox(height: 18),

              // 3. Khối VietQR động tương tác nếu chọn VietQR
              if (_selectedMethod == PaymentMethodType.vietQr) ...[
                VietQrDisplayCard(invoice: invoice),
                const SizedBox(height: 18),
              ],

              // 4. Form yêu cầu xuất hóa đơn GTGT (VAT)
              VatInvoiceForm(
                onChanged: (info) {
                  _vatInfo = info;
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TỔNG THANH TOÁN',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatVnd(invoice.totalAmount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _isSubmitting ? null : _handleSubmitPayment,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedMethod == PaymentMethodType.vietQr
                                ? 'Xác nhận đã chuyển khoản'
                                : 'Tiến hành thanh toán',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
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
      ),
    );
  }
}
