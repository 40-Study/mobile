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
        loadTeachers(classId),
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

  Future<void> loadTeachers(String classId) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    emit(currentState.copyWith(isLoadingTeachers: true));

    try {
      final teachers = await _repository.getClassTeachers(classId);
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(
          teachers: teachers,
          isLoadingTeachers: false,
        ));
      }
    } catch (e) {
      debugPrint('loadTeachers error: $e');
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(isLoadingTeachers: false));
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

  Future<void> loadAttendances(String classId, {String? sessionDate}) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    emit(currentState.copyWith(isLoadingAttendances: true));

    try {
      final attendances = await _repository.getClassAttendances(
        classId,
        sessionDate: sessionDate,
      );
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(
          attendances: attendances,
          isLoadingAttendances: false,
        ));
      }
    } catch (e) {
      debugPrint('loadAttendances error: $e');
      final newState = state;
      if (newState is TeacherClassDetailLoaded) {
        emit(newState.copyWith(isLoadingAttendances: false));
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

  Future<void> removeTeacher(String classId, String teacherId) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    try {
      await _repository.removeTeacherFromClass(classId, teacherId);
      final updatedTeachers =
          currentState.teachers.where((t) => t.id != teacherId).toList();
      emit(currentState.copyWith(teachers: updatedTeachers));
    } catch (e) {
      debugPrint('removeTeacher error: $e');
    }
  }

  Future<void> updateAttendance(
    String classId,
    String studentId,
    String status,
  ) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    try {
      final updatedAttendances = currentState.attendances.map((a) {
        if (a.studentId == studentId) {
          return AttendanceModel(
            id: a.id,
            classId: a.classId,
            studentId: a.studentId,
            studentName: a.studentName,
            studentCode: a.studentCode,
            avatarUrl: a.avatarUrl,
            sessionDate: a.sessionDate,
            status: status,
            note: a.note,
          );
        }
        return a;
      }).toList();

      emit(currentState.copyWith(attendances: updatedAttendances));
    } catch (e) {
      debugPrint('updateAttendance error: $e');
    }
  }

  Future<void> saveAttendances(String classId) async {
    final currentState = state;
    if (currentState is! TeacherClassDetailLoaded) return;

    try {
      final attendanceData = currentState.attendances
          .map((a) => {
                'student_id': a.studentId,
                'status': a.status,
                'session_date': a.sessionDate,
                'note': a.note,
              })
          .toList();

      await _repository.batchUpdateAttendance(classId, attendanceData);
    } catch (e) {
      debugPrint('saveAttendances error: $e');
      rethrow;
    }
  }
}
