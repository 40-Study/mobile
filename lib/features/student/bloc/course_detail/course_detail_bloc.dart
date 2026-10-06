import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/course/repository/course_repository.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
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
    final result = await _repository.getCourseDetail(_id!);

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
        emit(CourseDetailFailure(error.message ?? 'Loi khong xac dinh'));
      },
    );
  }

  Future<void> _loadCourse(Emitter<CourseDetailState> emit) async {
    final result = await _repository.getCourseById(_id!);

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
        emit(CourseDetailFailure(error.message ?? 'Loi khong xac dinh'));
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
}
