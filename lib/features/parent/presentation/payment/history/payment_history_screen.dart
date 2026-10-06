import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/presentation/widgets/family_scope_selector.dart';
import 'package:study/features/parent/repository/parent_payment_repository.dart';
import 'package:study/features/parent/repository/parent_payment_repository_impl.dart';
import '../widgets/payment_formatters.dart';
import 'widgets/payment_history_card.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({
    super.key,
    this.repository,
    this.onOpenInvoiceDetail,
  });

  final ParentPaymentRepository? repository;
  final void Function(ParentInvoiceModel invoice)? onOpenInvoiceDetail;

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late final ParentPaymentRepository _repository;

  List<FamilyScopeChild> _children = [];
  String? _selectedChildId;
  int _selectedYear = 2026;
  bool _isLoading = true;
  List<ParentInvoiceModel> _historyInvoices = [];

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
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      if (_children.isEmpty) {
        _children = await _repository.getChildren();
      }
      final list = await _repository.getPaymentHistory(
        childId: _selectedChildId,
        year: _selectedYear,
      );
      if (!mounted) return;
      setState(() {
        _historyInvoices = list;
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

  void _handleSelectYear() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Chọn năm học',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Năm học 2025 - 2026'),
                  trailing: _selectedYear == 2026
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF1D4ED8),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedYear = 2026);
                    _loadHistory();
                  },
                ),
                ListTile(
                  title: const Text('Năm học 2024 - 2025'),
                  trailing: _selectedYear == 2025
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF1D4ED8),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedYear = 2025);
                    _loadHistory();
                  },
                ),
                ListTile(
                  title: const Text('Năm học 2023 - 2024'),
                  trailing: _selectedYear == 2024
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF1D4ED8),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedYear = 2024);
                    _loadHistory();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleDownloadReceipt(ParentInvoiceModel invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đang tải biên lai VAT cho mã hóa đơn ${invoice.invoiceCode}...',
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

    final totalAmount = _historyInvoices.fold<double>(
      0.0,
      (sum, item) => sum + item.totalAmount,
    );

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: const Text(
          'Lịch sử thanh toán',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _handleSelectYear,
            icon: const Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: Color(0xFF1D4ED8),
            ),
            label: Text(
              '$_selectedYear',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bộ lọc học sinh FamilyScopeSelector
          if (_children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: FamilyScopeSelector(
                children: _children,
                selectedChildId: _selectedChildId,
                showAllOption: true,
                onSelected: (id) {
                  setState(() => _selectedChildId = id);
                  _loadHistory();
                },
              ),
            ),

          // 2. Banner tóm tắt tổng tích lũy đã đóng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFBBF7D0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TỔNG ĐÃ THANH TOÁN',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatVnd(totalAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF86EFAC),
                      ),
                    ),
                    child: Text(
                      '${_historyInvoices.length} giao dịch',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 3. Danh sách các biên lai thanh toán
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _historyInvoices.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 56,
                                color: cs.outlineVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedChildName != null
                                    ? 'Chưa có giao dịch nào cho '
                                        '$_selectedChildName trong năm '
                                        '$_selectedYear'
                                    : 'Chưa có giao dịch nào trong năm '
                                        '$_selectedYear',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _historyInvoices.length,
                          itemBuilder: (ctx, i) {
                            final inv = _historyInvoices[i];
                            return PaymentHistoryCard(
                              invoice: inv,
                              onTapDetail: () {
                                if (widget.onOpenInvoiceDetail != null) {
                                  widget.onOpenInvoiceDetail!(inv);
                                }
                              },
                              onDownloadReceipt: () =>
                                  _handleDownloadReceipt(inv),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
