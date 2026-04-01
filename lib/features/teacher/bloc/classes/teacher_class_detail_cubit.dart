import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';

part 'teacher_class_detail_state.dart';

class TeacherClassDetailCubit extends Cubit<TeacherClassDetailState> {
  TeacherClassDetailCubit({required TeacherRepository repository})
      : _repository = repository,
        super(const TeacherClassDetailInitial());

  final TeacherRepository _repository;

  Future<void> loadClassDetail(String classId) async {
    emit(const TeacherClassDetailLoading());

    try {
      final classModel = await _repository.getClassDetail(classId);
      emit(TeacherClassDetailLoaded(classModel: classModel));

      // Load related data in parallel
      await Future.wait([
        loadStudents(classId),
        loadAssignments(classId),
        loadDocuments(classId),
        loadSchedules(classId),
      ]);
    } catch (e) {
      emit(TeacherClassDetailFailure(message: e.toString()));
    }
  }

  Future<void> loadStudents(String classId) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    emit(currentState.copyWith(isLoadingStudents: true));

    try {
      final students = await _repository.getStudents(classId: classId);
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(
          students: students,
          isLoadingStudents: false,
        ));
      }
    } catch (e) {
      debugPrint('loadStudents error: $e');
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(isLoadingStudents: false));
      }
    }
  }

  Future<void> loadAssignments(String classId) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    emit(currentState.copyWith(isLoadingAssignments: true));

    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final assignments = _getMockAssignments();
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(
          assignments: assignments,
          isLoadingAssignments: false,
        ));
      }
    } catch (e) {
      debugPrint('loadAssignments error: $e');
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(isLoadingAssignments: false));
      }
    }
  }

  Future<void> loadDocuments(String classId) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    emit(currentState.copyWith(isLoadingDocuments: true));

    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final documents = _getMockDocuments();
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(
          documents: documents,
          isLoadingDocuments: false,
        ));
      }
    } catch (e) {
      debugPrint('loadDocuments error: $e');
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(isLoadingDocuments: false));
      }
    }
  }

  Future<void> loadSchedules(String classId) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    emit(currentState.copyWith(isLoadingSchedules: true));

    try {
      final schedules = await _repository.getClassScheduleModels(classId);
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(
          schedules: schedules,
          isLoadingSchedules: false,
        ));
      }
    } catch (e) {
      debugPrint('loadSchedules error: $e');
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(isLoadingSchedules: false));
      }
    }
  }

  void changeTab(int index) {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    emit(currentState.copyWith(selectedTab: index));
  }

  Future<void> removeStudent(String classId, String studentId) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    try {
      await _repository.removeStudentFromClass(classId, studentId);
      final updatedStudents =
          currentState.students.where((s) => s.id != studentId).toList();
      emit(currentState.copyWith(students: updatedStudents));
    } catch (e) {
      debugPrint('removeStudent error: $e');
    }
  }

  Future<void> loadStudentDetail(String classId, String studentId) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    emit(currentState.copyWith(isLoadingStudentDetail: true));

    try {
      final detail = await _repository.getStudentDetail(classId, studentId);
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(
          selectedStudentDetail: detail,
          isLoadingStudentDetail: false,
        ));
      }
    } catch (e) {
      debugPrint('loadStudentDetail error: $e');
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(isLoadingStudentDetail: false));
      }
    }
  }

  void clearStudentDetail() {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    emit(currentState.copyWith(clearStudentDetail: true));
  }

  List<ClassAssignmentModel> _getMockAssignments() {
    return const [
      ClassAssignmentModel(
        id: 'a1',
        title: 'Bài tập 1: Thiết kế Landing Page',
        description: 'Thiết kế một landing page cho sản phẩm công nghệ',
        dueDate: '2026-04-05',
        maxScore: 100,
        submittedCount: 18,
        totalStudents: 22,
        gradedCount: 15,
        status: ClassAssignmentStatus.active,
        createdAt: '2026-03-20',
      ),
      ClassAssignmentModel(
        id: 'a2',
        title: 'Bài tập 2: Wireframe Mobile App',
        description: 'Vẽ wireframe cho ứng dụng di động e-commerce',
        dueDate: '2026-04-12',
        maxScore: 100,
        submittedCount: 10,
        totalStudents: 22,
        gradedCount: 0,
        status: ClassAssignmentStatus.active,
        createdAt: '2026-03-25',
      ),
      ClassAssignmentModel(
        id: 'a3',
        title: 'Bài tập 3: Design System',
        description: 'Xây dựng design system hoàn chỉnh',
        dueDate: '2026-04-20',
        maxScore: 150,
        submittedCount: 0,
        totalStudents: 22,
        gradedCount: 0,
        status: ClassAssignmentStatus.active,
        createdAt: '2026-03-28',
      ),
      ClassAssignmentModel(
        id: 'a4',
        title: 'Đồ án cuối khóa',
        description: 'Thiết kế UI/UX hoàn chỉnh cho một dự án thực tế',
        dueDate: '2026-05-15',
        maxScore: 200,
        submittedCount: 0,
        totalStudents: 22,
        gradedCount: 0,
        status: ClassAssignmentStatus.draft,
        createdAt: '2026-03-28',
      ),
    ];
  }

  List<ClassDocumentModel> _getMockDocuments() {
    return const [
      ClassDocumentModel(
        id: 'd1',
        title: 'Slide bài giảng - Chương 1: Giới thiệu UI/UX',
        type: DocumentType.ppt,
        description: 'Tổng quan về UI/UX Design',
        fileSize: '15.2 MB',
        downloadCount: 45,
        uploadedAt: '2026-03-01',
      ),
      ClassDocumentModel(
        id: 'd2',
        title: 'Slide bài giảng - Chương 2: Figma cơ bản',
        type: DocumentType.ppt,
        description: 'Hướng dẫn sử dụng Figma từ cơ bản',
        fileSize: '22.8 MB',
        downloadCount: 42,
        uploadedAt: '2026-03-08',
      ),
      ClassDocumentModel(
        id: 'd3',
        title: 'Tài liệu tham khảo - Design Principles',
        type: DocumentType.pdf,
        description: 'Các nguyên tắc thiết kế cơ bản',
        fileSize: '5.4 MB',
        downloadCount: 38,
        uploadedAt: '2026-03-10',
      ),
      ClassDocumentModel(
        id: 'd4',
        title: 'Video hướng dẫn - Auto Layout',
        type: DocumentType.video,
        description: 'Cách sử dụng Auto Layout trong Figma',
        fileSize: '125 MB',
        downloadCount: 30,
        uploadedAt: '2026-03-15',
      ),
      ClassDocumentModel(
        id: 'd5',
        title: 'Template Design System',
        type: DocumentType.link,
        description: 'Link Figma Community template',
        downloadCount: 28,
        uploadedAt: '2026-03-20',
      ),
      ClassDocumentModel(
        id: 'd6',
        title: 'Bảng điểm mẫu',
        type: DocumentType.xls,
        description: 'Template chấm điểm bài tập',
        fileSize: '245 KB',
        downloadCount: 12,
        uploadedAt: '2026-03-22',
      ),
    ];
  }
}
