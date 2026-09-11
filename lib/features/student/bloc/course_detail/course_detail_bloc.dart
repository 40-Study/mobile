import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  CourseDetailBloc(this._repository) : super(const CourseDetailInitial()) {
    on<CourseDetailStarted>(_onStarted);
    on<CourseDetailRefreshed>(_onRefreshed);
    on<CourseDetailSectionToggled>(_onSectionToggled);
  }

  final StudentRepository _repository;
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

    result.when(
      success: (enrollment) {
        final firstSectionId = enrollment.course?.sections?.firstOrNull?.id;
        emit(CourseDetailSuccess(
          enrollment: enrollment,
          expandedSections: firstSectionId != null ? {firstSectionId} : {},
        ));
      },
      failure: (error) {
        emit(CourseDetailFailure(error.message ?? 'Loi khong xac dinh'));
      },
    );
  }

  Future<void> _loadCourse(Emitter<CourseDetailState> emit) async {
    final result = await _repository.getCourseById(_id!);

    result.when(
      success: (course) {
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
}
