import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_payment_model.dart';

/// Interface quản lý dữ liệu và luồng giao dịch cho phân hệ Học phí (Payment)
abstract class ParentPaymentRepository {
  /// Lấy danh sách học sinh của phụ huynh
  /// (kết hợp con thật từ backend và con mẫu)
  Future<List<FamilyScopeChild>> getChildren();

  /// Lấy dữ liệu tổng quan tài chính hiển thị tại Hero Card
  /// [childId]: ID học sinh đang chọn (null = Tất cả con)
  /// [mockAllPaid]: cho phép chuyển đổi giữa trạng thái Đã hoàn tất nghĩa vụ
  /// (Thiết kế 2) và trạng thái Còn khoản cần đóng/quá hạn
  Future<PaymentSummaryOverviewModel> getPaymentSummary({
    String? childId,
    bool mockAllPaid = true,
  });

  /// Lấy danh sách các khoản phí (hóa đơn) theo điều kiện lọc
  Future<List<ParentInvoiceModel>> getInvoices({
    String? childId,
    PaymentInvoiceStatus? status,
  });

  /// Lấy thông tin chi tiết một hóa đơn / khoản thu cụ thể
  Future<ParentInvoiceModel?> getInvoiceDetail(String invoiceId);

  /// Khởi tạo và thực hiện thanh toán với Idempotency Key bảo toàn giao dịch
  Future<PaymentTransactionResult> submitPayment({
    required String invoiceId,
    required PaymentMethodType method,
    required String idempotencyKey,
    VatInvoiceRequestInfo? vatInfo,
  });

  /// Kiểm tra lại trạng thái giao dịch hiện hành
  /// (chỉ đọc, không tạo attempt mới)
  Future<PaymentTransactionResult> checkPaymentStatus(String transactionId);

  /// Lấy lịch sử các giao dịch đã hoàn tất qua các kỳ
  Future<List<ParentInvoiceModel>> getPaymentHistory({
    String? childId,
    int? year,
  });
}
