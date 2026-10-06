import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/home/widgets/parent_no_child_view.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/features/parent/repository/parent_payment_repository.dart';
import 'package:study/features/parent/repository/parent_payment_repository_impl.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/theme/theme.dart';
import 'checkout/payment_checkout_screen.dart';
import 'history/payment_history_screen.dart';
import 'invoice_detail/payment_invoice_detail_screen.dart';
import 'result/payment_transaction_result_screen.dart';
import 'widgets/payment_all_clear_hero_card.dart';
import 'widgets/payment_due_hero_card.dart';
import 'widgets/recent_paid_invoice_card.dart';
import 'widgets/unpaid_invoice_card.dart';
import 'widgets/vat_tax_lookup_card.dart';

class ParentPaymentScreen extends StatefulWidget {
  const ParentPaymentScreen({
    super.key,
    this.repository,
    this.onNavigateToProfile,
    this.onOpenInvoiceDetail,
    this.onOpenCheckout,
    this.onOpenHistory,
  });

  final ParentPaymentRepository? repository;
  final VoidCallback? onNavigateToProfile;
  final void Function(ParentInvoiceModel invoice)? onOpenInvoiceDetail;
  final void Function(ParentInvoiceModel invoice)? onOpenCheckout;
  final VoidCallback? onOpenHistory;

  @override
  State<ParentPaymentScreen> createState() => _ParentPaymentScreenState();
}

class _ParentPaymentScreenState extends State<ParentPaymentScreen> {
  late final ParentPaymentRepository _repository;

  List<FamilyScopeChild> _children = [];
  String? _selectedChildId; // null = Tất cả học sinh
  bool _forceActionableDueMode = false; // Toggle demo giữa All-Clear và Có nợ
  bool _isLoading = true;

