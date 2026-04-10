import 'package:flutter/foundation.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/parent_api_client.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';

class ParentRepositoryImpl implements ParentRepository {
  ParentRepositoryImpl({required ParentApiClient apiClient})
      : _api = apiClient;

  final ParentApiClient _api;

  /// Enable mock data when API fails (for development).
  static const _useMockOnError = true;

  @override
  Future<List<ChildModel>> getChildren() async {
    try {
      final response = await _api.getChildren();
      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'children') ??
          _parseList(data, 'data');

      if (items == null || items.isEmpty) {
        if (_useMockOnError) return _getMockChildren();
        return [];
      }

      return items
          .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getChildren error: $e');
      if (_useMockOnError) return _getMockChildren();
      rethrow;
    }
  }

  /// Mock children theo API DOCS - GET /me/children
  /// Response: { children: [ChildDto], total, page, page_size }
  List<ChildModel> _getMockChildren() {
    return const [
      ChildModel(
        // API fields theo API_DOCS.md
        id: 'child-001',
        username: 'nguyenvanb',
        fullName: 'Nguyen Van B',
        avatarUrl: 'https://i.pravatar.cc/150?u=child1',
        relationship: 'parent', // parent|guardian|grandparent
        // Extended fields for app
        name: 'Nguyen Van B',
        grade: 'Lop 10A1',
        school: 'Truong THPT ABC',
        attendanceRate: 0.90,
        averageScore: 8.5,
        classCount: 3,
        studentId: 'student-001',
        userId: 'user-child-001',
      ),
      ChildModel(
        id: 'child-002',
        username: 'nguyenthic',
        fullName: 'Nguyen Thi C',
        avatarUrl: 'https://i.pravatar.cc/150?u=child2',
        relationship: 'parent',
        name: 'Nguyen Thi C',
        grade: 'Lop 8A2',
        school: 'Truong THCS XYZ',
        attendanceRate: 0.95,
        averageScore: 9.0,
        classCount: 2,
        studentId: 'student-002',
        userId: 'user-child-002',
      ),
    ];
  }

  @override
  Future<List<ParentNotificationModel>> getNotifications({
    int limit = 5,
  }) async {
    // TODO: Replace with actual notification API when available
    // Return mock data for now
    return [
      const ParentNotificationModel(
        id: '1',
        title: 'Nguyen Van B vang buoi hoc ngay 23/03/2024',
        type: NotificationType.attendance,
        childId: '1',
        childName: 'Nguyen Van B',
        createdAt: '2 gio truoc',
      ),
      const ParentNotificationModel(
        id: '2',
        title: 'Nguyen Thi C dat diem 10 bai kiem tra Toan',
        type: NotificationType.performance,
        childId: '2',
        childName: 'Nguyen Thi C',
        createdAt: 'Hom qua',
      ),
      const ParentNotificationModel(
        id: '3',
        title: 'Lich hop phu huynh: 30/03/2024',
        type: NotificationType.general,
        createdAt: '2 ngay truoc',
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<ChildClassModel>> getChildClasses(String studentId) async {
    try {
      final response = await _api.getClasses(studentId: studentId);
      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'classes') ??
          _parseList(data, 'data');

      if (items == null || items.isEmpty) {
        if (_useMockOnError) return _getMockClasses();
        return [];
      }

      return items
          .map((e) => ChildClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getChildClasses error: $e');
      if (_useMockOnError) return _getMockClasses();
      rethrow;
    }
  }

  List<ChildClassModel> _getMockClasses() {
    return const [
      ChildClassModel(
        id: '1',
        name: 'Lop Toan 10A1',
        description: 'Lop Toan nang cao cho hoc sinh khoi 10',
        teacherName: 'Thay Nguyen Van A',
        studentCount: 25,
        maxStudents: 30,
        status: 'active',
      ),
      ChildClassModel(
        id: '2',
        name: 'Lop Anh Van',
        description: 'Lop Anh van giao tiep',
        teacherName: 'Co Tran Thi B',
        studentCount: 20,
        maxStudents: 25,
        status: 'active',
      ),
      ChildClassModel(
        id: '3',
        name: 'Lop Vat Ly',
        description: 'Lop Vat ly co ban',
        teacherName: 'Thay Le Van C',
        studentCount: 28,
        maxStudents: 30,
        status: 'active',
      ),
    ];
  }

  @override
  Future<List<ChildAttendanceModel>> getChildAttendances({
    required String classId,
    String? studentId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.getClassAttendances(
        classId,
        studentId: studentId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        pageSize: pageSize,
      );
      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'attendances') ??
          _parseList(data, 'data');

      if (items == null || items.isEmpty) {
        if (_useMockOnError) return _getMockAttendances();
        return [];
      }

      return items
          .map((e) => ChildAttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getChildAttendances error: $e');
      if (_useMockOnError) return _getMockAttendances();
      rethrow;
    }
  }

  @override
  Future<List<ChildAttendanceModel>> getAllChildAttendances({
    required String studentId,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      // Get all classes first
      final classes = await getChildClasses(studentId);
      if (classes.isEmpty) {
        if (_useMockOnError) return _getMockAttendances();
        return [];
      }

      // Get attendances from all classes
      final allAttendances = <ChildAttendanceModel>[];
      for (final cls in classes) {
        try {
          final attendances = await getChildAttendances(
            classId: cls.id,
            studentId: studentId,
            dateFrom: dateFrom,
            dateTo: dateTo,
          );
          // Add class name to each attendance
          for (final att in attendances) {
            allAttendances.add(ChildAttendanceModel(
              id: att.id,
              date: att.date,
              classId: cls.id,
              className: cls.name,
              status: att.status,
              note: att.note,
              createdAt: att.createdAt,
            ));
          }
        } catch (_) {
          // Skip if class attendance fails
        }
      }

      if (allAttendances.isEmpty && _useMockOnError) {
        return _getMockAttendances();
      }

      // Sort by date descending
      allAttendances.sort((a, b) => b.date.compareTo(a.date));

      return allAttendances;
    } catch (e) {
      debugPrint('getAllChildAttendances error: $e');
      if (_useMockOnError) return _getMockAttendances();
      rethrow;
    }
  }

  List<ChildAttendanceModel> _getMockAttendances() {
    return const [
      ChildAttendanceModel(
        id: '1',
        date: '2024-03-25',
        classId: '1',
        className: 'Toan 10A1',
        status: 'present',
      ),
      ChildAttendanceModel(
        id: '2',
        date: '2024-03-24',
        classId: '1',
        className: 'Toan 10A1',
        status: 'present',
      ),
      ChildAttendanceModel(
        id: '3',
        date: '2024-03-23',
        classId: '1',
        className: 'Toan 10A1',
        status: 'absent',
        note: 'Khong phep',
      ),
      ChildAttendanceModel(
        id: '4',
        date: '2024-03-22',
        classId: '1',
        className: 'Toan 10A1',
        status: 'present',
      ),
      ChildAttendanceModel(
        id: '5',
        date: '2024-03-21',
        classId: '2',
        className: 'Anh Van',
        status: 'late',
        note: '10 phut',
      ),
    ];
  }

  @override
  Future<List<ChildEnrollmentModel>> getChildEnrollments(String userId) async {
    try {
      final response = await _api.getEnrollments(userId: userId);
      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'enrollments') ??
          _parseList(data, 'data');

      if (items == null || items.isEmpty) {
        if (_useMockOnError) return _getMockEnrollments();
        return [];
      }

      return items
          .map((e) => ChildEnrollmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getChildEnrollments error: $e');
      if (_useMockOnError) return _getMockEnrollments();
      rethrow;
    }
  }

  List<ChildEnrollmentModel> _getMockEnrollments() {
    return const [
      ChildEnrollmentModel(
        id: '1',
        courseId: 'course-1',
        courseName: 'Lap trinh Python co ban',
        courseDescription: 'Khoa hoc lap trinh Python danh cho nguoi moi bat dau',
        progress: 75.0,
        status: 'active',
      ),
      ChildEnrollmentModel(
        id: '2',
        courseId: 'course-2',
        courseName: 'Tieng Anh giao tiep',
        courseDescription: 'Khoa hoc Tieng Anh giao tiep hang ngay',
        progress: 45.0,
        status: 'active',
      ),
    ];
  }

  @override
  Future<ChildModel> getChildDetail(String childId) async {
    try {
      final children = await getChildren();
      final child = children.firstWhere(
        (c) => c.id == childId,
        orElse: () => throw Exception('Child not found'),
      );
      return child;
    } catch (e) {
      debugPrint('getChildDetail error: $e');
      if (_useMockOnError) {
        return _getMockChildren().first;
      }
      rethrow;
    }
  }

  @override
  Future<TrackingOverviewModel> getTrackingOverview(String childId) async {
    // TODO: Replace with actual API when available
    return _getMockTrackingOverview();
  }

  TrackingOverviewModel _getMockTrackingOverview() {
    return TrackingOverviewModel(
      focusTracking: FocusTrackingModel(
        averageFocus: 78.5,
        totalSessions: 24,
        sessions: [
          FocusSessionModel(
            id: '1',
            date: '2024-03-25',
            className: 'Toán 10A1',
            focusScore: 85.0,
            durationMinutes: 90,
          ),
          FocusSessionModel(
            id: '2',
            date: '2024-03-24',
            className: 'Anh Văn',
            focusScore: 72.0,
            durationMinutes: 60,
          ),
          FocusSessionModel(
            id: '3',
            date: '2024-03-23',
            className: 'Vật Lý',
            focusScore: 90.0,
            durationMinutes: 75,
          ),
        ],
        bestSession: const FocusSessionModel(
          id: '3',
          date: '2024-03-23',
          className: 'Vật Lý',
          focusScore: 90.0,
          durationMinutes: 75,
        ),
        worstSession: const FocusSessionModel(
          id: '2',
          date: '2024-03-24',
          className: 'Anh Văn',
          focusScore: 72.0,
          durationMinutes: 60,
        ),
      ),
      assignmentProgress: AssignmentProgressModel(
        totalAssignments: 15,
        completedCount: 12,
        missingCount: 1,
        lateCount: 2,
        pendingCount: 0,
        assignments: [
          ChildAssignmentModel(
            id: '1',
            title: 'Bài tập Toán Chương 3',
            className: 'Toán 10A1',
            status: AssignmentStatus.completed,
            score: 9.5,
            maxScore: 10,
            dueDate: '2024-03-20',
            teacherFeedback: 'Làm bài rất tốt!',
          ),
          ChildAssignmentModel(
            id: '2',
            title: 'Essay Writing',
            className: 'Anh Văn',
            status: AssignmentStatus.late,
            score: 8.0,
            maxScore: 10,
            dueDate: '2024-03-18',
          ),
          ChildAssignmentModel(
            id: '3',
            title: 'Thí nghiệm Vật Lý',
            className: 'Vật Lý',
            status: AssignmentStatus.missing,
            dueDate: '2024-03-15',
          ),
        ],
      ),
      performanceOverview: PerformanceOverviewModel(
        averageScore: 8.5,
        highestScore: 10.0,
        lowestScore: 7.0,
        performances: [
          ChildPerformanceModel(
            id: '1',
            title: 'Kiểm tra 15 phút - Toán',
            score: 10.0,
            maxScore: 10.0,
            className: 'Toán 10A1',
            date: '2024-03-22',
          ),
          ChildPerformanceModel(
            id: '2',
            title: 'Kiểm tra 1 tiết - Anh Văn',
            score: 8.0,
            maxScore: 10.0,
            className: 'Anh Văn',
            date: '2024-03-20',
          ),
          ChildPerformanceModel(
            id: '3',
            title: 'Kiểm tra giữa kỳ - Vật Lý',
            score: 7.5,
            maxScore: 10.0,
            className: 'Vật Lý',
            date: '2024-03-15',
          ),
        ],
      ),
      attendanceSummary: const AttendanceSummaryModel(
        totalSessions: 40,
        presentCount: 35,
        absentCount: 2,
        lateCount: 2,
        excusedCount: 1,
        attendanceRate: 0.875,
      ),
      teacherInfo: const TeacherInfoModel(
        id: '1',
        name: 'Nguyễn Văn A',
        email: 'nguyenvana@school.edu.vn',
        phone: '0901234567',
        yearsOfExperience: 10,
        specialization: 'Toán học - Đại số & Giải tích',
      ),
    );
  }

  @override
  Future<ParentFinanceOverviewModel> getFinanceOverview({
    String? childId,
  }) async {
    // TODO: Replace with actual API when available
    return _getMockFinanceOverview();
  }

  ParentFinanceOverviewModel _getMockFinanceOverview() {
    return ParentFinanceOverviewModel(
      totalTuition: 15000000,
      paidAmount: 10000000,
      remainingAmount: 5000000,
      nextDueDate: '2024-04-15',
      pendingPayments: [
        PendingPaymentModel(
          id: '1',
          amount: 3000000,
          dueDate: '2024-04-15',
          childName: 'Nguyễn Văn B',
          courseName: 'Học phí tháng 4/2024',
        ),
        PendingPaymentModel(
          id: '2',
          amount: 2000000,
          dueDate: '2024-03-25',
          childName: 'Nguyễn Thị C',
          courseName: 'Khóa học Tiếng Anh',
          isOverdue: true,
        ),
      ],
      paymentHistory: [
        PaymentHistoryModel(
          id: '1',
          amount: 3000000,
          paymentDate: '2024-03-15',
          status: PaymentStatus.completed,
          paymentMethod: 'Chuyển khoản ngân hàng',
          childName: 'Nguyễn Văn B',
          courseName: 'Học phí tháng 3/2024',
          transactionId: 'TXN123456',
        ),
        PaymentHistoryModel(
          id: '2',
          amount: 2000000,
          paymentDate: '2024-03-10',
          status: PaymentStatus.completed,
          paymentMethod: 'Ví MoMo',
          childName: 'Nguyễn Thị C',
          courseName: 'Học phí tháng 3/2024',
          transactionId: 'TXN123457',
        ),
        PaymentHistoryModel(
          id: '3',
          amount: 5000000,
          paymentDate: '2024-02-15',
          status: PaymentStatus.completed,
          paymentMethod: 'Thẻ tín dụng',
          childName: 'Nguyễn Văn B',
          courseName: 'Học phí tháng 2/2024',
          transactionId: 'TXN123458',
        ),
      ],
    );
  }

  @override
  Future<PortfolioModel> getPortfolio(String childId) async {
    // TODO: Replace with actual API when available
    return _getMockPortfolio(childId);
  }

  PortfolioModel _getMockPortfolio(String childId) {
    return PortfolioModel(
      childId: childId,
      childName: 'Nguyễn Văn B',
      totalItems: 8,
      highlightedCount: 3,
      items: [
        PortfolioItemModel(
          id: '1',
          title: 'Bài tập Toán - Chương 3',
          type: PortfolioItemType.assignment,
          score: 9.5,
          maxScore: 10,
          teacherFeedback: 'Làm bài rất tốt, trình bày rõ ràng',
          className: 'Toán 10A1',
          createdAt: '2024-03-20',
          isHighlighted: true,
        ),
        PortfolioItemModel(
          id: '2',
          title: 'Dự án Web App',
          type: PortfolioItemType.project,
          score: 95,
          maxScore: 100,
          teacherFeedback: 'Dự án sáng tạo, code sạch',
          className: 'Lập trình Web',
          createdAt: '2024-03-15',
          isHighlighted: true,
        ),
        PortfolioItemModel(
          id: '3',
          title: 'Bài kiểm tra giữa kỳ',
          type: PortfolioItemType.test,
          score: 8.5,
          maxScore: 10,
          teacherFeedback: 'Cần cải thiện phần lý thuyết',
          className: 'Vật lý 10',
          createdAt: '2024-03-10',
        ),
      ],
    );
  }

  @override
  Future<PaymentHistoryModel> createPayment(CreatePaymentRequest request) async {
    // TODO: Replace with actual API when available
    return PaymentHistoryModel(
      id: 'new-payment',
      amount: request.amount,
      paymentDate: DateTime.now().toString(),
      status: PaymentStatus.completed,
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    // TODO: Replace with actual API when available
    return [
      const PaymentMethodModel(
        id: '1',
        name: 'Chuyển khoản ngân hàng',
        type: PaymentMethodType.bankTransfer,
        isDefault: true,
      ),
      const PaymentMethodModel(
        id: '2',
        name: 'Ví MoMo',
        type: PaymentMethodType.eWallet,
      ),
      const PaymentMethodModel(
        id: '3',
        name: 'Thẻ tín dụng/Ghi nợ',
        type: PaymentMethodType.creditCard,
      ),
    ];
  }

  /// Helper to parse list from response data.
  List<dynamic>? _parseList(dynamic data, String key) {
    if (data is Map<String, dynamic>) {
      final value = data[key];
      if (value is List<dynamic>) return value;

      // Check nested data
      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedValue = nestedData[key];
        if (nestedValue is List<dynamic>) return nestedValue;
      }
    }
    if (data is List<dynamic>) return data;
    return null;
  }
}
