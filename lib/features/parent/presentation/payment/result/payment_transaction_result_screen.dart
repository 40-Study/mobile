import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import 'package:study/features/parent/repository/parent_payment_repository.dart';
import 'package:study/features/parent/repository/parent_payment_repository_impl.dart';
import 'widgets/transaction_detail_card.dart';
import 'widgets/transaction_status_header.dart';

class PaymentTransactionResultScreen extends StatefulWidget {
  const PaymentTransactionResultScreen({
    super.key,
    required this.initialResult,
    this.repository,
    this.onReturnToPaymentHome,
    this.onRetryPayment,
    this.onViewReceipt,
  });

  final PaymentTransactionResult initialResult;
  final ParentPaymentRepository? repository;
  final VoidCallback? onReturnToPaymentHome;
  final VoidCallback? onRetryPayment;
  final void Function(String transactionId)? onViewReceipt;

  @override
  State<PaymentTransactionResultScreen> createState() =>
      _PaymentTransactionResultScreenState();
}

class _PaymentTransactionResultScreenState
    extends State<PaymentTransactionResultScreen> {
  late final ParentPaymentRepository _repository;
  late PaymentTransactionResult _currentResult;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ParentPaymentRepositoryImpl();
    _currentResult = widget.initialResult;
  }

  Future<void> _handleCheckStatus() async {
    setState(() => _isChecking = true);
    final updated =
        await _repository.checkPaymentStatus(_currentResult.transactionId);
    if (!mounted) return;
    setState(() {
      _currentResult = updated;
      _isChecking = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cập nhật trạng thái: ${_currentResult.statusTitle}'),
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
                  'Tổng đài Đối soát Giao dịch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mã giao dịch đối soát: ${_currentResult.transactionId}\n'
                  'Mã Idempotency: ${_currentResult.idempotencyKey}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.phone_rounded, color: Color(0xFF1D4ED8)),
                  ),
                  title: const Text('Hotline Kế toán & Đối soát'),
                  subtitle: const Text('1900 6868 (Phím 1) — 24/7'),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Chuyển đổi nhanh 4 trạng thái cho mục đích Demo & Kiểm thử
  void _switchDemoStatus(PaymentTransactionStatus newStatus) {
    String title;
    String msg;
    switch (newStatus) {
      case PaymentTransactionStatus.success:
        title = 'Thanh toán thành công!';
        msg = 'Khoản học phí đã được ghi nhận vào hệ thống học tập của con.';
        break;
      case PaymentTransactionStatus.failed:
        title = 'Thanh toán không thành công';
        msg = 'Giao dịch bị từ chối do tài khoản nguồn không đủ số dư.';
        break;
      case PaymentTransactionStatus.pending:
        title = 'Giao dịch đang được xử lý';
        msg = 'Hệ thống ngân hàng đang đối soát chuyển khoản. Kết quả sẽ '
            'được cập nhật tự động sau vài phút.';
        break;
      case PaymentTransactionStatus.unknown:
        title = 'Chưa xác nhận được kết quả';
        msg = 'Đã quá thời gian chờ phản hồi từ cổng thanh toán. Phụ huynh '
            'vui lòng không chuyển tiền thêm lần nữa trước khi tra soát.';
        break;
    }

    setState(() {
      _currentResult = PaymentTransactionResult(
        transactionId: _currentResult.transactionId,
        invoiceId: _currentResult.invoiceId,
        amount: _currentResult.amount,
        status: newStatus,
        statusTitle: title,
        message: msg,
        paymentMethod: _currentResult.paymentMethod,
        timestamp: DateTime.now(),
        idempotencyKey: _currentResult.idempotencyKey,
        vatInfo: _currentResult.vatInfo,
      );
    });
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
    final status = _currentResult.status;

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kết quả giao dịch',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          // Demo Switcher cho 4 trạng thái
          PopupMenuButton<PaymentTransactionStatus>(
            tooltip: 'Đổi trạng thái mẫu kết quả',
            icon: const Icon(Icons.tune_rounded),
            onSelected: _switchDemoStatus,
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: PaymentTransactionStatus.success,
                child: Text('Trạng thái 1: Thành công'),
              ),
              const PopupMenuItem(
                value: PaymentTransactionStatus.failed,
                child: Text('Trạng thái 2: Thất bại'),
              ),
              const PopupMenuItem(
                value: PaymentTransactionStatus.pending,
                child: Text('Trạng thái 3: Đang xử lý (Pending)'),
              ),
              const PopupMenuItem(
                value: PaymentTransactionStatus.unknown,
                child: Text('Trạng thái 4: Chưa xác nhận (Timeout)'),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 1. Icon & Tiêu đề trạng thái kết quả
              TransactionStatusHeader(
                status: status,
                title: _currentResult.statusTitle,
                message: _currentResult.message,
              ),

              const SizedBox(height: 24),

              // 2. Thẻ chi tiết giao dịch
              TransactionDetailCard(result: _currentResult),

              const SizedBox(height: 32),
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
            // Cụm nút hành động theo từng trạng thái cụ thể
            if (status == PaymentTransactionStatus.success) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (widget.onViewReceipt != null) {
                      widget.onViewReceipt!(_currentResult.transactionId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đang mở Biên lai điện tử...'),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Xem biên lai điện tử (PDF)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    if (widget.onReturnToPaymentHome != null) {
                      widget.onReturnToPaymentHome!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Về trang Học phí',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else if (status == PaymentTransactionStatus.failed) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (widget.onRetryPayment != null) {
                      widget.onRetryPayment!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Thử lại thanh toán (Attempt mới)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đổi phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else if (status == PaymentTransactionStatus.pending) ...[
              // QUY TẮC BẢO TOÀN IDEMPOTENCY: KHÔNG CÓ NÚT THỬ LẠI KHI PENDING!
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isChecking ? null : _handleCheckStatus,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Kiểm tra lại trạng thái',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    if (widget.onReturnToPaymentHome != null) {
                      widget.onReturnToPaymentHome!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Về trang Học phí',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Trạng thái Unknown / Timeout
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isChecking ? null : _handleCheckStatus,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Kiểm tra lại trạng thái',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleContactSupport,
                  icon: const Icon(Icons.support_agent_rounded, size: 18),
                  label: const Text(
                    'Liên hệ hỗ trợ đối soát',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
