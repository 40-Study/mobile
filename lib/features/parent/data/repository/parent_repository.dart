import 'package:study/features/parent/data/models/models.dart';

/// Repository interface for parent-related data operations.
abstract class ParentRepository {
  /// Fetches list of children for the parent.
  Future<List<ChildModel>> getChildren();

  /// Fetches notifications for the parent.
  Future<List<ParentNotificationModel>> getNotifications({int limit = 5});

  /// Fetches classes for a specific child.
  Future<List<ChildClassModel>> getChildClasses(String studentId);

  /// Fetches attendance records for a child in a class.
  Future<List<ChildAttendanceModel>> getChildAttendances({
    required String classId,
    String? studentId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches all attendance records for a child across all classes.
  Future<List<ChildAttendanceModel>> getAllChildAttendances({
    required String studentId,
    String? dateFrom,
    String? dateTo,
  });

  /// Fetches online course enrollments for a child.
  Future<List<ChildEnrollmentModel>> getChildEnrollments(String userId);

  /// Fetches a specific child's details.
  Future<ChildModel> getChildDetail(String childId);

  /// Fetches tracking overview for a child (focus, assignments, performance, attendance).
  Future<TrackingOverviewModel> getTrackingOverview(String childId);

  /// Fetches finance overview for the parent.
  Future<ParentFinanceOverviewModel> getFinanceOverview({String? childId});

  /// Fetches portfolio for a specific child.
  Future<PortfolioModel> getPortfolio(String childId);

  /// Creates a payment for a pending payment.
  Future<PaymentHistoryModel> createPayment(CreatePaymentRequest request);

  /// Fetches available payment methods.
  Future<List<PaymentMethodModel>> getPaymentMethods();
}
