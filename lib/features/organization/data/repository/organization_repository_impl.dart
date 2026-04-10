import 'package:study/features/organization/data/models/models.dart';
import 'package:study/features/organization/data/repository/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  OrganizationRepositoryImpl();

  @override
  Future<OrgStatsModel> getStats() async {
    // TODO: Replace with actual API
    await Future.delayed(const Duration(milliseconds: 500));
    return const OrgStatsModel(
      totalTeachers: 24,
      totalStudents: 1256,
      totalCourses: 48,
      activeCourses: 35,
      monthlyRevenue: 125600000,
      revenueChangePercent: 12.5,
      newStudentsThisMonth: 89,
      newTeachersThisMonth: 3,
      // Cash flow analytics
      totalIncome: 185000000,
      totalExpense: 72000000,
      netProfit: 113000000,
      profitMargin: 61.1,
      pendingPayments: 32500000,
    );
  }

  @override
  Future<List<OrgActivityModel>> getActivities({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      OrgActivityModel(
        id: '1',
        title: 'Giáo viên mới tham gia',
        subtitle: 'Nguyễn Văn A đã tham gia tổ chức',
        type: OrgActivityType.newTeacher,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      OrgActivityModel(
        id: '2',
        title: 'Khóa học mới được tạo',
        subtitle: 'Lập trình Flutter cơ bản - GV Trần B',
        type: OrgActivityType.courseCreated,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      ),
      OrgActivityModel(
        id: '3',
        title: 'Học viên đăng ký khóa học',
        subtitle: 'Lê C đã đăng ký "Toán cao cấp"',
        type: OrgActivityType.coursePurchase,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      ),
      OrgActivityModel(
        id: '4',
        title: 'Thanh toán cho giáo viên',
        subtitle: 'Đã thanh toán 5,200,000đ cho GV Phạm D',
        type: OrgActivityType.payout,
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      OrgActivityModel(
        id: '5',
        title: 'Đánh giá mới',
        subtitle: 'Khóa "IELTS 7.0" nhận được 5 sao',
        type: OrgActivityType.review,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<OrgTeacherModel>> getTeachers({
    String? status,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var teachers = _getMockTeachers();

    if (status != null && status.isNotEmpty) {
      teachers = teachers.where((t) => t.status == status).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      teachers = teachers.where((t) =>
        t.name.toLowerCase().contains(query) ||
        (t.email?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return teachers;
  }

  @override
  Future<OrgTeacherModel> getTeacherDetail(String teacherId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockTeachers().firstWhere(
      (t) => t.id == teacherId,
      orElse: () => _getMockTeachers().first,
    );
  }

  @override
  Future<void> inviteTeacher(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Implement actual invitation logic
  }

  @override
  Future<void> updateTeacherStatus(String teacherId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Implement actual status update
  }

  @override
  Future<void> removeTeacher(String teacherId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: Implement actual removal
  }

  @override
  Future<List<OrgStudentModel>> getStudents({
    String? status,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var students = _getMockStudents();

    if (status != null && status.isNotEmpty) {
      students = students.where((s) => s.status == status).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      students = students.where((s) =>
        s.name.toLowerCase().contains(query) ||
        (s.email?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return students;
  }

  @override
  Future<OrgStudentModel> getStudentDetail(String studentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockStudents().firstWhere(
      (s) => s.id == studentId,
      orElse: () => _getMockStudents().first,
    );
  }

  @override
  Future<OrgFinanceModel> getFinanceOverview() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return OrgFinanceModel(
      // === REVENUE ===
      grossRevenue: 185000000,
      monthlyRevenue: 185000000,
      totalRevenue: 1856000000, // YTD
      courseRevenue: 156000000, // 84%
      subscriptionRevenue: 24000000, // 13%
      otherRevenue: 5000000, // 3%

      // === RECURRING REVENUE ===
      mrr: 185000000,
      arr: 2220000000,
      mrrGrowth: 8.5,
      newMrr: 25000000,
      expansionMrr: 12000000,
      churnedMrr: 8500000,
      netMrrChange: 28500000,

      // === CUSTOMER METRICS ===
      totalCustomers: 4580,
      newCustomers: 342,
      churnedCustomers: 98,
      activeCustomers: 3850,
      arpu: 48035,
      arppu: 65200,
      ltv: 1850000,
      cac: 285000,
      ltvCacRatio: 6.5,
      paybackMonths: 5.9,
      churnRate: 2.1,
      retentionRate: 97.9,
      nrr: 112.5,

      // === SALES METRICS ===
      totalOrders: 1256,
      avgOrderValue: 147292,
      conversionRate: 4.8,
      refundRate: 2.0,
      totalVisitors: 26167,
      payingConversion: 14.7,

      // === COURSE METRICS ===
      totalCoursesSold: 1845,
      avgCoursePrice: 1250000,
      revenuePerCourse: 84552,
      bestSellingCategory: 'Lap trinh',
      completionRate: 68.5,

      // === COGS ===
      teacherPayout: 55500000,
      platformFee: 18500000,
      paymentProcessingFee: 5550000,
      refunds: 3700000,

      // === OPEX ===
      marketingCost: 12950000,
      staffCost: 18500000,
      infrastructureCost: 5550000,
      otherOpex: 3700000,

      // === METRICS ===
      grossProfit: 101750000,
      grossMargin: 55.0,
      operatingIncome: 61050000,
      operatingMargin: 33.0,
      ebitda: 72200000,
      ebitdaMargin: 39.0,
      netIncome: 57850000,
      netMargin: 31.3,

      // === CASH FLOW ===
      pendingPayout: 32500000,
      totalPayout: 856000000,
      cashBalance: 245000000,
      accountsReceivable: 28500000,

      // === COMPARISON ===
      revenueChange: 12.5,
      expenseChange: 8.2,
      profitChange: 18.5,
      ebitdaChange: 15.3,
      customerChange: 5.3,
      arpuChange: 3.2,
      ltvChange: 8.7,

      // === CHART DATA ===
      revenueData: [142, 156, 148, 168, 175, 185],
      expenseData: [98, 105, 102, 112, 118, 123],
      profitData: [44, 51, 46, 56, 57, 62],
      mrrData: [152, 158, 165, 172, 178, 185],
      customerData: [3950, 4100, 4250, 4380, 4480, 4580],
      chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],

      // === COHORT DATA ===
      cohortRetention: [
        const CohortData(month: 'T1/24', initialCustomers: 450, retentionRates: [100, 85, 78, 72, 68, 65]),
        const CohortData(month: 'T2/24', initialCustomers: 520, retentionRates: [100, 88, 81, 75, 70]),
        const CohortData(month: 'T3/24', initialCustomers: 480, retentionRates: [100, 86, 79, 73]),
        const CohortData(month: 'T4/24', initialCustomers: 550, retentionRates: [100, 89, 82]),
        const CohortData(month: 'T5/24', initialCustomers: 510, retentionRates: [100, 87]),
        const CohortData(month: 'T6/24', initialCustomers: 580, retentionRates: [100]),
      ],

      // === TOP COURSES ===
      topCourses: [
        const TopCourseRevenue(id: '1', name: 'Flutter Mastery', teacherName: 'Nguyen Van A', revenue: 45000000, unitsSold: 156, growth: 25.5),
        const TopCourseRevenue(id: '2', name: 'IELTS 7.0 Complete', teacherName: 'Tran Thi B', revenue: 38500000, unitsSold: 128, growth: 18.2),
        const TopCourseRevenue(id: '3', name: 'Python AI/ML', teacherName: 'Le Van C', revenue: 32000000, unitsSold: 98, growth: 32.8),
        const TopCourseRevenue(id: '4', name: 'React Native Pro', teacherName: 'Pham Van D', revenue: 28500000, unitsSold: 85, growth: 15.6),
        const TopCourseRevenue(id: '5', name: 'Toan THPT Chuyen', teacherName: 'Hoang Thi E', revenue: 24000000, unitsSold: 220, growth: 12.3),
      ],

      // === TOP CATEGORIES ===
      topCategories: [
        const CategoryRevenue(name: 'Lap trinh', revenue: 78500000, percentage: 42.4, courseCount: 45, growth: 22.5),
        const CategoryRevenue(name: 'Ngoai ngu', revenue: 52000000, percentage: 28.1, courseCount: 32, growth: 15.8),
        const CategoryRevenue(name: 'Hoc tap', revenue: 32500000, percentage: 17.6, courseCount: 28, growth: 8.5),
        const CategoryRevenue(name: 'Kinh doanh', revenue: 15000000, percentage: 8.1, courseCount: 15, growth: 5.2),
        const CategoryRevenue(name: 'Khac', revenue: 7000000, percentage: 3.8, courseCount: 10, growth: 2.1),
      ],
    );
  }

  @override
  Future<List<OrgTransactionModel>> getTransactions({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      OrgTransactionModel(
        id: '1',
        title: 'Học viên mua khóa học',
        amount: 1500000,
        transactionType: 'income',
        studentName: 'Nguyễn Văn A',
        courseName: 'Lập trình Flutter',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      OrgTransactionModel(
        id: '2',
        title: 'Thanh toán cho giáo viên',
        amount: -850000,
        transactionType: 'payout',
        teacherName: 'Trần Văn B',
        description: 'Thanh toán doanh thu tháng 3',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      ),
      OrgTransactionModel(
        id: '3',
        title: 'Phí nền tảng',
        amount: -150000,
        transactionType: 'fee',
        description: 'Phí 10% đơn hàng #12345',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      ),
      OrgTransactionModel(
        id: '4',
        title: 'Học viên mua khóa học',
        amount: 2500000,
        transactionType: 'income',
        studentName: 'Lê Thị C',
        courseName: 'IELTS 7.0 Speaking',
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      OrgTransactionModel(
        id: '5',
        title: 'Hoàn tiền học viên',
        amount: -500000,
        transactionType: 'refund',
        studentName: 'Phạm Văn D',
        courseName: 'Toán cao cấp',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)).toIso8601String(),
      ),
    ];
  }

  @override
  Future<void> requestPayout(double amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Implement actual payout request
  }

  @override
  Future<List<CourseRevenueModel>> getCourseRevenue({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      const CourseRevenueModel(
        courseId: 'c3',
        courseName: 'Python cho Data Science',
        teacherName: 'Lê Minh Cường',
        totalRevenue: 42120000,
        totalStudents: 234,
        revenueChange: 25.5,
        isTrending: true,
      ),
      const CourseRevenueModel(
        courseId: 'c2',
        courseName: 'IELTS 7.0 Speaking',
        teacherName: 'Trần Thị Bình',
        totalRevenue: 35600000,
        totalStudents: 89,
        revenueChange: 18.2,
        isTrending: true,
      ),
      const CourseRevenueModel(
        courseId: 'c1',
        courseName: 'Lập trình Flutter cơ bản',
        teacherName: 'Nguyễn Văn An',
        totalRevenue: 23400000,
        totalStudents: 156,
        revenueChange: 8.5,
        isTrending: false,
      ),
      const CourseRevenueModel(
        courseId: 'c5',
        courseName: 'Toán cao cấp A1',
        teacherName: 'Phạm Thu Dung',
        totalRevenue: 8960000,
        totalStudents: 112,
        revenueChange: -5.2,
        isTrending: false,
      ),
      const CourseRevenueModel(
        courseId: 'c4',
        courseName: 'React Native nâng cao',
        teacherName: 'Nguyễn Văn An',
        totalRevenue: 4500000,
        totalStudents: 45,
        revenueChange: -12.8,
        isTrending: false,
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<TeacherRevenueModel>> getTeacherRevenue({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      const TeacherRevenueModel(
        teacherId: '3',
        teacherName: 'Lê Minh Cường',
        totalRevenue: 42120000,
        totalCourses: 8,
        totalStudents: 234,
        commissionRate: 0.7,
        pendingPayout: 12500000,
        revenueChange: 25.5,
        isTopPerformer: true,
      ),
      const TeacherRevenueModel(
        teacherId: '2',
        teacherName: 'Trần Thị Bình',
        totalRevenue: 35600000,
        totalCourses: 3,
        totalStudents: 89,
        commissionRate: 0.7,
        pendingPayout: 8900000,
        revenueChange: 18.2,
        isTopPerformer: true,
      ),
      const TeacherRevenueModel(
        teacherId: '1',
        teacherName: 'Nguyễn Văn An',
        totalRevenue: 27900000,
        totalCourses: 5,
        totalStudents: 201,
        commissionRate: 0.7,
        pendingPayout: 6200000,
        revenueChange: 5.8,
        isTopPerformer: false,
      ),
      const TeacherRevenueModel(
        teacherId: '5',
        teacherName: 'Hoàng Văn Em',
        totalRevenue: 11200000,
        totalCourses: 4,
        totalStudents: 112,
        commissionRate: 0.7,
        pendingPayout: 3200000,
        revenueChange: -2.5,
        isTopPerformer: false,
      ),
      const TeacherRevenueModel(
        teacherId: '4',
        teacherName: 'Phạm Thu Dung',
        totalRevenue: 4500000,
        totalCourses: 2,
        totalStudents: 45,
        commissionRate: 0.7,
        pendingPayout: 1800000,
        revenueChange: -15.3,
        isTopPerformer: false,
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<FinanceAlertModel>> getFinanceAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      FinanceAlertModel(
        id: 'alert1',
        title: 'Khóa học doanh thu giảm',
        message: 'React Native nâng cao giảm 12.8% so với tháng trước',
        type: FinanceAlertType.courseUnderperform,
        severity: FinanceAlertSeverity.warning,
        relatedId: 'c4',
        relatedName: 'React Native nâng cao',
        amount: -12.8,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      FinanceAlertModel(
        id: 'alert2',
        title: 'Hoàn tiền tăng đột biến',
        message: '5 yêu cầu hoàn tiền trong tuần này (tăng 150%)',
        type: FinanceAlertType.refundSpike,
        severity: FinanceAlertSeverity.critical,
        amount: 2500000,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      ),
      FinanceAlertModel(
        id: 'alert3',
        title: 'Thanh toán chờ xử lý',
        message: '32,500,000đ đang chờ thanh toán cho giáo viên',
        type: FinanceAlertType.pendingPayout,
        severity: FinanceAlertSeverity.info,
        amount: 32500000,
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      FinanceAlertModel(
        id: 'alert4',
        title: 'Giáo viên doanh thu thấp',
        message: 'Phạm Thu Dung giảm 15.3% doanh thu tháng này',
        type: FinanceAlertType.lowRevenue,
        severity: FinanceAlertSeverity.warning,
        relatedId: '4',
        relatedName: 'Phạm Thu Dung',
        amount: -15.3,
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      ),
    ];
  }

  // Mock data generators
  List<OrgTeacherModel> _getMockTeachers() {
    return [
      OrgTeacherModel(
        id: '1',
        name: 'Nguyễn Văn An',
        email: 'an.nguyen@email.com',
        phone: '0901234567',
        bio: 'Senior Flutter Developer với 8 năm kinh nghiệm',
        specialization: ['Flutter', 'Dart', 'Mobile'],
        totalCourses: 5,
        activeCourses: 4,
        draftCourses: 1,
        avgCourseRating: 4.8,
        totalReviews: 245,
        totalStudents: 156,
        activeStudents: 120,
        newStudentsThisMonth: 28,
        studentRetentionRate: 92.5,
        avgCompletionRate: 78.5,
        monthlyRevenue: 45600000,
        totalRevenue: 256000000,
        pendingPayout: 12500000,
        totalPayout: 180000000,
        revenueChange: 15.5,
        avgRevenuePerCourse: 9120000,
        avgRevenuePerStudent: 292307,
        rating: 4.8,
        responseRate: 95.0,
        avgResponseTimeMinutes: 45,
        engagementScore: 88.5,
        contentQualityScore: 92.0,
        totalLessons: 156,
        totalContentHours: 48.5,
        lessonsThisMonth: 12,
        status: 'active',
        verificationStatus: 'verified',
        joinedAt: '2024-01-15',
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        revenueTrend: [35, 38, 42, 40, 43, 45.6],
        studentsTrend: [120, 128, 135, 142, 150, 156],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
      ),
      OrgTeacherModel(
        id: '2',
        name: 'Trần Thị Bình',
        email: 'binh.tran@email.com',
        phone: '0902345678',
        bio: 'IELTS Expert - Band 8.5',
        specialization: ['IELTS', 'English', 'Speaking'],
        totalCourses: 3,
        activeCourses: 3,
        draftCourses: 0,
        avgCourseRating: 4.9,
        totalReviews: 189,
        totalStudents: 189,
        activeStudents: 145,
        newStudentsThisMonth: 35,
        studentRetentionRate: 94.2,
        avgCompletionRate: 82.3,
        monthlyRevenue: 38900000,
        totalRevenue: 198000000,
        pendingPayout: 8500000,
        totalPayout: 145000000,
        revenueChange: 22.3,
        avgRevenuePerCourse: 12966666,
        avgRevenuePerStudent: 205820,
        rating: 4.9,
        responseRate: 98.0,
        avgResponseTimeMinutes: 30,
        engagementScore: 94.0,
        contentQualityScore: 96.0,
        totalLessons: 144,
        totalContentHours: 52.0,
        lessonsThisMonth: 8,
        status: 'active',
        verificationStatus: 'verified',
        joinedAt: '2024-02-20',
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        revenueTrend: [28, 30, 32, 35, 37, 38.9],
        studentsTrend: [100, 115, 130, 155, 170, 189],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
      ),
      OrgTeacherModel(
        id: '3',
        name: 'Lê Minh Cường',
        email: 'cuong.le@email.com',
        phone: '0903456789',
        bio: 'Data Scientist tại Big Tech',
        specialization: ['Python', 'Data Science', 'AI/ML'],
        totalCourses: 8,
        activeCourses: 6,
        draftCourses: 2,
        avgCourseRating: 4.7,
        totalReviews: 320,
        totalStudents: 234,
        activeStudents: 180,
        newStudentsThisMonth: 42,
        studentRetentionRate: 88.5,
        avgCompletionRate: 72.1,
        monthlyRevenue: 63400000,
        totalRevenue: 425000000,
        pendingPayout: 18500000,
        totalPayout: 320000000,
        revenueChange: 8.5,
        avgRevenuePerCourse: 7925000,
        avgRevenuePerStudent: 270940,
        rating: 4.7,
        responseRate: 85.0,
        avgResponseTimeMinutes: 120,
        engagementScore: 78.0,
        contentQualityScore: 88.0,
        totalLessons: 280,
        totalContentHours: 96.0,
        lessonsThisMonth: 18,
        status: 'active',
        verificationStatus: 'verified',
        joinedAt: '2023-11-10',
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        revenueTrend: [52, 55, 58, 60, 62, 63.4],
        studentsTrend: [150, 170, 190, 210, 225, 234],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
      ),
      OrgTeacherModel(
        id: '4',
        name: 'Phạm Thu Dung',
        email: 'dung.pham@email.com',
        phone: '0904567890',
        bio: 'Giảng viên Toán học',
        specialization: ['Toán', 'THPT', 'Luyện thi'],
        totalCourses: 2,
        activeCourses: 1,
        draftCourses: 1,
        avgCourseRating: 4.6,
        totalReviews: 56,
        totalStudents: 45,
        activeStudents: 20,
        newStudentsThisMonth: 5,
        studentRetentionRate: 65.0,
        avgCompletionRate: 55.0,
        monthlyRevenue: 4500000,
        totalRevenue: 32000000,
        pendingPayout: 2500000,
        totalPayout: 25000000,
        revenueChange: -12.5,
        avgRevenuePerCourse: 2250000,
        avgRevenuePerStudent: 100000,
        rating: 4.6,
        responseRate: 70.0,
        avgResponseTimeMinutes: 240,
        engagementScore: 55.0,
        contentQualityScore: 72.0,
        totalLessons: 48,
        totalContentHours: 18.0,
        lessonsThisMonth: 2,
        status: 'inactive',
        verificationStatus: 'pending',
        joinedAt: '2024-03-01',
        lastActiveAt: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        revenueTrend: [8, 7, 6, 5.5, 5, 4.5],
        studentsTrend: [60, 55, 52, 48, 46, 45],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
      ),
      OrgTeacherModel(
        id: '5',
        name: 'Hoàng Văn Em',
        email: 'em.hoang@email.com',
        phone: '0905678901',
        bio: 'React Native & Web Developer',
        specialization: ['React', 'JavaScript', 'Web'],
        totalCourses: 4,
        activeCourses: 3,
        draftCourses: 1,
        avgCourseRating: 4.5,
        totalReviews: 145,
        totalStudents: 112,
        activeStudents: 85,
        newStudentsThisMonth: 18,
        studentRetentionRate: 78.5,
        avgCompletionRate: 68.0,
        monthlyRevenue: 21200000,
        totalRevenue: 125000000,
        pendingPayout: 6500000,
        totalPayout: 95000000,
        revenueChange: 5.8,
        avgRevenuePerCourse: 5300000,
        avgRevenuePerStudent: 189285,
        rating: 4.5,
        responseRate: 82.0,
        avgResponseTimeMinutes: 90,
        engagementScore: 72.0,
        contentQualityScore: 78.0,
        totalLessons: 98,
        totalContentHours: 35.0,
        lessonsThisMonth: 8,
        status: 'active',
        verificationStatus: 'verified',
        joinedAt: '2024-01-28',
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        revenueTrend: [18, 19, 19.5, 20, 20.5, 21.2],
        studentsTrend: [85, 90, 95, 102, 108, 112],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
      ),
    ];
  }

  List<OrgStudentModel> _getMockStudents() {
    return [
      OrgStudentModel(
        id: '1',
        name: 'Nguyễn Minh Anh',
        email: 'anh.nguyen@email.com',
        enrolledCourses: 3,
        completedCourses: 1,
        inProgressCourses: 2,
        droppedCourses: 0,
        avgCompletionRate: 65.5,
        totalLearningHours: 48.5,
        avgDailyLearningMinutes: 45,
        currentStreakDays: 12,
        longestStreakDays: 28,
        lessonsCompleted: 85,
        quizzesCompleted: 24,
        avgQuizScore: 82.5,
        certificatesEarned: 1,
        totalSpent: 4500000,
        monthlySpending: 1500000,
        lifetimeValue: 6500000,
        avgOrderValue: 1500000,
        totalOrders: 3,
        refundCount: 0,
        hasSubscription: false,
        engagementScore: 78.0,
        totalComments: 45,
        totalQuestions: 12,
        reviewsGiven: 2,
        avgRatingGiven: 4.8,
        forumPosts: 8,
        helpfulVotesReceived: 15,
        averageProgress: 65.5,
        weeklyProgressChange: 5.2,
        churnRisk: 'low',
        daysSinceLastActivity: 0,
        isAtRisk: false,
        status: 'active',
        membershipTier: 'premium',
        joinedAt: '2024-02-01',
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        lastPurchaseAt: DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        learningHoursTrend: [8, 10, 12, 9, 11, 10.5],
        progressTrend: [45, 50, 55, 58, 62, 65.5],
        spendingTrend: [1.5, 0, 1.5, 0, 1.5, 0],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
        favoriteCategories: ['Lap trinh', 'Flutter'],
      ),
      OrgStudentModel(
        id: '2',
        name: 'Trần Văn Bảo',
        email: 'bao.tran@email.com',
        enrolledCourses: 2,
        completedCourses: 2,
        inProgressCourses: 0,
        droppedCourses: 0,
        avgCompletionRate: 100,
        totalLearningHours: 85.0,
        avgDailyLearningMinutes: 60,
        currentStreakDays: 0,
        longestStreakDays: 45,
        lessonsCompleted: 120,
        quizzesCompleted: 35,
        avgQuizScore: 92.0,
        certificatesEarned: 2,
        totalSpent: 13000000,
        monthlySpending: 0,
        lifetimeValue: 15000000,
        avgOrderValue: 2166666,
        totalOrders: 6,
        refundCount: 0,
        hasSubscription: true,
        subscriptionPlan: 'Premium Yearly',
        engagementScore: 95.0,
        totalComments: 120,
        totalQuestions: 35,
        reviewsGiven: 6,
        avgRatingGiven: 4.9,
        forumPosts: 25,
        helpfulVotesReceived: 85,
        averageProgress: 100,
        weeklyProgressChange: 0,
        churnRisk: 'low',
        daysSinceLastActivity: 1,
        isAtRisk: false,
        status: 'active',
        membershipTier: 'premium',
        joinedAt: '2024-01-15',
        lastActiveAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        lastPurchaseAt: DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        learningHoursTrend: [15, 18, 20, 16, 12, 4],
        progressTrend: [60, 75, 85, 92, 98, 100],
        spendingTrend: [2.5, 2, 3, 2.5, 2, 1],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
        favoriteCategories: ['IELTS', 'Ngoai ngu'],
      ),
      OrgStudentModel(
        id: '3',
        name: 'Lê Thị Chi',
        email: 'chi.le@email.com',
        enrolledCourses: 5,
        completedCourses: 3,
        inProgressCourses: 2,
        droppedCourses: 0,
        avgCompletionRate: 78.2,
        totalLearningHours: 125.0,
        avgDailyLearningMinutes: 55,
        currentStreakDays: 25,
        longestStreakDays: 62,
        lessonsCompleted: 245,
        quizzesCompleted: 68,
        avgQuizScore: 88.5,
        certificatesEarned: 3,
        totalSpent: 17500000,
        monthlySpending: 2500000,
        lifetimeValue: 25000000,
        avgOrderValue: 2500000,
        totalOrders: 7,
        refundCount: 0,
        hasSubscription: true,
        subscriptionPlan: 'Premium Monthly',
        engagementScore: 92.0,
        totalComments: 180,
        totalQuestions: 55,
        reviewsGiven: 5,
        avgRatingGiven: 4.7,
        forumPosts: 45,
        helpfulVotesReceived: 120,
        averageProgress: 78.2,
        weeklyProgressChange: 8.5,
        churnRisk: 'low',
        daysSinceLastActivity: 0,
        isAtRisk: false,
        status: 'active',
        membershipTier: 'premium',
        joinedAt: '2023-12-20',
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        lastPurchaseAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        learningHoursTrend: [18, 20, 22, 25, 20, 20],
        progressTrend: [45, 52, 60, 68, 74, 78.2],
        spendingTrend: [3, 2.5, 3.5, 3, 2.5, 3],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
        favoriteCategories: ['Data Science', 'Python', 'AI'],
      ),
      OrgStudentModel(
        id: '4',
        name: 'Phạm Đức Dũng',
        email: 'dung.pham@email.com',
        enrolledCourses: 1,
        completedCourses: 0,
        inProgressCourses: 0,
        droppedCourses: 1,
        avgCompletionRate: 25.0,
        totalLearningHours: 8.0,
        avgDailyLearningMinutes: 10,
        currentStreakDays: 0,
        longestStreakDays: 5,
        lessonsCompleted: 12,
        quizzesCompleted: 3,
        avgQuizScore: 65.0,
        certificatesEarned: 0,
        totalSpent: 1500000,
        monthlySpending: 0,
        lifetimeValue: 1500000,
        avgOrderValue: 1500000,
        totalOrders: 1,
        refundCount: 0,
        hasSubscription: false,
        engagementScore: 25.0,
        totalComments: 5,
        totalQuestions: 2,
        reviewsGiven: 0,
        avgRatingGiven: 0,
        forumPosts: 0,
        helpfulVotesReceived: 0,
        averageProgress: 25.0,
        weeklyProgressChange: -5.0,
        churnRisk: 'high',
        daysSinceLastActivity: 35,
        isAtRisk: true,
        status: 'inactive',
        membershipTier: 'free',
        joinedAt: '2024-03-10',
        lastActiveAt: DateTime.now().subtract(const Duration(days: 35)).toIso8601String(),
        lastPurchaseAt: DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
        learningHoursTrend: [3, 2, 2, 1, 0, 0],
        progressTrend: [15, 20, 23, 25, 25, 25],
        spendingTrend: [1.5, 0, 0, 0, 0, 0],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
        favoriteCategories: ['Lap trinh'],
      ),
      OrgStudentModel(
        id: '5',
        name: 'Hoàng Mai Hương',
        email: 'huong.hoang@email.com',
        enrolledCourses: 4,
        completedCourses: 2,
        inProgressCourses: 1,
        droppedCourses: 1,
        avgCompletionRate: 55.8,
        totalLearningHours: 65.0,
        avgDailyLearningMinutes: 35,
        currentStreakDays: 3,
        longestStreakDays: 18,
        lessonsCompleted: 95,
        quizzesCompleted: 28,
        avgQuizScore: 78.0,
        certificatesEarned: 2,
        totalSpent: 6000000,
        monthlySpending: 1000000,
        lifetimeValue: 8500000,
        avgOrderValue: 1500000,
        totalOrders: 4,
        refundCount: 1,
        hasSubscription: false,
        engagementScore: 62.0,
        totalComments: 35,
        totalQuestions: 18,
        reviewsGiven: 3,
        avgRatingGiven: 4.2,
        forumPosts: 12,
        helpfulVotesReceived: 25,
        averageProgress: 55.8,
        weeklyProgressChange: 2.5,
        churnRisk: 'medium',
        daysSinceLastActivity: 3,
        isAtRisk: false,
        status: 'active',
        membershipTier: 'free',
        joinedAt: '2024-02-28',
        lastActiveAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        lastPurchaseAt: DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        learningHoursTrend: [12, 14, 10, 8, 11, 10],
        progressTrend: [35, 42, 48, 52, 54, 55.8],
        spendingTrend: [2, 1.5, 1, 0.5, 1, 0],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
        favoriteCategories: ['Web', 'React'],
      ),
      OrgStudentModel(
        id: '6',
        name: 'Vũ Quốc Khánh',
        email: 'khanh.vu@email.com',
        enrolledCourses: 2,
        completedCourses: 0,
        inProgressCourses: 1,
        droppedCourses: 1,
        avgCompletionRate: 15.0,
        totalLearningHours: 5.0,
        avgDailyLearningMinutes: 8,
        currentStreakDays: 0,
        longestStreakDays: 3,
        lessonsCompleted: 8,
        quizzesCompleted: 2,
        avgQuizScore: 55.0,
        certificatesEarned: 0,
        totalSpent: 2500000,
        monthlySpending: 0,
        lifetimeValue: 2500000,
        avgOrderValue: 1250000,
        totalOrders: 2,
        refundCount: 1,
        hasSubscription: false,
        engagementScore: 18.0,
        totalComments: 2,
        totalQuestions: 1,
        reviewsGiven: 0,
        avgRatingGiven: 0,
        forumPosts: 0,
        helpfulVotesReceived: 0,
        averageProgress: 15.0,
        weeklyProgressChange: -2.0,
        churnRisk: 'high',
        daysSinceLastActivity: 21,
        isAtRisk: true,
        status: 'inactive',
        membershipTier: 'free',
        joinedAt: '2024-04-01',
        lastActiveAt: DateTime.now().subtract(const Duration(days: 21)).toIso8601String(),
        lastPurchaseAt: DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
        learningHoursTrend: [2, 1.5, 1, 0.5, 0, 0],
        progressTrend: [8, 12, 14, 15, 15, 15],
        spendingTrend: [1.5, 1, 0, 0, 0, 0],
        chartLabels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
        favoriteCategories: ['Lap trinh'],
      ),
    ];
  }

  // ==========================================================================
  // COURSES - Mock data theo API DOCS
  // ==========================================================================

  @override
  Future<List<OrgCourseModel>> getCourses({
    String? status,
    String? instructorId,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var courses = _getMockCourses();

    if (status != null && status.isNotEmpty) {
      courses = courses.where((c) => c.status == status).toList();
    }

    if (instructorId != null && instructorId.isNotEmpty) {
      courses = courses.where((c) => c.instructorId == instructorId).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      courses = courses.where((c) =>
        c.title.toLowerCase().contains(query) ||
        (c.shortDescription?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return courses;
  }

  @override
  Future<OrgCourseModel> getCourseDetail(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockCourses().firstWhere(
      (c) => c.id == courseId,
      orElse: () => _getMockCourses().first,
    );
  }

  @override
  Future<OrgCourseModel> createCourse({
    required String title,
    required String instructorId,
    String? categoryId,
    String? shortDescription,
    String? price,
    String? level,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: trả về course mới
    return OrgCourseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      instructorId: instructorId,
      title: title,
      slug: title.toLowerCase().replaceAll(' ', '-'),
      shortDescription: shortDescription,
      categoryId: categoryId,
      price: price ?? '0',
      level: level ?? 'beginner',
      status: 'draft',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<OrgCourseModel> updateCourse(String courseId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final course = await getCourseDetail(courseId);
    // Mock: trả về course đã update
    return course;
  }

  @override
  Future<void> publishCourse(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> archiveCourse(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  List<OrgCourseModel> _getMockCourses() {
    final teachers = _getMockTeachers();
    return [
      OrgCourseModel(
        id: 'c1',
        instructorId: '1',
        categoryId: 'cat1',
        title: 'Lập trình Flutter cơ bản',
        slug: 'lap-trinh-flutter-co-ban',
        shortDescription: 'Khóa học Flutter cho người mới bắt đầu',
        thumbnailUrl: 'https://picsum.photos/seed/flutter/400/225',
        level: 'beginner',
        price: '1500000',
        discountPrice: '999000',
        totalDurationMinutes: 480,
        totalLessons: 32,
        totalStudents: 156,
        averageRating: '4.8',
        totalReviews: 45,
        requirements: ['Biết sử dụng máy tính', 'Có kiến thức lập trình cơ bản'],
        objectives: ['Xây dựng ứng dụng mobile với Flutter', 'Hiểu về Dart'],
        status: 'published',
        publishedAt: '2024-01-15T00:00:00Z',
        isFeatured: true,
        instructor: OrgCourseInstructor(
          id: '1',
          name: teachers[0].name,
          bio: '10 năm kinh nghiệm',
        ),
        category: const OrgCourseCategory(
          id: 'cat1',
          name: 'Lập trình',
          slug: 'lap-trinh',
        ),
        tags: const [
          OrgCourseTag(id: 't1', name: 'Flutter', slug: 'flutter'),
          OrgCourseTag(id: 't2', name: 'Dart', slug: 'dart'),
        ],
        createdAt: '2024-01-01T00:00:00Z',
      ),
      OrgCourseModel(
        id: 'c2',
        instructorId: '2',
        categoryId: 'cat2',
        title: 'IELTS 7.0 Speaking',
        slug: 'ielts-7-speaking',
        shortDescription: 'Luyện thi IELTS Speaking band 7.0+',
        thumbnailUrl: 'https://picsum.photos/seed/ielts/400/225',
        level: 'intermediate',
        price: '2500000',
        totalDurationMinutes: 720,
        totalLessons: 48,
        totalStudents: 89,
        averageRating: '4.9',
        totalReviews: 32,
        status: 'published',
        publishedAt: '2024-02-20T00:00:00Z',
        instructor: OrgCourseInstructor(
          id: '2',
          name: teachers[1].name,
          bio: 'IELTS 8.5',
        ),
        category: const OrgCourseCategory(
          id: 'cat2',
          name: 'Ngoại ngữ',
          slug: 'ngoai-ngu',
        ),
        tags: const [
          OrgCourseTag(id: 't3', name: 'IELTS', slug: 'ielts'),
          OrgCourseTag(id: 't4', name: 'Speaking', slug: 'speaking'),
        ],
        createdAt: '2024-02-01T00:00:00Z',
      ),
      OrgCourseModel(
        id: 'c3',
        instructorId: '3',
        categoryId: 'cat1',
        title: 'Python cho Data Science',
        slug: 'python-data-science',
        shortDescription: 'Phân tích dữ liệu với Python',
        thumbnailUrl: 'https://picsum.photos/seed/python/400/225',
        level: 'intermediate',
        price: '1800000',
        discountPrice: '1200000',
        totalDurationMinutes: 600,
        totalLessons: 40,
        totalStudents: 234,
        averageRating: '4.7',
        totalReviews: 78,
        status: 'published',
        publishedAt: '2023-11-10T00:00:00Z',
        isFeatured: true,
        instructor: OrgCourseInstructor(
          id: '3',
          name: teachers[2].name,
          bio: 'Data Scientist',
        ),
        createdAt: '2023-10-01T00:00:00Z',
      ),
      OrgCourseModel(
        id: 'c4',
        instructorId: '1',
        categoryId: 'cat1',
        title: 'React Native nâng cao',
        slug: 'react-native-nang-cao',
        shortDescription: 'Xây dựng ứng dụng mobile chuyên nghiệp',
        thumbnailUrl: 'https://picsum.photos/seed/react/400/225',
        level: 'advanced',
        price: '2000000',
        totalDurationMinutes: 540,
        totalLessons: 36,
        totalStudents: 45,
        averageRating: '4.6',
        totalReviews: 15,
        status: 'draft',
        instructor: OrgCourseInstructor(
          id: '1',
          name: teachers[0].name,
        ),
        createdAt: '2024-03-01T00:00:00Z',
      ),
      OrgCourseModel(
        id: 'c5',
        instructorId: '4',
        categoryId: 'cat3',
        title: 'Toán cao cấp A1',
        slug: 'toan-cao-cap-a1',
        shortDescription: 'Giải tích và đại số tuyến tính',
        thumbnailUrl: 'https://picsum.photos/seed/math/400/225',
        level: 'all_levels',
        price: '800000',
        totalDurationMinutes: 360,
        totalLessons: 24,
        totalStudents: 112,
        averageRating: '4.5',
        totalReviews: 28,
        status: 'published',
        isFree: false,
        instructor: OrgCourseInstructor(
          id: '4',
          name: teachers[3].name,
        ),
        category: const OrgCourseCategory(
          id: 'cat3',
          name: 'Toán học',
          slug: 'toan-hoc',
        ),
        createdAt: '2024-01-28T00:00:00Z',
      ),
    ];
  }

  // ==========================================================================
  // CLASSES - Mock data theo API DOCS
  // ==========================================================================

  @override
  Future<List<OrgClassModel>> getClasses({
    String? status,
    String? teacherId,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var classes = _getMockClasses();

    if (status != null && status.isNotEmpty) {
      classes = classes.where((c) => c.status == status).toList();
    }

    if (teacherId != null && teacherId.isNotEmpty) {
      classes = classes.where((c) => c.teacherId == teacherId).toList();
    }

    return classes;
  }

  @override
  Future<OrgClassModel> createClass({
    required String name,
    required String teacherId,
    String? courseId,
    String? description,
    int? maxStudents,
    String? schedule,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return OrgClassModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      teacherId: teacherId,
      courseId: courseId,
      description: description,
      maxStudents: maxStudents,
      schedule: schedule,
      status: 'active',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  List<OrgClassModel> _getMockClasses() {
    final teachers = _getMockTeachers();
    final courses = _getMockCourses();
    return [
      OrgClassModel(
        id: 'cl1',
        name: 'Flutter K1 - Tối T2/T4/T6',
        description: 'Lớp Flutter buổi tối cho người đi làm',
        teacherId: '1',
        teacherName: teachers[0].name,
        courseId: 'c1',
        courseName: courses[0].title,
        totalStudents: 25,
        maxStudents: 30,
        status: 'active',
        startDate: '2024-04-01',
        endDate: '2024-06-30',
        schedule: 'T2, T4, T6 - 19:00',
        createdAt: '2024-03-15T00:00:00Z',
      ),
      OrgClassModel(
        id: 'cl2',
        name: 'IELTS Speaking - Sáng CN',
        description: 'Lớp luyện Speaking cuối tuần',
        teacherId: '2',
        teacherName: teachers[1].name,
        courseId: 'c2',
        courseName: courses[1].title,
        totalStudents: 15,
        maxStudents: 20,
        status: 'active',
        startDate: '2024-04-07',
        endDate: '2024-07-07',
        schedule: 'CN - 09:00',
        createdAt: '2024-03-20T00:00:00Z',
      ),
      OrgClassModel(
        id: 'cl3',
        name: 'Python DS - Online',
        description: 'Lớp Data Science online',
        teacherId: '3',
        teacherName: teachers[2].name,
        courseId: 'c3',
        courseName: courses[2].title,
        totalStudents: 45,
        maxStudents: 50,
        status: 'active',
        startDate: '2024-03-01',
        endDate: '2024-05-31',
        schedule: 'T3, T5 - 20:00',
        createdAt: '2024-02-15T00:00:00Z',
      ),
      OrgClassModel(
        id: 'cl4',
        name: 'Toán A1 - K2023',
        description: 'Lớp toán cho sinh viên năm nhất',
        teacherId: '4',
        teacherName: teachers[3].name,
        courseId: 'c5',
        courseName: courses[4].title,
        totalStudents: 35,
        maxStudents: 40,
        status: 'completed',
        startDate: '2024-01-15',
        endDate: '2024-03-15',
        schedule: 'T2, T4 - 14:00',
        createdAt: '2024-01-01T00:00:00Z',
      ),
    ];
  }

  // ==========================================================================
  // LIVESTREAM - Mock data theo API DOCS
  // ==========================================================================

  @override
  Future<List<OrgLivestreamModel>> getLivestreams({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var livestreams = _getMockLivestreams();

    if (status != null && status.isNotEmpty) {
      livestreams = livestreams.where((l) => l.status == status).toList();
    }

    return livestreams;
  }

  @override
  Future<OrgLivestreamModel> scheduleLivestream({
    required String title,
    required String classId,
    required String scheduledAt,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return OrgLivestreamModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      hostId: 'current_user',
      classId: classId,
      roomName: 'room-${DateTime.now().millisecondsSinceEpoch}',
      status: 'scheduled',
      scheduledAt: scheduledAt,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  List<OrgLivestreamModel> _getMockLivestreams() {
    final teachers = _getMockTeachers();
    final classes = _getMockClasses();
    return [
      OrgLivestreamModel(
        id: 'ls1',
        title: 'Buổi học Flutter - Tuần 5',
        description: 'Ôn tập State Management',
        hostId: '1',
        hostName: teachers[0].name,
        classId: 'cl1',
        className: classes[0].name,
        roomName: 'flutter-k1-w5',
        status: 'scheduled',
        scheduledAt: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        maxViewers: 50,
        isRecorded: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
      OrgLivestreamModel(
        id: 'ls2',
        title: 'IELTS Speaking Practice',
        description: 'Luyện Part 2 & 3',
        hostId: '2',
        hostName: teachers[1].name,
        classId: 'cl2',
        className: classes[1].name,
        roomName: 'ielts-speaking-practice',
        status: 'live',
        startedAt: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        scheduledAt: DateTime.now().subtract(const Duration(minutes: 35)).toIso8601String(),
        activeParticipants: 12,
        maxViewers: 30,
        isRecorded: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      ),
      OrgLivestreamModel(
        id: 'ls3',
        title: 'Python - Pandas Workshop',
        description: 'Thực hành xử lý dữ liệu',
        hostId: '3',
        hostName: teachers[2].name,
        classId: 'cl3',
        className: classes[2].name,
        roomName: 'python-pandas-ws',
        status: 'ended',
        startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
        endedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        scheduledAt: DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 5)).toIso8601String(),
        activeParticipants: 0,
        maxViewers: 60,
        isRecorded: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      ),
    ];
  }
}
