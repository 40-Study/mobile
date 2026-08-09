import 'package:flutter_bloc/flutter_bloc.dart';
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
  String? _enrollmentId;

  Future<void> _onStarted(
    CourseDetailStarted event,
    Emitter<CourseDetailState> emit,
  ) async {
    _enrollmentId = event.enrollmentId;
    emit(const CourseDetailInProgress());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    CourseDetailRefreshed event,
    Emitter<CourseDetailState> emit,
  ) async {
    if (_enrollmentId == null) return;
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<CourseDetailState> emit) async {
    final result = await _repository.getCourseDetail(_enrollmentId!);

    result.when(
      success: (enrollment) {
        // Expand first section by default
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
