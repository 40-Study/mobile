import 'dart:async';

import 'package:flutter/material.dart';
import 'package:study/core/logger/app_logger.dart';
import 'package:study/features/auth/data/models/user_model.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/repository/parent_payment_repository.dart';

class ParentPaymentRepositoryImpl implements ParentPaymentRepository {
  ParentPaymentRepositoryImpl({
    ParentHomeApiClient? apiClient,
    this.enablePreviewFallback = true,
  }) : _apiClient = apiClient;

  final ParentHomeApiClient? _apiClient;
  final bool enablePreviewFallback;

  static const String studentTungId = '31843f49-fd61-47aa-af78-d1badbdcce52';
  static const String studentMinhId = 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732';
  static const String studentLanId = 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad';

  bool _isMockChild(String? childId) =>
      childId == studentMinhId || childId == studentLanId;

  @override
  Future<List<FamilyScopeChild>> getChildren() async {
    var realChildren = <FamilyScopeChild>[];
    try {
      realChildren = await _fetchRealChildren();
    } catch (e, stackTrace) {
      if (!enablePreviewFallback) {
        rethrow;
      }
      AppLogger.w(
        'ParentPayment: fetch real children failed, fallback to mock',
        e,
      );
      AppLogger.d('ParentPayment children stackTrace', stackTrace);
    }

    if (enablePreviewFallback) {
      return _mergeWithMockChildren(realChildren);
    }
    return realChildren;
  }

