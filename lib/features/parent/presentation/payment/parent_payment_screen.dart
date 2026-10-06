import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import 'package:study/features/parent/repository/parent_payment_repository.dart';
import 'package:study/features/parent/repository/parent_payment_repository_impl.dart';
import 'checkout/payment_checkout_screen.dart';
import 'history/payment_history_screen.dart';
import 'invoice_detail/payment_invoice_detail_screen.dart';
import 'result/payment_transaction_result_screen.dart';
import 'widgets/payment_all_clear_hero_card.dart';
import 'widgets/payment_child_filter_bar.dart';
import 'widgets/payment_due_hero_card.dart';
import 'widgets/recent_paid_invoice_card.dart';
import 'widgets/unpaid_invoice_card.dart';
import 'widgets/vat_tax_lookup_card.dart';

class ParentPaymentScreen extends StatefulWidget {
  const ParentPaymentScreen({
    super.key,
    this.repository,
    this.onOpenInvoiceDetail,
    this.onOpenCheckout,
    this.onOpenHistory,
  });

  final ParentPaymentRepository? repository;
  final void Function(ParentInvoiceModel invoice)? onOpenInvoiceDetail;
  final void Function(ParentInvoiceModel invoice)? onOpenCheckout;
  final VoidCallback? onOpenHistory;

  @override
  State<ParentPaymentScreen> createState() => _ParentPaymentScreenState();
}

class _ParentPaymentScreenState extends State<ParentPaymentScreen> {
  late final ParentPaymentRepository _repository;

  String? _selectedChildId; // null = Tất cả học sinh
  bool _forceActionableDueMode = false; // Toggle demo giữa All-Clear và Có nợ
  bool _isLoading = true;

  PaymentSummaryOverviewModel? _overview;
  List<ParentInvoiceModel> _allInvoices = [];

  final List<PaymentChildFilterItem> _filterItems = const [
    PaymentChildFilterItem(
      id: null,
      label: 'Tất cả học sinh',
      count: 2,
    ),
    PaymentChildFilterItem(
      id: 'student-minh-001',
      label: 'Quang Minh (10A1)',
    ),
    PaymentChildFilterItem(
      id: 'student-lan-002',
      label: 'Mai Lan (7C2)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ParentPaymentRepositoryImpl();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final overview = await _repository.getPaymentSummary(
      mockAllPaid: !_forceActionableDueMode,
    );
    final invoices = await _repository.getInvoices();
    if (!mounted) return;
    setState(() {
      _overview = overview;
      _allInvoices = invoices;
      _isLoading = false;
    });
  }

  List<ParentInvoiceModel> get _filteredInvoices {
    if (_selectedChildId == null) return _allInvoices;
    return _allInvoices
        .where((inv) => inv.childId == _selectedChildId)
        .toList();
  }

  List<ParentInvoiceModel> get _paidInvoices {
    return _filteredInvoices
        .where((inv) => inv.status == PaymentInvoiceStatus.paid)
        .toList();
  }

  List<ParentInvoiceModel> get _dueInvoices {
    return _filteredInvoices
        .where((inv) =>
            inv.status == PaymentInvoiceStatus.unpaid ||
            inv.status == PaymentInvoiceStatus.overdue ||
            inv.status == PaymentInvoiceStatus.dueSoon)
        .toList();
  }