  PaymentSummaryOverviewModel? _overview;
  List<ParentInvoiceModel> _allInvoices = [];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        (diContainer.isRegistered<ParentPaymentRepository>()
            ? diContainer<ParentPaymentRepository>()
            : ParentPaymentRepositoryImpl(
                apiClient: diContainer.isRegistered<ParentHomeApiClient>()
                    ? diContainer<ParentHomeApiClient>()
                    : null,
                enablePreviewFallback: true,
              ));
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _repository.getChildren();
      final overview = await _repository.getPaymentSummary(
        childId: _selectedChildId,
        mockAllPaid: !_forceActionableDueMode,
      );
      final invoices = await _repository.getInvoices(
        childId: _selectedChildId,
      );
      if (!mounted) return;
      setState(() {
        _children = children;
        _overview = overview;
        _allInvoices = invoices;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String? get _selectedChildName {
    if (_selectedChildId == null) return null;
    try {
      return _children.firstWhere((c) => c.id == _selectedChildId).name;
    } catch (_) {
      return null;
    }
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

  void _openManageChildren(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManageChildrenScreen(),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationScreen(),
      ),
    );
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
    final overview = _overview;
    if (overview != null && overview.totalPaidAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Học sinh chưa có biên lai hoặc giao dịch thanh toán nào '
            'được ghi nhận trong kỳ.',
          ),
        ),
      );
      return;
    }

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

    if (_isLoading && _children.isEmpty) {
      return Scaffold(
        backgroundColor: surfaceBg,
        body: SafeArea(
          child: Column(
            children: [
              ParentAppHeader(
                icon: Icons.account_balance_wallet_rounded,
                categoryLabel: 'HỌC VỤ & TÀI CHÍNH',
                title: 'Học phí & Thanh toán',
                onNotificationTap: () => _openNotifications(context),
                onAvatarTap: widget.onNavigateToProfile,
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Trường hợp phụ huynh chưa liên kết tài khoản con
    if (_children.isEmpty) {
      return Scaffold(
        backgroundColor: surfaceBg,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ParentAppHeader(
                  icon: Icons.account_balance_wallet_rounded,
                  categoryLabel: 'HỌC VỤ & TÀI CHÍNH',
                  title: 'Học phí & Thanh toán',
                  onNotificationTap: () => _openNotifications(context),
                  onAvatarTap: widget.onNavigateToProfile,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 24,
                  ),
                  child: ParentNoChildView(
                    onLinkChild: () => _openManageChildren(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final overview = _overview ??
        const PaymentSummaryOverviewModel(
          totalDueAmount: 0,
          totalDueCount: 0,
          totalPaidAmount: 0,
          isAllPaid: true,
          allPaidMessage: 'Học sinh hiện không có khoản học phí nào cần đóng.',
        );

    final showActionableDue = _forceActionableDueMode ||
        (!overview.isAllPaid && _dueInvoices.isNotEmpty);

    final hasNoInvoicesAtAll = _dueInvoices.isEmpty && _paidInvoices.isEmpty;

    return Scaffold(
      backgroundColor: surfaceBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Header chuẩn đồng bộ với Trang chủ, Lịch và Học tập
              SliverToBoxAdapter(
                child: ParentAppHeader(
                  icon: Icons.account_balance_wallet_rounded,
                  categoryLabel: 'HỌC VỤ & TÀI CHÍNH',
                  title: 'Học phí & Thanh toán',
                  onNotificationTap: () => _openNotifications(context),
                  onAvatarTap: widget.onNavigateToProfile,
                ),
              ),

              // 2. GHIM THANH CHỌN CON (Sticky Pinned Header)
              SliverPersistentHeader(
                pinned: true,
                delegate: PinnedFamilyScopeHeaderDelegate(
                  backgroundColor: surfaceBg,
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: FamilyScopeSelector(
                      children: _children,
                      selectedChildId: _selectedChildId,
                      showAllOption: true,
                      onSelected: (childId) {
                        setState(() => _selectedChildId = childId);
                        _loadData();
                      },
                      onLinkChild: () => _openManageChildren(context),
                    ),
                  ),
                ),
              ),

              // 3. Nội dung chính tab Học phí
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Thanh tác vụ phụ (Lịch sử thanh toán & Demo toggle)
                    _buildSubToolbar(context, cs),
                    const SizedBox(height: 12),

                    // Hero Banner tương ứng theo trạng thái
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

                    // Empty State khi con không có hóa đơn nào (ví dụ con thật)
                    if (hasNoInvoicesAtAll) ...[
                      _buildEmptyInvoicesCard(cs),
                      const SizedBox(height: 20),
                    ] else ...[
                      // Khối Khoản cần thanh toán (nếu có)
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
                        const SizedBox(height: 20),
                      ],

                      // Khối Khoản đã thanh toán gần nhất
                      if (_paidInvoices.isNotEmpty) ...[
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
                        ..._paidInvoices.map(
                          (inv) => RecentPaidInvoiceCard(
                            invoice: inv,
                            onTap: () => _handleInvoiceDetail(inv),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],

                    // Khối Hóa đơn điện tử VAT (Thiết kế 2)
                    VatTaxLookupCard(
                      onLookupTap: _handleVatLookup,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Thanh tác vụ phụ gồm xem lịch sử thanh toán và nút chuyển đổi demo All-Clear / Có nợ
  Widget _buildSubToolbar(BuildContext context, ColorScheme cs) {
    return Row(
      children: [
        // Nút mở Lịch sử thanh toán
        InkWell(
          onTap: _handleOpenHistory,
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
                Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: cs.primary,
                ),
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
          onTap: () {
            setState(() {
              _forceActionableDueMode = !_forceActionableDueMode;
            });
            _loadData();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _forceActionableDueMode
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _forceActionableDueMode
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFBBF7D0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _forceActionableDueMode
                      ? Icons.pending_actions_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 14,
                  color: _forceActionableDueMode
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF15803D),
                ),
                const SizedBox(width: 5),
                Text(
                  _forceActionableDueMode
                      ? 'Demo: Có nợ quá hạn'
                      : 'Demo: Tất toán',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _forceActionableDueMode
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

  /// Empty State Card khi con được chọn chưa phát sinh hóa đơn nào
  Widget _buildEmptyInvoicesCard(ColorScheme cs) {
    final childName = _selectedChildName;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 26,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có thông tin học phí',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            childName != null
                ? 'Học sinh $childName hiện chưa phát sinh hóa đơn '
                    'cần thanh toán hoặc lịch sử biên lai trong kỳ này.'
                : 'Hiện không có hóa đơn học phí cần thanh toán '
                    'hoặc lịch sử giao dịch trong kỳ này.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