  Future<List<FamilyScopeChild>> _fetchRealChildren() async {
    final api = _apiClient;
    if (api == null) return [];
    try {
      final response = await api.getChildren().timeout(
            const Duration(seconds: 10),
          );
      final data = _extractData(response.data);
      final list = _extractList(data, keys: ['children', 'items']);
      return list
          .asMap()
          .entries
          .map(
            (e) => FamilyScopeChild.fromUserModel(
              UserModel.fromJson(e.value as Map<String, dynamic>),
              index: e.key,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.w('ParentPayment: fetch real children failed', e);
      AppLogger.d('ParentPayment children stackTrace', stackTrace);
      rethrow;
    }
  }

  List<FamilyScopeChild> _mergeWithMockChildren(List<FamilyScopeChild> real) {
    final list = <FamilyScopeChild>[];

    if (real.isNotEmpty) {
      list.addAll(real);
    } else {
      list.add(
        FamilyScopeChild.sample(
          id: studentTungId,
          name: 'Mai Hoàng Tùng',
          className: '12A',
        ),
      );
    }

    if (!list.any((c) => c.id == studentMinhId)) {
      list.add(
        const FamilyScopeChild(
          id: studentMinhId,
          name: 'Minh',
          className: '10A1',
          initialLetter: 'M',
          badgeColor: Color(0xFFDBEAFE),
        ),
      );
    }
    if (!list.any((c) => c.id == studentLanId)) {
      list.add(
        const FamilyScopeChild(
          id: studentLanId,
          name: 'Lan',
          className: '7B',
          initialLetter: 'L',
          badgeColor: Color(0xFFFCE7F3),
        ),
      );
    }

    return list;
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  List<dynamic> _extractList(dynamic data, {List<String> keys = const []}) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        if (data[key] is List) return data[key] as List<dynamic>;
      }
      if (data['items'] is List) return data['items'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<PaymentSummaryOverviewModel> getPaymentSummary({
    String? childId,
    bool mockAllPaid = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Con thật chưa có dữ liệu học phí phát sinh
    if (childId != null && !_isMockChild(childId)) {
      return const PaymentSummaryOverviewModel(
        totalDueAmount: 0.0,
        totalDueCount: 0,
        totalPaidAmount: 0.0,
        isAllPaid: true,
        allPaidMessage:
            'Học sinh hiện không có khoản học phí nào cần thanh toán.',
        completionPercentText: 'Hoàn tất 100%',
        nextTermName: 'Học kỳ II',
        nextTermEstimatedDate: 'Dự kiến 01/2025',
        recentPaidCount: 0,
      );
    }

    // Chọn học sinh mẫu Minh
    if (childId == studentMinhId) {
      if (mockAllPaid) {
        return const PaymentSummaryOverviewModel(
          totalDueAmount: 0.0,
          totalDueCount: 0,
          totalPaidAmount: 1400000.0,
          isAllPaid: true,
          allPaidMessage:
              'Tất cả học phí của Nguyễn Nhật Minh trong '
              'Học kỳ I đã được thanh toán đầy đủ.',
          completionPercentText: 'Hoàn tất 100%',
          nextTermName: 'Học kỳ II',
          nextTermEstimatedDate: 'Dự kiến 01/2025',
          recentPaidCount: 1,
        );
      }
      return const PaymentSummaryOverviewModel(
        totalDueAmount: 1100000.0,
        totalDueCount: 1,
        totalPaidAmount: 1400000.0,
        isAllPaid: false,
        allPaidMessage:
            'Nguyễn Nhật Minh có 1 khoản học phí quá hạn '
            'cần hoàn tất thanh toán.',
        completionPercentText: 'Hoàn tất 56%',
        nextTermName: 'Học kỳ II',
        nextTermEstimatedDate: 'Dự kiến 01/2025',
        recentPaidCount: 1,
      );
    }

    // Chọn học sinh mẫu Lan
    if (childId == studentLanId) {
      return const PaymentSummaryOverviewModel(
        totalDueAmount: 0.0,
        totalDueCount: 0,
        totalPaidAmount: 1000000.0,
        isAllPaid: true,
        allPaidMessage:
            'Tất cả học phí của Nguyễn Mai Lan trong '
            'Học kỳ I đã được thanh toán đầy đủ.',
        completionPercentText: 'Hoàn tất 100%',
        nextTermName: 'Học kỳ II',
        nextTermEstimatedDate: 'Dự kiến 01/2025',
        recentPaidCount: 1,
      );
    }

    // Tất cả học sinh (childId == null)
    if (mockAllPaid) {
      // Đúng chuẩn theo Thiết kế 2 (All-Clear)
      return const PaymentSummaryOverviewModel(
        totalDueAmount: 0.0,
        totalDueCount: 0,
        totalPaidAmount: 2400000.0,
        isAllPaid: true,
        allPaidMessage:
            'Tất cả học phí và dịch vụ học tập của Minh & Lan trong '
            'Học kỳ I đã được thanh toán đầy đủ.',
        completionPercentText: 'Hoàn tất 100%',
        nextTermName: 'Học kỳ II',
        nextTermEstimatedDate: 'Dự kiến 01/2025',
        recentPaidCount: 2,
      );
    }

    // Trạng thái khi còn khoản nợ quá hạn (Thiết kế 1)
    return const PaymentSummaryOverviewModel(
      totalDueAmount: 1100000.0,
      totalDueCount: 1,
      totalPaidAmount: 2400000.0,
      isAllPaid: false,
      allPaidMessage:
          'Gia đình có 1 khoản học phí quá hạn cần hoàn tất thanh toán.',
      completionPercentText: 'Hoàn tất 68%',
      nextTermName: 'Học kỳ II',
      nextTermEstimatedDate: 'Dự kiến 01/2025',
      recentPaidCount: 2,
    );
  }

  @override
  Future<List<ParentInvoiceModel>> getInvoices({
    String? childId,
    PaymentInvoiceStatus? status,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (childId != null && !_isMockChild(childId)) {
      return [];
    }

    final list = _generateSampleInvoices();

    return list.where((inv) {
      if (childId != null && inv.childId != childId) {
        return false;
      }
      if (status != null && inv.status != status) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<ParentInvoiceModel?> getInvoiceDetail(String invoiceId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final list = _generateSampleInvoices();
    try {
      return list.firstWhere((inv) => inv.id == invoiceId);
    } catch (_) {
      return list.first;
    }
  }

  @override
  Future<PaymentTransactionResult> submitPayment({
    required String invoiceId,
    required PaymentMethodType method,
    required String idempotencyKey,
    VatInvoiceRequestInfo? vatInfo,
  }) async {
    // Giả lập độ trễ kết nối cổng thanh toán
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return PaymentTransactionResult(
      transactionId: 'TXN-2026-99120',
      invoiceId: invoiceId,
      amount: 1400000.0,
      status: PaymentTransactionStatus.success,
      statusTitle: 'Thanh toán thành công',
      message:
          'Học phí môn Toán nâng cao 10 của học sinh Nguyễn Nhật Minh '
          'đã được hệ thống xác nhận thanh toán thành công qua VietQR.',
      paymentMethod: method,
      timestamp: DateTime.now(),
      idempotencyKey: idempotencyKey,
      receiptPdfUrl: 'https://cdn.fortex.edu.vn/receipts/TXN-99120.pdf',
      vatInfo: vatInfo,
    );
  }

  @override
  Future<PaymentTransactionResult> checkPaymentStatus(
    String transactionId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return PaymentTransactionResult(
      transactionId: transactionId,
      invoiceId: 'inv-minh-toan-6',
      amount: 1400000.0,
      status: PaymentTransactionStatus.success,
      statusTitle: 'Giao dịch hoàn tất',
      message: 'Khoản thu đã được cập nhật thành công vào hệ thống học vụ.',
      paymentMethod: PaymentMethodType.vietQr,
      timestamp: DateTime.now(),
      idempotencyKey: 'idemp-$transactionId',
    );
  }

  @override
  Future<List<ParentInvoiceModel>> getPaymentHistory({
    String? childId,
    int? year,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (childId != null && !_isMockChild(childId)) {
      return [];
    }

    final list = _generateSampleInvoices()
        .where((inv) => inv.status == PaymentInvoiceStatus.paid)
        .toList();

    if (childId != null) {
      return list.where((inv) => inv.childId == childId).toList();
    }
    return list;
  }

  List<ParentInvoiceModel> _generateSampleInvoices() {
    return const [
      // Hóa đơn 1 (Minh - Thiết kế 1 & Thiết kế 2)
      ParentInvoiceModel(
        id: 'inv-minh-toan-6',
        invoiceCode: '#INV-2026-06-M01',
        childId: studentMinhId,
        childName: 'Nguyễn Nhật Minh',
        childInitials: 'QM',
        className: '10A1',
        title: 'Minh — Học phí tháng 6',
        courseName: 'Toán học nâng cao & Luyện đề',
        teacherName: 'ThS. Hoàng Minh Tuấn',
        durationText: '12 buổi (Tháng 6/2026)',
        dueDateText: '15/06/2026',
        paidDateText: '15/06/2026',
        transactionCode: 'TXN-99120',
        status: PaymentInvoiceStatus.paid,
        statusLabel: 'Đã đóng',
        overdueDays: 5,
        originalAmount: 1600000.0,
        discountAmount: 200000.0,
        totalAmount: 1400000.0,
        lineItems: [
          InvoiceLineItem(
            name: 'Học phí gốc (12 buổi)',
            amount: 1600000.0,
          ),
          InvoiceLineItem(
            name: 'Ưu đãi học bổng chăm chỉ (10%)',
            amount: -200000.0,
            isDiscount: true,
            note: 'Áp dụng cho học sinh chuyên cần >90%',
          ),
        ],
        hasVatInvoice: true,
        policyNote:
            'Lưu ý: Học sinh có thể bị tạm ngưng tham gia '
            'các buổi học tương tác nếu học phí quá hạn quá 7 ngày. '
            'Phụ huynh vui lòng hoàn tất sớm để đảm bảo việc học của con.',
      ),

      // Hóa đơn 2 (Lan - Thiết kế 2)
      ParentInvoiceModel(
        id: 'inv-lan-anh-6',
        invoiceCode: '#INV-2026-06-L02',
        childId: studentLanId,
        childName: 'Nguyễn Mai Lan',
        childInitials: 'ML',
        className: '7C2',
        title: 'Lan — Học phí tháng 6',
        courseName: 'Tiếng Anh Giao Tiếp 7',
        teacherName: 'Thầy David Nam',
        durationText: '10 buổi (Tháng 6/2026)',
        dueDateText: '14/06/2026',
        paidDateText: '14/06/2026',
        transactionCode: 'TXN-99084',
        status: PaymentInvoiceStatus.paid,
        statusLabel: 'Đã đóng',
        originalAmount: 1200000.0,
        discountAmount: 200000.0,
        totalAmount: 1000000.0,
        lineItems: [
          InvoiceLineItem(
            name: 'Học phí khóa Tiếng Anh Giao Tiếp (10 buổi)',
            amount: 1200000.0,
          ),
          InvoiceLineItem(
            name: 'Ưu đãi đăng ký nhóm bạn học',
            amount: -200000.0,
            isDiscount: true,
          ),
        ],
        hasVatInvoice: true,
      ),

      // Hóa đơn 3 (Minh - Khoản cần thanh toán đợt tới để test luồng Unpaid/Overdue)
      ParentInvoiceModel(
        id: 'inv-minh-ly-7',
        invoiceCode: '#INV-2026-07-M03',
        childId: studentMinhId,
        childName: 'Nguyễn Nhật Minh',
        childInitials: 'QM',
        className: '10A1',
        title: 'Minh — Chuyên đề Vật lý 10 nâng cao',
        courseName: 'Vật lý 10 Chuyên sâu & Thực nghiệm',
        teacherName: 'ThS. Nguyễn Văn Hưng',
        durationText: '8 buổi (Tháng 7/2026)',
        dueDateText: '25/07/2026',
        status: PaymentInvoiceStatus.overdue,
        statusLabel: '• ĐÃ QUÁ HẠN (3 NGÀY)',
        overdueDays: 3,
        originalAmount: 1200000.0,
        discountAmount: 100000.0,
        totalAmount: 1100000.0,
        lineItems: [
          InvoiceLineItem(
            name: 'Học phí chuyên đề Vật lý (8 buổi)',
            amount: 1200000.0,
          ),
          InvoiceLineItem(
            name: 'Hỗ trợ phụ huynh có 2 con theo học',
            amount: -100000.0,
            isDiscount: true,
          ),
        ],
        hasVatInvoice: true,
        policyNote:
            'Lưu ý: Học sinh có thể bị tạm ngưng tham gia '
            'các buổi học tương tác nếu học phí quá hạn quá 7 ngày.',
      ),
    ];
  }
}
