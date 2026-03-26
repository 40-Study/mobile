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

  List<ChildModel> _getMockChildren() {
    return const [
      ChildModel(
        id: '1',
        name: 'Nguyen Van B',
        grade: 'Lop 10A1',
        school: 'Truong THPT ABC',
        attendanceRate: 0.90,
        averageScore: 8.5,
        classCount: 3,
        studentId: 'student-1',
        userId: 'user-1',
      ),
      ChildModel(
        id: '2',
        name: 'Nguyen Thi C',
        grade: 'Lop 8A2',
        school: 'Truong THCS XYZ',
        attendanceRate: 0.95,
        averageScore: 9.0,
        classCount: 2,
        studentId: 'student-2',
        userId: 'user-2',
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
        type: 'attendance',
        childId: '1',
        childName: 'Nguyen Van B',
        createdAt: '2 gio truoc',
      ),
      const ParentNotificationModel(
        id: '2',
        title: 'Nguyen Thi C dat diem 10 bai kiem tra Toan',
        type: 'grade',
        childId: '2',
        childName: 'Nguyen Thi C',
        createdAt: 'Hom qua',
      ),
      const ParentNotificationModel(
        id: '3',
        title: 'Lich hop phu huynh: 30/03/2024',
        type: 'event',
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