  void _handleInvoiceDetail(ParentInvoiceModel invoice) {
    if (widget.onOpenInvoiceDetail != null) {
      widget.onOpenInvoiceDetail!(invoice);
    } else {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (ctx) => PaymentInvoiceDetailScreen(
            invoice: invoice,
            onCheckout: _handleCheckout,
          ),
        ),
      );
    }
  }

  void _handleCheckout(ParentInvoiceModel invoice) {
    if (widget.onOpenCheckout != null) {
      widget.onOpenCheckout!(invoice);
    } else {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (ctx) => PaymentCheckoutScreen(
            invoice: invoice,
            onPaymentCompleted: (result) {
              Navigator.pushReplacement<void, void>(
                ctx,
                MaterialPageRoute<void>(
                  builder: (resCtx) => PaymentTransactionResultScreen(
                    initialResult: result,
                    onReturnToPaymentHome: () {
                      Navigator.pop(resCtx);
                      _loadData();
                    },
                    onViewReceipt: (_) {
                      Navigator.push<void>(
                        resCtx,
                        MaterialPageRoute<void>(
                          builder: (_) => PaymentInvoiceDetailScreen(
                            invoice: invoice,
                          ),
                        ),
                      );
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

  void _handleOpenHistory() {
    if (widget.onOpenHistory != null) {
      widget.onOpenHistory!();
    } else {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (ctx) => PaymentHistoryScreen(
            onOpenInvoiceDetail: _handleInvoiceDetail,
          ),
        ),
      );
    }
  }

  void _handleDownloadReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đang tải Giấy xác nhận học phí và Biên lai điện tử VAT (PDF)...',
        ),
      ),
    );
  }

  void _handleVatLookup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đang kết nối cổng Hóa đơn điện tử VAT ngành Giáo dục...',
        ),
      ),
    );
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: surfaceBg,
        appBar: AppBar(
          backgroundColor: surfaceBg,
          title: const Text('Học phí & Thanh toán'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final overview = _overview ??
        const PaymentSummaryOverviewModel(
          totalDueAmount: 0,
          totalDueCount: 0,
          totalPaidAmount: 2400000,
          isAllPaid: true,
        );

    final showActionableDue = _forceActionableDueMode ||
        (!overview.isAllPaid && _dueInvoices.isNotEmpty);

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HỌC VỤ & TÀI CHÍNH',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Học phí & Thanh toán',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Nút đổi trạng thái mẫu All-Clear ↔ Có nợ quá hạn
          IconButton(
            tooltip: _forceActionableDueMode
                ? 'Đang xem: Có nợ quá hạn (Bấm để xem All-Clear)'
                : 'Đang xem: All-Clear (Bấm để xem Có nợ quá hạn)',
            icon: Icon(
              _forceActionableDueMode
                  ? Icons.check_circle_outline_rounded
                  : Icons.pending_actions_rounded,
              color: _forceActionableDueMode
                  ? const Color(0xFF15803D)
                  : const Color(0xFFDC2626),
            ),
            onPressed: () {
              setState(() {
                _forceActionableDueMode = !_forceActionableDueMode;
              });
              _loadData();
            },
          ),
          IconButton(
            tooltip: 'Lịch sử thanh toán',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: _handleOpenHistory,
          ),
          IconButton(
            tooltip: 'Thông báo học phí',
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không có thông báo mới về học phí'),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bộ lọc học sinh (Tất cả, Minh, Lan)
              PaymentChildFilterBar(
                items: _filterItems,
                selectedId: _selectedChildId,
                onChanged: (newId) {
                  setState(() => _selectedChildId = newId);
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 2. Hero Banner tương ứng theo trạng thái
                    if (showActionableDue)
                      PaymentDueHeroCard(
                        overview: _dueInvoices.isNotEmpty
                            ? PaymentSummaryOverviewModel(
                                totalDueAmount: _dueInvoices.fold(
                                  0.0,
                                  (sum, item) => sum + item.totalAmount,
                                ),
                                totalDueCount: _dueInvoices.length,
                                totalPaidAmount: overview.totalPaidAmount,
                                isAllPaid: false,
                              )
                            : overview,
                        onPayNow: () {
                          if (_dueInvoices.isNotEmpty) {
                            _handleCheckout(_dueInvoices.first);
                          }
                        },
                      )
                    else
                      PaymentAllClearHeroCard(
                        overview: overview,
                        onDownloadConfirmationReceipt: _handleDownloadReceipt,
                      ),

                    const SizedBox(height: 24),

                    // 3. Khối Khoản cần thanh toán (nếu có)
                    if (showActionableDue && _dueInvoices.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'KHOẢN CẦN THANH TOÁN',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_dueInvoices.length} khoản cần đóng',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._dueInvoices.map(
                        (inv) => UnpaidInvoiceCard(
                          invoice: inv,
                          onTapDetail: () => _handleInvoiceDetail(inv),
                          onPayNow: () => _handleCheckout(inv),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4. Khối Khoản đã thanh toán gần nhất (Thiết kế 2)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'KHOẢN ĐÃ THANH TOÁN GẦN NHẤT',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_paidInvoices.length} khoản hoàn tất',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_paidInvoices.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        child: const Text(
                          'Chưa có khoản thanh toán nào cho học sinh này',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      )
                    else
                      ..._paidInvoices.map(
                        (inv) => RecentPaidInvoiceCard(
                          invoice: inv,
                          onTap: () => _handleInvoiceDetail(inv),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // 5. Khối Hóa đơn điện tử VAT (Thiết kế 2)
                    VatTaxLookupCard(
                      onLookupTap: _handleVatLookup,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
