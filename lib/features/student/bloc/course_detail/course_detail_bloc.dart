import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/config/preview_flags.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/course/repository/course_repository.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/data/mock/mock_course_detail_data.dart';
import 'package:study/features/student/data/models/bookmark_model.dart';
import 'package:study/features/student/repository/student_repository.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  CourseDetailBloc(
    this._repository,
    this._courseRepository,
    this._bookmarkStorage,
  ) : super(const CourseDetailInitial()) {
    on<CourseDetailStarted>(_onStarted);
    on<CourseDetailRefreshed>(_onRefreshed);
    on<CourseDetailSectionToggled>(_onSectionToggled);
    on<CourseDetailBookmarkToggled>(_onBookmarkToggled);
    on<CourseDetailCertificateRequested>(_onCertificateRequested);
    on<CourseDetailEnrollRequested>(_onEnrollRequested);
  }

  final StudentRepository _repository;
  final CourseRepository _courseRepository;
  final BookmarkStorage _bookmarkStorage;
  String? _id;
  bool _isEnrollment = true;

  Future<void> _onStarted(
    CourseDetailStarted event,
    Emitter<CourseDetailState> emit,
  ) async {
    _id = event.id;
    _isEnrollment = event.isEnrollment;
    emit(const CourseDetailInProgress());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    CourseDetailRefreshed event,
    Emitter<CourseDetailState> emit,
  ) async {
    if (_id == null) return;
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<CourseDetailState> emit) async {
    if (_isEnrollment) {
      await _loadEnrollment(emit);
    } else {
      await _loadCourse(emit);
    }
  }

  Future<void> _loadEnrollment(Emitter<CourseDetailState> emit) async {
    final id = _id;
    if (kPreviewDataEnabled && MockCourseDetailData.isMockId(id)) {
      emit(MockCourseDetailData.getMockCourseDetail(id ?? '', isEnrollment: true));
      return;
    }
    if (id == null || id.isEmpty) {
      emit(const CourseDetailFailure('Không tìm thấy khóa học'));
      return;
    }

    final result = await _repository.getCourseDetail(id);

    await result.when(
      success: (enrollment) async {
        // Lưu last accessed course
        unawaited(_repository.setLastAccessedCourse(enrollment.id));

        final courseId = enrollment.course?.id;
        final isBookmarked = await _checkBookmarkStatus(courseId);

        final firstSectionId = enrollment.course?.sections?.firstOrNull?.id;
        emit(CourseDetailSuccess(
          enrollment: enrollment,
          expandedSections: firstSectionId != null ? {firstSectionId} : {},
          isBookmarked: isBookmarked,
        ));
      },
      failure: (error) {
        emit(CourseDetailFailure(error.message ?? 'Không tải được khóa học'));
      },
    );
  }

  Future<void> _loadCourse(Emitter<CourseDetailState> emit) async {
    final id = _id;
    if (kPreviewDataEnabled && MockCourseDetailData.isMockId(id)) {
      emit(MockCourseDetailData.getMockCourseDetail(id ?? '', isEnrollment: false));
      return;
    }
    if (id == null || id.isEmpty) {
      emit(const CourseDetailFailure('Không tìm thấy khóa học'));
      return;
    }

    final result = await _repository.getCourseById(id);

    await result.when(
      success: (course) async {
        final isBookmarked = await _checkBookmarkStatus(course.id);

        // Wrap course in enrollment for UI compatibility
        final enrollment = EnrollmentModel(
          id: '',
          courseId: course.id,
          course: course,
          status: 'preview',
        );
        final firstSectionId = course.sections?.firstOrNull?.id;
        emit(CourseDetailSuccess(
          enrollment: enrollment,
          expandedSections: firstSectionId != null ? {firstSectionId} : {},
          isBookmarked: isBookmarked,
        ));
      },
      failure: (error) {
        emit(CourseDetailFailure(error.message ?? 'Không tải được khóa học'));
      },
    );
  }

  void _onSectionToggled(
    CourseDetailSectionToggled event,
    Emitter<CourseDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is! CourseDetailSuccess) return;

    final expanded = Set<String>.from(currentState.expandedSections);
    if (expanded.contains(event.sectionId)) {
      expanded.remove(event.sectionId);
    } else {
      expanded.add(event.sectionId);
    }

    emit(currentState.copyWith(expandedSections: expanded));
  }

  Future<bool> _checkBookmarkStatus(String? courseId) async {
    if (courseId == null) return false;
    final bookmarks = await _bookmarkStorage.getAll();
    return bookmarks.any((b) => b.itemId == courseId);
  }

  Future<void> _onBookmarkToggled(
    CourseDetailBookmarkToggled event,
    Emitter<CourseDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CourseDetailSuccess) return;

    final course = currentState.course;
    if (course == null) return;

    final bookmarkId = 'course_${course.id}';

    if (currentState.isBookmarked) {
      await _bookmarkStorage.remove(bookmarkId);
      emit(currentState.copyWith(isBookmarked: false));
    } else {
      final bookmark = BookmarkModel(
        id: bookmarkId,
        itemId: course.id,
        type: BookmarkType.course,
        title: course.title,
        thumbnail: course.thumbnailUrl,
        subtitle: course.instructorName,
        savedAt: DateTime.now(),
      );
      await _bookmarkStorage.save(bookmark);
      emit(currentState.copyWith(isBookmarked: true));
    }
  }

  Future<void> _onCertificateRequested(
    CourseDetailCertificateRequested event,
    Emitter<CourseDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CourseDetailSuccess) return;

    final courseId = currentState.course?.id;
    if (courseId == null) return;

    final isMock = kPreviewDataEnabled && MockCourseDetailData.isMockId(courseId);
    if (isMock || currentState.certificate != null) {
      final cert = currentState.certificate ??
          MockCourseDetailData.createMockCertificate(
            courseId,
            currentState.course?.title,
            currentState.course?.instructorName,
          );
      emit(currentState.copyWith(certificate: cert));
      return;
    }

    final result = await _repository.getCertificates();

    final certs = result.when(success: (c) => c, failure: (_) => null);
    if (certs == null) return;

    var cert = certs.where((c) => c.courseId == courseId).firstOrNull;

    // Nếu chưa có chứng chỉ, cấp mới
    if (cert == null) {
      try {
        cert = await _courseRepository.issueCertificate(
          courseId,
          event.enrollmentId,
        );
      } catch (_) {
        return;
      }
    }

    emit(currentState.copyWith(certificate: cert));
  }

  Future<void> _onEnrollRequested(
    CourseDetailEnrollRequested event,
    Emitter<CourseDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CourseDetailSuccess) return;
    if (currentState.isEnrolling) return; // Prevent double tap

    final courseId = currentState.course?.id;
    if (courseId == null) return;

    emit(currentState.copyWith(isEnrolling: true));

    try {
      final enrollment = await _courseRepository.enrollCourse(courseId);
      // Enroll success - reload full data
      _id = enrollment.id;
      _isEnrollment = true;
      await _loadEnrollment(emit);
    } catch (e) {
      final error = _parseEnrollError(e);
      emit(currentState.copyWith(isEnrolling: false, enrollError: error));
    }
  }

  String _parseEnrollError(Object e) {
    final message = e.toString();
    if (message.contains('402') || message.contains('Payment')) {
      return 'Khóa học trả phí. Vui lòng mua qua trang thanh toán.';
    }
    if (message.contains('404')) {
      return 'Khóa học không tồn tại hoặc chưa được xuất bản.';
    }
    if (message.contains('409') || message.contains('COURSE_NOT_FOR_SALE')) {
      return 'Khóa học đã ngừng bán.';
    }
    return 'Không thể đăng ký. Vui lòng thử lại.';
  }
}
