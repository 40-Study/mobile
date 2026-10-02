import 'package:flutter/material.dart';

/// Trạng thái của hóa đơn / khoản thu học phí
enum PaymentInvoiceStatus {
  unpaid, // Chưa thanh toán
  dueSoon, // Sắp tới hạn
  overdue, // Đã quá hạn
  paid, // Đã thanh toán hoàn tất
  processing, // Đang xử lý giao dịch
}

/// Các phương thức thanh toán hỗ trợ
enum PaymentMethodType {
  vietQr, // Chuyển khoản ngân hàng VietQR (Napas247)
  atmCard, // Thẻ ATM nội địa / Internet Banking
  eWallet, // Ví điện tử (MoMo, ZaloPay, VNPay)
  creditCard, // Thẻ quốc tế Visa / MasterCard
}

/// Trạng thái kết quả giao dịch thanh toán
enum PaymentTransactionStatus {
  success, // Giao dịch thành công
  failed, // Giao dịch thất bại
  pending, // Đang xử lý / Chờ đối soát
  unknown, // Không rõ kết quả / Hết thời gian chờ (Timeout)
}

/// Mục chi tiết chi phí (Line Item) trong hóa đơn
@immutable
class InvoiceLineItem {
  const InvoiceLineItem({
    required this.name,
    required this.amount,
    this.isDiscount = false,
    this.note,
  });

  final String name; // Tên khoản (VD: "Học phí gốc (12 buổi)")
  final double amount; // Số tiền (VD: 1600000 hoặc -200000)
  final bool isDiscount; // Có phải khoản giảm trừ/học bổng không
  final String? note; // Ghi chú thêm
}

/// Model Hóa đơn / Khoản thu học phí chi tiết
@immutable
class ParentInvoiceModel {
  const ParentInvoiceModel({
    required this.id,
    required this.invoiceCode,
    required this.childId,
    required this.childName,
    required this.childInitials,
    required this.className,
    required this.title,
    required this.courseName,
    required this.teacherName,
    required this.durationText,
    required this.dueDateText,
    this.paidDateText,
    this.transactionCode,
    required this.status,
    required this.statusLabel,
    this.overdueDays,
    required this.lineItems,
    required this.originalAmount,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.hasVatInvoice = true,
    this.vatInvoicePdfUrl,
    this.policyNote,
  });

  final String id;
  final String invoiceCode; // VD: "#INV-2026-06-M01"
  final String childId;
  final String childName; // VD: "Nguyễn Nhật Minh", "Quang Minh"
  final String childInitials; // VD: "QM", "ML"
  final String className; // VD: "10A1", "7C2"
  final String title; // VD: "Minh — Học phí tháng 6"
  final String courseName; // VD: "Toán học nâng cao & Luyện đề"
  final String teacherName; // VD: "ThS. Hoàng Minh Tuấn"
  final String durationText; // VD: "12 buổi (Tháng 6/2026)"
  final String dueDateText; // VD: "15/06/2026"
  final String? paidDateText; // VD: "15/06/2026"
  final String? transactionCode; // VD: "TXN-99120"
  final PaymentInvoiceStatus status;
  final String statusLabel; // VD: "Đã đóng", "• ĐÃ QUÁ HẠN (5 NGÀY)"
  final int? overdueDays; // VD: 5
  final List<InvoiceLineItem> lineItems;
  final double originalAmount; // VD: 1600000
  final double discountAmount; // VD: 200000
  final double totalAmount; // VD: 1400000
  final bool hasVatInvoice; // Có hóa đơn điện tử VAT không
  final String? vatInvoicePdfUrl;
  final String? policyNote; // Lưu ý quy chế ngưng học sau 7 ngày quá hạn
}

/// Dữ liệu tổng quan tài chính hiển thị tại Hero Card của Tab Học phí
@immutable
class PaymentSummaryOverviewModel {
  const PaymentSummaryOverviewModel({
    required this.totalDueAmount,
    required this.totalDueCount,
    required this.totalPaidAmount,
    required this.isAllPaid,
    this.allPaidMessage =
        'Tất cả học phí và dịch vụ học tập của Minh & Lan trong Học kỳ I '
        'đã được thanh toán đầy đủ.',
    this.completionPercentText = 'Hoàn tất 100%',
    this.nextTermName = 'Học kỳ II',
    this.nextTermEstimatedDate = 'Dự kiến 01/2025',
    this.recentPaidCount = 2,
  });

  /// Tổng tiền cần đóng hiện tại (VD: 0 hoặc 1400000)
  final double totalDueAmount;
  final int totalDueCount; // Số khoản cần thanh toán (VD: 0 hoặc 1)
  final double totalPaidAmount; // Tổng đã đóng kỳ này (VD: 2400000)
  final bool isAllPaid; // Đã hoàn tất nghĩa vụ kỳ này chưa
  final String allPaidMessage;
  final String completionPercentText;
  final String nextTermName;
  final String nextTermEstimatedDate;
  final int recentPaidCount;
}

/// Thông tin yêu cầu xuất hóa đơn GTGT (VAT)
@immutable
class VatInvoiceRequestInfo {
  const VatInvoiceRequestInfo({
    required this.companyName,
    required this.taxCode,
    required this.companyAddress,
    required this.email,
  });

  final String companyName;
  final String taxCode;
  final String companyAddress;
  final String email;
}

/// Kết quả giao dịch thanh toán (áp dụng chặt chẽ quy tắc Idempotency)
@immutable
class PaymentTransactionResult {
  const PaymentTransactionResult({
    required this.transactionId,
    required this.invoiceId,
    required this.amount,
    required this.status,
    required this.statusTitle,
    required this.message,
    required this.paymentMethod,
    required this.timestamp,
    required this.idempotencyKey,
    this.receiptPdfUrl,
    this.errorMessage,
    this.vatInfo,
  });

  final String transactionId; // VD: "TXN-2026-99120"
  final String invoiceId;
  final double amount;
  final PaymentTransactionStatus status;
  final String statusTitle; // VD: "Thanh toán thành công"
  final String message; // VD: "Đã ghi nhận thanh toán cho học sinh..."
  final PaymentMethodType paymentMethod;
  final DateTime timestamp;
  final String idempotencyKey;
  final String? receiptPdfUrl;
  final String? errorMessage;
  final VatInvoiceRequestInfo? vatInfo;
}
